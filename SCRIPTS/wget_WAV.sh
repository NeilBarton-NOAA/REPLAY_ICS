#!/bin/bash
set -u
dtg=${1}
topoutdir=${2}
source ${SCRIPT_DIR}/functions.sh
dir=${topoutdir}/${dtg}/mem000/wave
mkdir -p ${dir} && cd ${dir}

echo "DOWNLOADING WAVEWATCHIII data to ${dir}"
file_in=restart.ww3
file_out=${DTG_TEXT}.restart_glo025
WGET_AWS ${aws_path}/${file_in} ${file_out}

