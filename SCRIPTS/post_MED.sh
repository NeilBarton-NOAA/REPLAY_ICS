#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${IC_DIR}/${dtg}/mem000/med

echo "EDITING MEDIATOR restart in ${dir}"
file=${dir}/${DTG_TEXT}.ufs.cpld.cpl.r.nc
dev_file=${IC_DIR}/ufs.cpld.cpl.r.DEV.nc

if [[ ! -f ${dev_file} ]]; then
    echo "GRABBING ${dev_file} from HPSS"
fi

python ${SCRIPT_DIR}/MED_replay2dev.py -r ${file} -d ${SCRIPT_DIR}/INPUT/ufs.cpld.cpl.r.DEV.nc
#new_file=$(ls new*nc)
#mv ${new_file} ${PWD}/${file}
echo 'NPB check'
exit 1 
