#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_atmos}
mkdir -p ${dir} && cd ${dir}

echo "EDITING SURFACE FILES in ${dir}"
echo "  LAND_VER", ${LAND_VER}

if [[ ${LAND_VER} == HR3 ]]; then
    static_file=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/static/ufs-land_${ATMRES}_hr3_static_fields.nc
    ec_dir=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/run/output/
    files=$( ls ${dir}/sfc_data.tile*.nc )
    python ${SCRIPT_DIR}/SFC_ic_edit.py -d ${dtg} -f ${files} -s ${static_file} -ld  ${ec_dir}
    if (( $? > 0 )); then
        echo "FAIL SFC_ic_edit.py"
        exit 1
    fi  
elif [[ ${LAND_VER} == HR4 ]]; then
    sfc_dir=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/replay_restarts/sfc_output_hr4
    f=sfc_data
    for tile in $(seq 1 6); do
        file_in=${sfc_dir}/${dtg:0:8}/${f}.tile${tile}.nc 
        file_out=${f}.tile${tile}.nc
        if [[ ! -f ${file_in} ]]; then
            echo 'SFC file not found:' ${file_in}
            exit 1
        fi
        cp ${file_in} ${file_out}
        ncatted -a checksum,,d,, ${file_out}
    done
else
    echo "LAND_VER is unknown: ${LAND_VER}"
    exit 1
fi
