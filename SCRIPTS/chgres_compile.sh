#!/bin/sh
set -xu
# compiles chgres program
SCRIPT_DIR=$(dirname "$0")
dtg=2017100100
source ${SCRIPT_DIR}/defaults.sh
CODE=https://github.com/DeniseWorthen/UFS_UTILS.git
HASH=feature/ocnprep
export compiler=gnu

mkdir -p ${CODE_DIR} && cd ${CODE_DIR}

git clone ${CODE} 
cd ${CODE_DIR}/UFS_UTILS
git checkout ${HASH}
git submodule update --init --recursive
cd ${CODE_DIR}/UFS_UTILS/fix
bash link_fixdirs.sh emc hera
cd ${CODE_DIR}/UFS_UTILS
bash build_all.sh
