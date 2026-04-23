#!/bin/bash
set -u
# Run CHGRES for ICs
#dtg=${1:-2026030100}
#export IC_SRC=${2:-GFS}
dtg=${1:-2022030100}
export IC_SRC=${2:-CPC_land}
#dtg=${1:-2022030100}
#export IC_SRC=${2:-REPLAY}
export DEBUG=F
export TOPDIR=${PWD}
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
BACKGROUND_JOB=F
source ${TOPDIR}/MACHINE/config.sh
source ${TOPDIR}/SCRIPTS/defaults.sh

if [[ ${IC_SRC} == "GFS" ]]; then
    models="ATM"
    members=$( ls -d ${dir_restart_atmos%/mem000*}/mem*/ | grep -oP '(?<=mem)\d{3}')
elif [[ ${IC_SRC} == "REPLAY" ]]; then
    models="ATM"
    members="000"
elif [[ ${IC_SRC} == *"CPC"* ]]; then
    models="ATM OCN ICE"
    members="000"
    SCRIPT_TAG=CPC
fi

for model in ${models}; do
    for mem in ${members}; do
        JOB_NAME=CHGRES.${IC_SRC}.${model}.MEM${mem}.${dtg}
        NTASKS=12
        WALLTIME="00:30:00"
        source ${TOPDIR}/MACHINE/config.sh
        if [[ ${mem} == "000" && ${IC_SRC} == GFS ]]; then
            ATMRES="C1152"
        else
            ATMRES="C384"
        fi
        echo "${JOB_NAME}"
        ${SUBMIT} ${SCRIPT_DIR}/chgres_${model}.sh ${dtg} ${ATMRES} mx025 ${mem} ${IC_SRC}
        [[ ${?} > 0 ]] && echo "FATAL with SUBMIT_HPSS" && exit 1
    done
done
