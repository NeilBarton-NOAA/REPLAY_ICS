#!/bin/bash
set -u
# Run CHGRES for ICs
dtg=${1:-2022030100}
export IC_SRC=${2:-CPC_land}
export TOPDIR=${PWD}
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
BACKGROUND_JOB=T
source ${TOPDIR}/MACHINE/config.sh
source ${TOPDIR}/SCRIPTS/defaults.sh
dir_land_states=/scratch3/NCEPDEV/land/Michael.Barlage/spinup_sfs/ufs-land-driver/run/utility_scripts/spinup/C192.mx025_sfs/
file_land_states=$( ls ${dir_land_states}/ufs_land_restart.${dtg:0:4}-${dtg:4:2}-${dtg:6:2}_00-00-00.nc)

members="000"
for mem in ${members}; do
    JOB_NAME=LAND.MEM${mem}.${dtg}
    WALLTIME="00:30:00"
    source ${TOPDIR}/MACHINE/config.sh
    echo "${JOB_NAME}"
    ${SUBMIT} python ${SCRIPT_DIR}/LAND_UPDATE/spinup/replace_land_states.py "${dir_input_atmos}/" ${file_land_states}
    [[ ${?} > 0 ]] && echo "FATAL with SUBMIT_HPSS" && exit 1
done
