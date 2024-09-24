set -xu
SCRIPT_DIR=${SCRIPT_DIR:-$PWD}
run=gefs

############
# number of ensembles
dow=$(date -d "${dtg:0:8}" +%A)
if [[ ${dow} == "Thursday" ]] || [[ ${dow} == "Monday" ]]; then
    NENS=10
else
    NENS=5
fi
if [[ ${ATMRES} != "C384" ]]; then
    NENS=10
fi

############
machine=$(uname -n)
[[ ${machine:0:3} == hfe ]] && TOPICDIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs
[[ ${machine} == hercules* ]] && TOPICDIR=/work/noaa/marine/nbarton/ICs

############
# time stamp, Noah-MP land version, and IC directory
if [[ ${ATMRES} == "C384" ]]; then
    DTG_TEXT=${dtg:0:8}.030000 # restarts valid at 
    LAND_VER=HR3
    IC_DIR=${TOPICDIR}/REPLAY_ICs/${ATMRES}${OCNRES}
else
    DTG_TEXT=${dtg:0:8}.000000 # restarts valid at 
    LAND_VER=HR4
    IC_DIR=${TOPICDIR}/${LAND_VER}/${ATMRES}${OCNRES}
fi
mkdir -p ${IC_DIR}

###########
# directories for each component
dtg_precycle=$(date -u -d"${dtg:0:4}-${dtg:4:2}-${dtg:6:2} ${dtg:8:2}:00:00 6 hours ago" +%Y%m%d%H)
if [[ ${LAND_VER} == HR3 ]]; then
    dir_atmos=${IC_DIR}/${dtg}/mem000/atmos
    dir_ocean=${IC_DIR}/${dtg}/mem000/ocean
    dir_ice=${IC_DIR}/${dtg}/mem000/ice
    dir_wave=${IC_DIR}/${dtg}/mem000/wave
    dir_med=${IC_DIR}/${dtg}/mem000/med
else
    if [[ ${ATMRES} == "C384" ]]; then
        dir_atmos=${IC_DIR}/${run}.${dtg:0:8}/${dtg:8:2}/mem000/model/atmos/restart
    else
        dir_atmos=${IC_DIR}/${run}.${dtg:0:8}/${dtg:8:2}/mem000/model/atmos/input
    fi
    dir_ocean=${IC_DIR}/${run}.${dtg_precycle:0:8}/${dtg_precycle:8:2}/mem000/model/ocean/restart
    dir_ice=${IC_DIR}/${run}.${dtg_precycle:0:8}/${dtg_precycle:8:2}/mem000/model/ice/restart
    dir_wave=${IC_DIR}/${run}.${dtg_precycle:0:8}/${dtg_precycle:8:2}/mem000/model/wave/restart
    dir_med=${IC_DIR}/${run}.${dtg_precycle:0:8}/${dtg_precycle:8:2}/mem000/model/med/restart
    dir_atmos_perturbations=${IC_DIR}/${run}.${dtg:0:8}/${dtg:8:2}/mem001/analysis/atmos
    dir_ocean_perturbations=${IC_DIR}/${run}.${dtg:0:8}/${dtg:8:2}/mem001/analysis/ocean
fi


############
# Replay Restarts
# https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/index.html
aws_path="https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/${dtg:0:4}/${dtg:4:2}/${dtg:0:8}06"

########################
# CODE Directory for chgres and aerosol tools
CODE_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/CODE/REPLAY

########################
# compiler used for chgres
export chgres_compiler=intel
export APRUN="srun"

