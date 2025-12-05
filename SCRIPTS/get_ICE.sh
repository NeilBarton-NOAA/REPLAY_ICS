#!/bin/bash
set -xu
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_ice}
mkdir -p ${dir} && cd ${dir}

echo "DOWNLOADING CICE data to ${dir}"
if [[ ${SCOUT_RUN} == "True" ]]; then
    f_in=${aws_path}/model/ice/restart/${DTG_TEXT}.${f}.nc  
else
    file_in=${aws_path}/iced.${dtg:0:4}-${dtg:4:2}-${dtg:6:2}-10800.nc
fi
file_out=${DTG_TEXT}.cice_model.res.nc
if [[ ${GLOBUS} == T ]]; then
    ID=$( GLOBUS_AWS ${aws_path}/${file_in} ${dir}/${file_out} )
    [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed" && exit 1
    globus task wait ${ID}
else
    WGET_AWS ${file_in} ${file_out} 
fi
FIND_EMPTY_FILES ${PWD}
