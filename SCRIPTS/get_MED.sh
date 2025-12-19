#!/bin/bash
set -u
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_restart_med}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING MEDIATOR data to ${dir}"

f=${DTG_TEXT}.ufs.cpld.cpl.r.nc
file_in=${aws_path}/${dtg_minus6}/gdas.${dtg_minus6:0:8}/${dtg_minus6:8:10}/analysis/ice/${f}
file_out=${f}
WGET_AWS ${file_in} ${file_out}

FIND_EMPTY_FILES ${PWD}

exit 0
