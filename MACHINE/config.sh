#!/bin/sh
####################################
# Local Directoriesi and 'global' variables
export HPC_ACCOUNT=${COMPUTE_ACCOUNT}
export TOPDIR=${SCRIPT_DIR}/../
machine=$(uname -n)
JOB_NAME=${JOB_NAME:-hpss}
WALLTIME=${WALLTIME:-01:00:00}
NTASKS=${NTASKS:-1}

BATCH_SYSTEM="sbatch"
SUBMIT_SUFFIX=""
SUBMIT_HPSS_SUFFIX=""
############
# scrath dir based in machine
machine=$(uname -n)
export chgres_compiler=intel
if [[ ${machine:0:3} == hfe || ${machine} == h*[cm]* ]]; then
    machine=hera
    export WORK_DIR=/scratch2/NCEPDEV/stmp3/${USER}
elif [[ ${machine} == hercules* ]]; then
    machine=hercules
    export WORK_DIR=/work/noaa/marine/${USER}
elif [[ ${machine} == gaea* || ${machine} == dtn* || ${machine} == c6* ]]; then
    machine=gaea
    export WORK_DIR=/gpfs/f6/sfs-emc/scratch/${USER}
    SUBMIT_SUFFIX="--qos=normal --clusters=c6 --partition=batch"
    SUBMIT_HPSS_SUFFIX="--mem=100G --qos=hpss --clusters=es --partition=dtn_f5_f6 --constraint=f6"
elif [[ ${machine} == u* ]]; then
    machine=ursa
    export chgres_compiler=intelllvm
    export WORK_DIR=/scratch4/NCEPDEV/stmp/${USER}
    SUBMIT_SUFFIX="--mem=0 --qos=batch"
    SUBMIT_HPSS_SUFFIX="--mem=100G --partition=u1-service"
elif [[ ${machine} == *[cd]login* ]]; then
    machine=wcoss2
    export WORK_DIR=/lfs/h2/emc/couple/noscrub/${USER}
else
    echo 'FATAL: MACHINE UNKNOWN'
    exit 1
fi
SUBMIT_BASE="${BATCH_SYSTEM} 
    --job-name=${JOB_NAME} 
    --output=${TOPDIR}/logs/${JOB_NAME}.out
    --error=${TOPDIR}/logs/${JOB_NAME}.out
    --time=${WALLTIME} 
    --account=${HPC_ACCOUNT} 
    --ntasks=${NTASKS}"
SUBMIT="${SUBMIT_BASE} ${SUBMIT_SUFFIX}"
SUBMIT_HPSS="${SUBMIT_BASE} ${SUBMIT_HPSS_SUFFIX}"

if [[ ${BACKGROUND_JOB:-F} == T ]]; then
    SUBMIT=""
    SUBMIT_HPSS=""
fi

source ${SCRIPT_DIR}/../MACHINE/modules.sh
