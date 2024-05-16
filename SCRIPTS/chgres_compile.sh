#!/bin/sh
set -xu
# compiles chgres program
SCRIPT_DIR=$(dirname "$0")
CODE=https://github.com/DeniseWorthen/UFS_UTILS.git
HASH=feature/ocnprep

git clone ${CODE} 
cd ${SCRIPT_DIR}/UFS_UTILS
git checkout ${HASH}
git submodule update --init --recursive
cd ${SCRIPT_DIR}/UFS_UTILS/fix
bash link_fixdirs.sh emc hera
cd ${SCRIPT_DIR}/UFS_UTILS
bash build_all.sh
