#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
cd ${IC_DIR}

if [[ ${LAND_VER} == HR3 ]]; then
    HPSS_DIR=/NCEPDEV/emc-marine/2year/${USER}/REPLAY_ICS/${ATMRES}${OCNRES} 
    folders=${dtg}
else
    HPSS_DIR=/NCEPDEV/emc-marine/2year/${USER}/ICS/${LAND_VER}/${ATMRES}${OCNRES} 
    folders=""
    [[ -d ${IC_DIR}/${run}.${dtg:0:8} ]] && folders="${folders} ${run}.${dtg:0:8}"
    [[ -d ${IC_DIR}/${run}.${dtg_precycle:0:8} ]] && folders="${folders} ${run}.${dtg_precycle:0:8}"
fi
hsi mkdir -p ${HPSS_DIR}
file_name=${HPSS_DIR}/${dtg}.tar
htar -cvf ${file_name} ${folders}
if (( ${?} > 0 )); then
    echo 'ERROR in htar'
    exit 1
fi
if [[ ${ATMRES} != "C96" ]]; then
    echo "Removing C384 and C192 data from hera"
    rm -r ${dtg}
fi
