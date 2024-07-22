#!/bin/sh
set -xu
# compiles chgres program
SCRIPT_DIR=$(dirname "$0")/SCRIPTS
dtg=2017100100 # dummy variable
ATMRES=DUMMY
OCNRES=DUMMY
source ${SCRIPT_DIR}/defaults.sh
CODE=https://github.com/ufs-community/UFS_UTILS.git
HASH=develop
export compiler=${chgres_compiler}
export target=hera
mkdir -p ${CODE_DIR} && cd ${CODE_DIR}

git clone ${CODE} 
cd ${CODE_DIR}/UFS_UTILS
git checkout ${HASH}

# fix files
cd ${CODE_DIR}/UFS_UTILS/fix
bash link_fixdirs.sh emc hera

# compile
cd ${CODE_DIR}/UFS_UTILS
bash build_all.sh
if (( ${?} != 0 )); then
    echo 'COMPILE failed'
    exit 1
fi

