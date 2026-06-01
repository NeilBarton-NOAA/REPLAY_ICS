#!/bin/bash
set -u
# Get ICs for GFS or CPC
dtg=${1:-2026030100}
export IC_SRC=${2:-DA_UPDATE}
export TOPDIR=${PWD}
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
source ${TOPDIR}/MACHINE/config.sh
source ${TOPDIR}/SCRIPTS/defaults.sh

####################################
SRC_DIR=${IC_DIR/${IC_SRC}/GFS}
echo ${IC_DIR}
ds="${run}.${dtg_minus6:0:8} ${run}.${dtg:0:8}"
for d in ${ds}; do
    SRC=${SRC_DIR}/${d}
    DES=${IC_DIR}/${d} 
    mkdir -p ${DES}
    cd ${SRC}
    echo $PWD
    find . -type d -exec mkdir -p "${DES}/{}" \;
    files=$(find . -type f | grep -v cice | grep -v MOM | grep -v mom) 
    for f in ${files}; do
        src_file=${SRC}/${f}
        des_file=${DES}/${f}
        echo "ln -sf"
        echo "  ${src_file}"
        echo "  ${des_file}"
        cd $(dirname ${des_file})
        ln -sf ${src_file} $(basename $f)
    done 
done

