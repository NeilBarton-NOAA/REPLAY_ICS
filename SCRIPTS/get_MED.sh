#!/bin/bash
set -u
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_med}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING MEDIATOR data to ${dir}"

file_in=ufs.cpld.cpl.r.${dtg:0:4}-${dtg:4:2}-${dtg:6:2}-10800.nc
file_out=${DTG_TEXT}.ufs.cpld.cpl.r.nc
if [[ ${GLOBUS} == T ]]; then
    ID=$( GLOBUS_AWS ${aws_path}/${file_in} ${dir}/${file_out} )
    [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed" && exit 1
    globus task wait ${ID}
else
    WGET_AWS ${aws_path}/${file_in} ${file_out}
fi

FIND_EMPTY_FILES ${PWD}

