#!/bin/sh
set -xu
# compiles chgres program
SCRIPT_DIR=$(dirname "$0")
dtg=2017100100 # dummy variable
source ${SCRIPT_DIR}/defaults.sh
CODE=https://github.com/DeniseWorthen/UFS_UTILS.git
HASH=feature/ocnprep
export compiler=${chgres_compiler}
export target=hera
mkdir -p ${CODE_DIR} && cd ${CODE_DIR}

git clone ${CODE} 
cd ${CODE_DIR}/UFS_UTILS
git checkout ${HASH}
#git submodule update --init --recursive

# fix files
cd ${CODE_DIR}/UFS_UTILS/fix
bash link_fixdirs.sh emc hera

# compile
cd ${CODE_DIR}/UFS_UTILS
echo 'Remove machine setup call'
#exit 1
#sed -i /"module purge"/d ${CODE_DIR}/UFS_UTILS/sorc/machine-setup.sh
module purge
bash build_all.sh
if (( ${?} != 0 )); then
    echo 'COMPILE failed'
    exit 1
fi

