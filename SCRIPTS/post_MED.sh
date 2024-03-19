#!/bin/bash
set -xu
dtg=${1}
topoutdir=${2}
dir=${topoutdir}/${dtg}/mem000/med

echo "EDITING MEDIATOR restart in ${dir}"
file=${dir}/${DTG_TEXT}.ufs.cpld.cpl.r.nc
python ${SCRIPT_DIR}/MED_replay2dev.py -r ${file} -d ${SCRIPT_DIR}/INPUT/ufs.cpld.cpl.r.DEV.nc
#new_file=$(ls new*nc)
#mv ${new_file} ${PWD}/${file}
echo 'NPB check'
exit 1 
