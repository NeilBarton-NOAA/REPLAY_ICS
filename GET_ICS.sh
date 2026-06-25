#!/bin/bash
set -u
# Get ICs for GFS or CPC
dtg=${1:-2026030100}
export IC_SRC=${2:-GFS}
export TOPDIR=${PWD}
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
source ${TOPDIR}/MACHINE/config.sh
source ${TOPDIR}/SCRIPTS/defaults.sh
export ATMRES=C384
BACKGROUND_JOB=T && export MV_DATA=T && export DOWNLOAD=T
####################################
if [[ ${IC_SRC} == "GFS" ]]; then
    files="gdasocean_restart gdasocean_analysis gdas_restarta gdas_restartb enkfgdas \
           enkfgdas_restarta_grp1 enkfgdas_restartb_grp1"
    # comment out below if only need 10 members
    files="${files} enkfgdas_restarta_grp2 enkfgdas_restartb_grp2 enkfgdas_restarta_grp3 enkfgdas_restartb_grp3"
elif [[ ${IC_SRC} == "DA_UPDATE" ]]; then
    files="gdasocean_restart gdasocean_analysis gdas_restartb enkfgdas_restarta_grp1 enkfgdas_restartb_grp1"
    # comment out below if only need 10 members
    files="${files} enkfgdas_restarta_grp2 enkfgdas_restartb_grp2 enkfgdas_restarta_grp3 enkfgdas_restartb_grp3"
elif [[ ${IC_SRC} == "REPLAY" ]] || [[ ${IC_SRC} == *"CPC"* ]]; then
    files="ATM OCN ICE"
fi
[[ ${IC_SRC} == *"CPC"* ]] && SCRIPT_TAG=CPC
[[ ${IC_SRC} == "DA_UPDATE"* ]] && SCRIPT_TAG=GFS
####################################
for f in ${files}; do
    JOB_NAME=GET.${IC_SRC}.${f}.${dtg} && echo ${JOB_NAME}
    source ${TOPDIR}/MACHINE/config.sh
    ${SUBMIT_HPSS} ${SCRIPT_DIR}/get_${SCRIPT_TAG:-$IC_SRC}.sh ${dtg} ${f} ${IC_SRC} 
    [[ ${?} > 0 ]] && echo "FATAL with SUBMIT_HPSS" && exit 1
done 

