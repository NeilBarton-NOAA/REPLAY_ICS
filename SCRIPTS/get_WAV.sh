#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_wave}
mkdir -p ${dir} && cd ${dir}

echo "DOWNLOADING WAVEWATCHIII data to ${dir}"
file_in=restart.ww3
file_out=${DTG_TEXT}.restart.glo_025
WGET_AWS ${aws_path}/${file_in} ${file_out}

FIND_EMPTY_FILES ${PWD}

