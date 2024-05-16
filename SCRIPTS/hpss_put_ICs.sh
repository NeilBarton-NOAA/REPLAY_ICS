#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
cd ${IC_DIR}

HPSS_DIR=/NCEPDEV/emc-marine/2year/${USER}/REPLAY_ICS/${ATMRES}${OCNRES} 
hsi mkdir -p ${HPSS_DIR}
file_name=${HPSS_DIR}/${dtg}.tar
htar -cvf ${file_name} ${dtg}
if (( ${?} > 0 )); then
    echo 'ERROR in htar'
    exit 1
fi

