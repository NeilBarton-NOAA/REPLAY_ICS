#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh

dir=${dir_wave}
mkdir -p ${dir} && cd ${dir}

echo "EDITING WAV binary IC in ${dir}"
file=${DTG_TEXT}.restart.glo_025
python3 ${SCRIPT_DIR}/WAV_ic_edit.py -f ${file}
new_file=$(ls *new*)
mv ${new_file} ${PWD}/${file}
