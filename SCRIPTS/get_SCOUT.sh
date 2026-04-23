#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
SCOUT_RESTARTS=${SCOUT_RESTARTS:-T}
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
############
# SFS Scout Run
# https://noaa-reanalyses-pds.s3.amazonaws.com/index.html
export aws_path_scout="https://noaa-reanalyses-pds.s3.amazonaws.com/analyses/scout_runs/3dvar_coupledreanl_scoutrun_v1.01"
export restart_tile_files='ca_data fv_core.res fv_srf_wnd.res fv_tracer.res phy_data sfc_data'
export restart_nontile_files='ca_data fv_core.res'
export analysis_files="gdas.t${dtg:8:10}z.atmanl.nc gdas.t${dtg:8:10}z.sfcanl.nc"

dir=${dir_restart_atmos}
if [[ ${SCOUT_RESTARTS} == "T" ]]; then
    aws_path="${aws_path}/${dtg}/gdas.${dtg:0:8}/${dtg:8:10}/model/atmos/restart"
else
    dir=${dir_input_atmos}
    aws_path="${aws_path}/${dtg}/gdas.${dtg:0:8}/${dtg:8:10}/analysis/atmos"
fi
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING FV3 data to ${dir}"

if [[ ${SCOUT_RESTARTS} != "T" ]]; then
    for f in ${analysis_files}; do
        file_in=${aws_path}/${f}
        file_out=${f}
        WGET_AWS ${file_in} ${file_out} 
    done
else
    for f in ${restart_tile_files}; do
    for tile in $(seq 1 6); do
        file_in=${aws_path}/${DTG_TEXT_SRC}.${f}.tile${tile}.nc 
        file_out=${DTG_TEXT_DES}.${f}.tile${tile}.nc
        WGET_AWS ${file_in} ${file_out} 
    done
    done
    for f in ${restart_nontile_files}; do
        file_in=${aws_path}/${DTG_TEXT_SRC}.${f}.nc 
        file_out=${DTG_TEXT_DES}.${f}.nc
        WGET_AWS ${file_in} ${file_out} 
    done
    for tile in $(seq 1 6); do
        file_out=${DTG_TEXT_DES}.sfc_data.tile${tile}.nc
        ncatted -a checksum,,d,, ${file_out}
    done
fi
aws_restart_path="${aws_path}/${dtg}/gdas.${dtg:0:8}/${dtg:8:10}/model/ocean/restart"
aws_inc_path="${aws_path}/${dtg}/gdas.${dtg:0:8}/${dtg:8:10}/analysis/ocean"

############
# MOM restarts
file_in=${aws_restart_path}/${DTG_TEXT_SRC}.MOM.res.nc  
WGET_AWS ${file_in} ${DTG_TEXT_DES}.MOM.res.nc
for i in $(seq 1 3); do
    file_in=${aws_restart_path}/${DTG_TEXT_SRC}.MOM.res_${i}.nc  
    WGET_AWS ${file_in} ${DTG_TEXT_DES}.MOM.res_${i}.nc
done
FIND_EMPTY_FILES ${PWD}

############
# MOM inc files
dir=${dir_inc_ocean}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING MOM6 increments to ${dir}"
file_in=${aws_inc_path}/gdas.t${dtg:8:10}z.ocn.incr.nc  
file_out=gdas.t${dtg:8:10}z.ocn.incr.nc
WGET_AWS ${file_in} ${file_out}
FIND_EMPTY_FILES ${PWD}

echo "DOWNLOADING MEDIATOR data to ${dir}"

f=${DTG_TEXT_SRC}.ufs.cpld.cpl.r.nc
file_in=${aws_path}/${dtg}/gdas.${dtg:0:8}/${dtg:8:10}/model/med/restart/${f}
file_out=${DTG_TEXT_DES}.ufs.cpld.cpl.r.nc
WGET_AWS ${file_in} ${file_out}

FIND_EMPTY_FILES ${PWD}

