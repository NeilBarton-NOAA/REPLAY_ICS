#!/bin/bash
set -u
# Get ICs for GFS or CPC
#dtg=${1:-2022030100}
#export IC_SRC=${2:-CPC_land}
dtg=${1:-2022030100}
export IC_SRC=${2:-REPLAY}
export TOPDIR=${PWD}
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
source ${TOPDIR}/MACHINE/config.sh
source ${TOPDIR}/SCRIPTS/defaults.sh

${SCRIPT_DIR}/link_member_dirs.sh ${dtg} ${IC_SRC} 

