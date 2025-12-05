#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_atmos}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING FV3 data to ${dir}"
# surface files for C192, https://noaa-oar-sfsdev-pds.s3.amazonaws.com/index.html#input/c192/hr4_land/1994050106/ 

files='ca_data fv_core.res fv_srf_wnd.res fv_tracer.res phy_data sfc_data'
IDS=""
for f in ${files}; do
    for tile in $(seq 1 6); do
        file_in=${f}.tile${tile}.nc 
        file_out=${DTG_TEXT}.${f}.tile${tile}.nc
        if [[ ${SCOUT_RUN} == "True" ]]; then
            f_in=${aws_path}/model/atmos/restart/${DTG_TEXT}.${file_in}  
        elif [[ ${f} == "sfc_data" ]] && (( ${DTG} < 2024010100 )); then
            lower_case=$( echo ${LAND_VER} | tr '[:upper:]' '[:lower:]')
            f_in=${aws_path}/${lower_case}_land/${file_in}  
        else
            f_in=${aws_path}/${file_in} 
        fi
        if [[ ${GLOBUS} == T ]]; then
            ID=$( GLOBUS_AWS ${f_in} ${dir}/${file_out} )
            [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed: ${dir}/${file_out}" && RETRY="YES"
            [[ ${ID} != 9999 ]] && IDS="${IDS} ${ID}"
        else
            WGET_AWS ${f_in} ${file_out} 
        fi
   done
done

files='ca_data fv_core.res'
for f in ${files}; do
    if [[ ${SCOUT_RUN} == "True" ]]; then
        f_in=${aws_path}/model/atmos/restart/${DTG_TEXT}.${f}.nc  
    else
        f_in=${aws_path}/${f}.nc
    fi
    file_out=${DTG_TEXT}.${f}.nc
    if [[ ${GLOBUS} == T ]]; then
        ID=$( GLOBUS_AWS ${aws_path}/${file_in} ${dir}/${file_out} )
        [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed: ${dir}/${file_out}" && RETRY="YES"
        [[ ${ID} != 9999 ]] && IDS="${IDS} ${ID}"
    else
        WGET_AWS ${f_in} ${file_out} 
    fi
done

# wait for the downloads to finish
if [[ ${GLOBUS} == T ]]; then
    for ID in ${IDS}; do
        globus task wait ${ID}
    done
    [[ ${RETRY:-"NO"} == "YES" ]] && exit 1
fi
# remove checksum from sfc_data files
for tile in $(seq 1 6); do
    file_out=${DTG_TEXT}.sfc_data.tile${tile}.nc
    ncatted -a checksum,,d,, ${file_out}
done

FIND_EMPTY_FILES ${PWD}

if [[ ${ATMRES} == "C384" ]]; then
    touch ${DTG_TEXT}.coupler.res
fi
