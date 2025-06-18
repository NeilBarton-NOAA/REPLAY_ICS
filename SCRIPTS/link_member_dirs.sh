#!/bin/bash
set -xu
dtg=${1}
SCRIPT_DIR=${SCRIPT_DIR:-$(dirname "$0")}
source ${SCRIPT_DIR}/defaults.sh

LINK_MEMBERS () {
dir=${1}
NENS=${2}
if [[ ${LAND_VER} == HR4 ]]; then
    mem000_dir="../../../../mem${dir##*mem}"
else
    mem000_dir="../../mem${dir##*mem}"
fi 
for i in $(seq 1 ${NENS}); do
    mem=$(printf "%03d" ${i})   
    dir_mem=${dir/mem000/mem${mem}} 
    mkdir -p ${dir_mem} && cd ${dir_mem}
    echo $dir_mem
    files=$( ls ${mem000_dir}/* )
    for f in ${files}; do
        ln -sf ${mem000_dir}/$(basename ${f}) .
    done
done
}

[[ -d ${dir_atmos} ]] && LINK_MEMBERS ${dir_atmos} ${NENS}
[[ -d ${dir_ocean} ]] && LINK_MEMBERS ${dir_ocean} ${NENS}
[[ -d ${dir_ice} ]] && LINK_MEMBERS ${dir_ice} ${NENS}
[[ -d ${dir_wave} ]] && LINK_MEMBERS ${dir_wave} ${NENS}
[[ -d ${dir_med} ]] && LINK_MEMBERS ${dir_med} ${NENS}

echo "Linked ICs to member directories"
