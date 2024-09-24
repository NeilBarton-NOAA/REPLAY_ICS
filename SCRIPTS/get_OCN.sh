#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_ocean}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING MOM6 data to ${dir}"
WGET_AWS ${aws_path}/MOM.res.nc ${DTG_TEXT}.MOM.res.nc
for i in $(seq 1 3); do
    WGET_AWS ${aws_path}/MOM.res_${i}.nc ${DTG_TEXT}.MOM.res_${i}.nc
done

FIND_EMPTY_FILES ${PWD}

