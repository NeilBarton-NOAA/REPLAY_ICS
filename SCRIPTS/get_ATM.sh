#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh

dir=${IC_DIR}/${dtg}/mem000/atmos
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING FV3 data to ${dir}"

files='ca_data fv_core.res fv_srf_wnd.res fv_tracer.res phy_data sfc_data'
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

if [[ ${ATMRES} == "C384" ]]; then
    touch ${DTG_TEXT}.coupler.res
fi
