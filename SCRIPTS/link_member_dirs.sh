#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${IC_DIR}/${dtg}/ && cd ${dir}/mem000

models=$( ls -d */ )
for i in $(seq 1 ${NENS}); do
    mem=$(printf "%03d" ${i})
    out_dir=${IC_DIR}/${dtg}/mem${mem}
    for model in ${models}; do
        dir=${out_dir}/${model} 
        mkdir -p ${dir} && cd ${dir}
        files=$( ls ../../mem000/${model}* )
        for f in ${files}; do
            ln -sf ../../mem000/${model}${f} .
        done
    done
done

cd ${IC_DIR}/${dtg}
current_time=$(date)
cat <<EOF > README
RESOLUTION: ${ATMRES}${OCNRES}
REPLAY ICS are valid at 03Z
The file folders are at 00Z to run in g-w
Files Created on ${current_time}
EOF

