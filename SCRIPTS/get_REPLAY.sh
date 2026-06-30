#!/bin/bash
set -u
export dtg=${1}
model=${2} # ATM, OCN, ICE
DEBUG=${DEBUG:-F}
export IC_SRC=REPLAY
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh

########################
# GEFSv13 Replay
# https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/index.html
# https://noaa-oar-sfsdev-pds.s3.amazonaws.com/index.html
aws_path_replay="https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/${dtg:0:4}/${dtg:4:2}/${dtg:0:8}06"
aws_path_sfc="https://noaa-oar-sfsdev-pds.s3.amazonaws.com/input/c192/hr4_land/${dtg}"

[[ ${model} == "ATM" ]] && dir=${dir_restart_atmos} && files=${restart_nontile_files_atmos}
[[ ${model} == "OCN" ]] && dir=${dir_restart_ocean} && files=${restart_files_ocean}
[[ ${model} == "ICE" ]] && dir=${dir_restart_ice} && files="iced.${dtg:0:4}-${dtg:4:2}-${dtg:6:2}-10800"
[[ ${model} == "MED" ]] && dir=${dir_restart_med} && files="ufs.cpld.cpl.r.${dtg:0:4}-${dtg:4:2}-${dtg:6:2}-10800"

############
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING ${model} data to ${dir}"

if [[ ${model} == "ATM" ]]; then
    for f in ${restart_tile_files_atmos}; do
    for tile in $(seq 1 6); do
        file_in=${f}.tile${tile}.nc 
        file_out=${DTG_TEXT_MINUS3}.${f}.tile${tile}.nc
        if [[ ${f} == "sfc_data" ]] && [[ "${dtg}" -ge "1994050100" && "${dtg}" -le "2023110106" ]]; then
            WGET_AWS ${aws_path_sfc}/${file_in} ${file_out} 
            [[ $? > 0 ]] && echo "FATAL in download" && exit 1
        else
            WGET_AWS ${aws_path_replay}/${file_in} ${file_out} 
            [[ $? > 0 ]] && echo "FATAL in download" && exit 1
        fi
    done
    done
fi

for f in ${files}; do
    file_in=${f}.nc
    if [[ ${model} == 'ICE' ]]; then
        file_out=${DTG_TEXT}.cice_model.res.nc
    elif [[ ${model} == 'OCN' ]]; then
        file_out=${DTG_TEXT}.${f}.nc
    elif [[ ${model} == 'MED' ]]; then
        file_out=${DTG_TEXT}.ufs.cpld.cpl.r.nc
    else
        file_out=${DTG_TEXT_MINUS3}.${f}.nc
    fi
    WGET_AWS ${aws_path_replay}/${file_in} ${file_out} 
done

if [[ ${model} == 'ICE' ]]; then
    ${SCRIPT_DIR}/CICE_ic_edit.py -f ${file_out}
    echo "MOVING ${file_out%.nc}_new.nc" "${file_out}"
    mv "${file_out%.nc}_new.nc" "${file_out}"
    mask_file=$(dirname ${file_out})/tmask_mx025.nc
    [[ -f ${mask_file} ]] && rm ${mask_file}
fi

if [[ ${model} == 'MED' ]]; then
echo "EDITING MEDIATOR restart in ${dir}"
    file=${dir}/${file_out}
    dev_file=$(readlink -f "${IC_DIR}/../ufs.cpld.cpl.r.DEV.nc")
    if [[ ! -f ${dev_file} ]]; then
        echo "GRABBING ${dev_file} from HPSS"
        HPSS_DIR="/NCEPDEV/emc-marine/2year/Neil.Barton/REPLAY_ICS/${ATMRES}${OCNRES}"
        HPSS_FILE=${HPSS_DIR}/$(basename ${dev_file})
        hsi -q get ${dev_file} : ${HPSS_FILE}
        if [[ ! -f ${dev_file} ]]; then
            echo "FATAL: failed to download ${HPSS_FILE} to"
            echo "       ${dev_file}"
            exit 1
        fi
    fi
    python ${SCRIPT_DIR}/MED_replay2dev.py -r ${file} -d ${dev_file}
    if (( $? > 0 )); then
        echo "FAIL Med_replay2dev.py"
        exit 1
    fi
    new_file=${dir}/DEV_MEDFILE.nc
    mv ${new_file} ${file}
    echo "mediator file updated"
fi

echo "SUCCESSFULLY Downloaded ${model}"
exit 0


