#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_restart_ocean}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING MOM6 restarts to ${dir}"

aws_restart_path="${aws_path}/${dtg_minus6}/gdas.${dtg_minus6:0:8}/${dtg_minus6:8:10}/model/ocean/restart"
aws_inc_path="${aws_path}/${dtg}/gdas.${dtg:0:8}/${dtg:8:10}/analysis/ocean"

############
# MOM restarts
file_in=${aws_restart_path}/${DTG_TEXT}.MOM.res.nc  
WGET_AWS ${file_in} ${DTG_TEXT}.MOM.res.nc
for i in $(seq 1 3); do
    file_in=${aws_restart_path}/${DTG_TEXT}.MOM.res_${i}.nc  
    WGET_AWS ${file_in} ${DTG_TEXT}.MOM.res_${i}.nc
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

exit 0
