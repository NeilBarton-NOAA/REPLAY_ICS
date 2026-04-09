#!/bin/bash
set -u
# Get ICs for GFS or CPC
dtg=${1:-2025010100}
export IC_SRC=REPLAY
export TOPDIR=${PWD}
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
source ${TOPDIR}/MACHINE/config.sh
source ${TOPDIR}/SCRIPTS/defaults.sh

${SCRIPT_DIR}/link_member_dirs.sh ${dtg}  

