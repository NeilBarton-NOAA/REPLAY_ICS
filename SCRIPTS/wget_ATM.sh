#!/bin/bash
set -u
dtg=${1}
topoutdir=${2}
source ${SCRIPT_DIR}/functions.sh
files='ca_data fv_core.res fv_srf_wnd.res fv_tracer.res phy_data sfc_data'
dir=${topoutdir}/${dtg}/mem000/atmos
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING FV3 data to ${dir}"
echo "${aws_path}/${dtg:0:4}/${dtg:4:2}/${dtg:0:8}06/"

for f in ${files}; do
    for tile in $(seq 1 6); do
        file_in=${f}.tile${tile}.nc 
        file_out=${DTG_TEXT}.${f}.tile${tile}.nc
        WGET_AWS ${aws_path}/${file_in} ${file_out} 
    done
done

files='ca_data fv_core.res'
for f in ${files}; do
    file_in=${f}.nc
    file_out=${DTG_TEXT}.${f}.nc
    WGET_AWS ${aws_path}/${file_in} ${file_out} 
done

