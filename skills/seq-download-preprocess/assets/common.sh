#!/usr/bin/env bash
# lib/common.sh — shared config, logging, guards, and container wrapper
#
# Preserved baseline for sequencing preprocessing pipelines. Copy to
# lib/common.sh and adjust. The contract below (log_* / require_file /
# already_done / run_in_container / the MNT_* mounts) is what generated
# run_*.sh scripts depend on — keep those names stable.
#
# Source it first, before any other setup:
#   ORGANISM=mouse
#   source "${ROOT_DIR}/lib/common.sh"

# ── Paths (host side) ─────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${DATA_DIR:-${REPO_ROOT}/data}"
RESULTS_DIR="${RESULTS_DIR:-${REPO_ROOT}/results}"
CONTAINER="${CONTAINER:-${REPO_ROOT}/apptainer/pipeline.sif}"

# ── Container-side mount points ───────────────────────────────────────────────
# Every path passed into run_in_container must be one of these, never a host
# path. Passing a host path is the most common failure and surfaces as "file not
# found" for a file that plainly exists.
MNT_DATA="/mnt/data"
MNT_RESULTS="/mnt/results"
MNT_OUT="/mnt/out"          # the script's -o directory, bound automatically below

# Conventional subdirectories of the output dir. Defined here so step blocks can
# use them without each script redefining them (and without dying on an unbound
# variable under `set -u`).
MNT_WORK="${MNT_OUT}/tmp"
MNT_QC="${MNT_OUT}/qc"
MNT_BAM="${MNT_OUT}/genome_bams"

# ── Runtime ───────────────────────────────────────────────────────────────────
THREADS="${THREADS:-16}"

# ── Logging ───────────────────────────────────────────────────────────────────
# NOTE: there is deliberately no log_warn — do not call one.
log_info()  { echo "[INFO]  $(date '+%H:%M:%S') $*"; }
log_error() { echo "[ERROR] $(date '+%H:%M:%S') $*" >&2; }
log_step()  { echo ""; echo "=== $* ==="; }

# ── Guards ────────────────────────────────────────────────────────────────────
require_file() {
    local path="$1" label="${2:-$1}"
    if [[ ! -f "$path" ]]; then
        log_error "Required file not found: ${label}"
        log_error "  Expected at: ${path}"
        return 1
    fi
}

# Returns 0 (true) when the output already exists → caller should skip.
already_done() {
    local output="$1"
    if [[ -f "$output" ]]; then
        log_info "Skipping — output already exists: $(basename "$output")"
        return 0
    fi
    return 1
}

# ── Container wrapper ─────────────────────────────────────────────────────────
# Usage: run_in_container <extra_binds> <command_string>
#   extra_binds: comma-separated "host:container" pairs, or "" for none
#
# ${OUT_DIR} is bound at ${MNT_OUT} automatically when set, because -o routinely
# points outside RESULTS_DIR and an unbound output directory is invisible inside
# the container — the job then fails on a path the user can see on the host.
run_in_container() {
    local extra_binds="$1"
    local cmd="$2"
    local binds="${DATA_DIR}:${MNT_DATA},${RESULTS_DIR}:${MNT_RESULTS}"
    if [[ -n "${OUT_DIR:-}" ]]; then
        mkdir -p "${OUT_DIR}"
        binds="${binds},${OUT_DIR}:${MNT_OUT}"
    fi
    [[ -n "$extra_binds" ]] && binds="${binds},${extra_binds}"
    apptainer exec --bind "${binds}" "${CONTAINER}" bash -c "${cmd}"
}

# ── Organism reference selection ──────────────────────────────────────────────
# Each data/<organism>/config.sh exports the reference paths and the
# organism-specific parameters (INTRON_MAX, ...) that belong with them. Adding an
# organism is a new directory, not a diff to this file. Produced by the
# organism-reference-setup skill.
ORGANISM="${ORGANISM:-}"
MNT_ORG="${MNT_DATA}/${ORGANISM}"
ORG_CONFIG="${DATA_DIR}/${ORGANISM}/config.sh"
ORG_CONFIG_LOADED=false
if [[ -n "${ORGANISM}" && -f "${ORG_CONFIG}" ]]; then
    # shellcheck source=/dev/null
    source "${ORG_CONFIG}"
    ORG_CONFIG_LOADED=true
fi

# Call from preflight, NOT at source time: sourcing happens before getopts, so a
# hard exit here would make `-h` fail on a machine where the reference has not
# been set up yet — exactly when someone needs to read the help.
require_organism() {
    [[ "${ORG_CONFIG_LOADED}" == true ]] && return 0
    if [[ -z "${ORGANISM}" ]]; then
        log_error "ORGANISM is not set. Pass it, e.g. ORGANISM=mouse $0 ..."
    else
        log_error "No reference config for organism '${ORGANISM}': ${ORG_CONFIG}"
        log_error "Run the reference setup script for this organism first."
    fi
    return 1
}
