#!/bin/bash
set -u
dtg=${1}
topoutdir=${2}
source ${SCRIPT_DIR}/functions.sh
dir=${topoutdir}/${dtg}/mem000/ocean
mkdir -p ${dir} && cd ${dir}

echo "DOWNLOADING MOM6 data to ${dir}"
WGET_AWS -nc ${aws_path}/MOM.res.nc -o ${DTG_TEXT}.MOM_res.nc
for i in $(seq 1 3); do
    WGET_AWS ${aws_path}/MOM.res_${i}.nc ${DTG_TEXT}.MOM.res_${i}.nc
done

