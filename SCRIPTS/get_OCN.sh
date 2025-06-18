#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_ocean}
mkdir -p ${dir} && cd ${dir}
echo "DOWNLOADING MOM6 data to ${dir}"
if [[ ${GLOBUS} == T ]]; then
    IDS=""
    ID=$( GLOBUS_AWS ${aws_path}/MOM.res.nc ${dir}/${DTG_TEXT}.MOM.res.nc )
    [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed: ${dir}/${DTG_TEXT}.MOM.res.nc" && RETRY="YES"
    [[ ${ID} != 9999 ]] && IDS="${IDS} ${ID}"
else
    WGET_AWS ${aws_path}/MOM.res.nc ${DTG_TEXT}.MOM.res.nc
fi

for i in $(seq 1 3); do
    file_in=MOM.res_${i}.nc 
    file_out=${DTG_TEXT}.MOM.res_${i}.nc
    if [[ ${GLOBUS} == T ]]; then    
        ID=$( GLOBUS_AWS ${aws_path}/${file_in} ${dir}/${file_out} )
        [[ ${ID} == 9999 ]] && echo "FATAL: globus submit failed: ${dir}/${file_out}" && RETRY="YES"
        [[ ${ID} != 9999 ]] && IDS="${IDS} ${ID}"
    else
        WGET_AWS ${aws_path}/MOM.res_${i}.nc ${DTG_TEXT}.MOM.res_${i}.nc
    fi
done

if [[ ${GLOBUS} == T ]]; then    
    for ID in ${IDS}; do
        globus task wait ${ID}
    done
    [[ ${RETRY:-"NO"} == "YES" ]] && exit 1
fi

FIND_EMPTY_FILES ${PWD}

