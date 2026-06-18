#!/bin/bash
set -u

dtg=2026061800
dir_nrt="/lfs/h2/emc/gfstemp/emc.global/comroot/retrov17_01_realtime"
SCRIPT_DIR=${PWD}/SCRIPTS
main(){
source ${SCRIPT_DIR}/defaults.sh
############
# put check for files, exit if not there, add one month
############
# FV3 Restarts
# submit changres and sfc
############
# CICE Restarts
FIND_AND_COPY "${restart_tile_files_atmos}"
exit 1
FIND_AND_COPY "analysis.cice_model.res"
FIND_AND_COPY "${restart_files_ocean}"
############
# inc files, MOM6, sfc, atm
############
# wait for chngres to be finished and submit htar
}

FIND_AND_COPY(){
local restart_files=${1}
for rf in ${restart_files}; do
    echo ${rf}, ${dtg}, ${DTG_TEXT_MINUS3}
    files=$( find ${dir_nrt} -name ${DTG_TEXT_MINUS3}.${rf}*.nc | sort )
    for f in ${files}; do
        RENAME_COPY ${f}
    done
done

}

RENAME_COPY() {
    local f=${1}
    local nf=${f}
    nf="${nf//enkfgdas/sfs}"
    nf="${nf//gdas/sfs}"
    nf="${nf//${dir_nrt}/${WORK_DIR}/ICs/GFS/C192mx025}"
    if [[ ! ${nf} == *"mem"* ]]; then
        nf=$(echo "${nf}" | sed 's|\(/[0-9][0-9]/\)|\1mem000/|')
    fi
    if [[ ${nf} == *"increment.atm."* ]]; then
        # Extract the number
        num=$(echo "${nf}" | grep -oP '(?<=\.i)\d+(?=\.nc)')
        # Calculate new number
        new_num=$(echo "${num} - 3" | bc)
        # Replace in string
        nf=$(printf "${nf/.i${num}.nc/.i%03d.nc}" "${new_num}")
    fi
    f2=${nf}
    ############
    # COPY
    mem=$( echo ${f2} | grep -oP '(?<=mem)\d+' )
    if (( 10#${mem} < 31 )) && [[ ${f2} != *gfs* ]] && [[ ! -f ${f2} ]]; then
        mkdir -p $(dirname ${f2})
        cp ${f} ${f2} 
        echo "COPIED: ${f2}"
    fi
}

main
