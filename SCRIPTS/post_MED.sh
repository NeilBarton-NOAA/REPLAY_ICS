#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_med}

echo "EDITING MEDIATOR restart in ${dir}"
file=${dir}/${DTG_TEXT}.ufs.cpld.cpl.r.nc
dev_file=${IC_DIR}/ufs.cpld.cpl.r.DEV.nc

if [[ ! -f ${dev_file} ]]; then
    echo "GRABBING ${dev_file} from HPSS"
    HPSS_DIR="/NCEPDEV/emc-marine/2year/Neil.Barton/REPLAY_ICS"
    HPSS_FILE=${HPSS_DIR}/$(basename ${dev_file})
    hsi -q get ${HPSS_FILE} : ${dev_file}
fi

python ${SCRIPT_DIR}/MED_replay2dev.py -r ${file} -d ${dev_file}
if (( $? > 0 )); then
    echo "FAIL Med_replay2dev.py"
    exit 1
fi
new_file=${dir}/DEV_MEDFILE.nc
mv ${new_file} ${file}
echo "mediator file updated"
