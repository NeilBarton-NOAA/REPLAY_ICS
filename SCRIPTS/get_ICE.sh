#!/bin/bash
set -xu
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh

dir=${IC_DIR}/${dtg}/mem000/ice
mkdir -p ${dir} && cd ${dir}

echo "DOWNLOADING CICE data to ${dir}"
file_in=iced.${dtg:0:4}-${dtg:4:2}-${dtg:6:2}-10800.nc
file_out=${DTG_TEXT}.cice_model.res.nc
WGET_AWS ${aws_path}/${file_in} ${file_out} 

FIND_EMPTY_FILES ${PWD}
