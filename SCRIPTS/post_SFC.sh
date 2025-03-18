#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_atmos}
mkdir -p ${dir} && cd ${dir}

echo "EDITING SURFACE FILES in ${dir}"
echo "  LAND_VER", ${LAND_VER}
if [[ ${LAND_VER} == HR3 ]]; then
    static_file=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/static/ufs-land_${ATMRES}_hr3_static_fields.nc
    ec_dir=/scratch2/BMC/gsienkf/Philip.Pegion/ufs-land-driver/run/output/
    files=$( ls ${dir}/sfc_data.tile*.nc )
    ${PYTHON} ${SCRIPT_DIR}/SFC_hr3_edit.py -d ${dtg} -f ${files} -s ${static_file} -ld  ${ec_dir}
    if (( $? > 0 )); then
        echo "FAIL SFC_ic_edit.py"
        exit 1
    fi  
elif [[ ${LAND_VER} == HR4 ]]; then
    if [[ ${ATMRES} == "C96" ]]; then 
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
    elif [[ ${ATMRES} == "C192" ]]; then
        IDS=""
        for tile in $(seq 1 6); do
            file=sfc_data.tile${tile}.nc 
            [[ -f ${file} ]] && rm ${file} 
            echo "Downloading ${dir}/${file}"
            #WGET_AWS ${aws_C192sfc}/${file} ${dir}/${file} 
            ID=$( GLOBUS_AWS ${aws_C192sfc}/${file} ${dir}/${file} )
            [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed: ${dir}/${file}" && RETRY="YES"
            [[ ${ID} != 9999 ]] && IDS="${IDS} ${ID}"
        done
        # wait for the downloads to finish
        for ID in ${IDS}; do
            globus task wait ${ID}
        done
        [[ ${RETRY:-"NO"} == "YES" ]] && exit 1
    fi
    # remove checksum from sfc_data files
    for tile in $(seq 1 6); do
        file_out=sfc_data.tile${tile}.nc
        ncatted -a checksum,,d,, ${file_out}
        echo "Remove NaNs in: ${file_out}"
        ${PYTHON} ${SCRIPT_DIR}/SFC_ic_edit.py -f ${file_out}
    done
else
    echo "LAND_VER is unknown: ${LAND_VER}"
    exit 1
fi
