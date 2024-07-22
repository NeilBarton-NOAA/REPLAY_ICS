#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh

dir=${IC_DIR}/${dtg}/mem000/atmos
mkdir -p ${dir} && cd ${dir}

echo "EDITING SURFACE FILES in ${dir}"
static_file=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/static/ufs-land_${ATMRES}_hr3_static_fields.nc
ec_dir=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/run/output/
files=$( ls ${dir}/sfc_data.tile*.nc )
python ${SCRIPT_DIR}/SFC_ic_edit.py -d ${dtg} -f ${files} -s ${static_file} -ld  ${ec_dir}
if (( $? > 0 )); then
    echo "FAIL SFC_ic_edit.py"
    exit 1
fi

