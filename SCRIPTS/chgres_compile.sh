#!/bin/sh
set -xu
# compiles chgres program
SCRIPT_DIR=$(dirname "$0")/SCRIPTS
dtg=2017100100 # dummy variable
source ${SCRIPT_DIR}/defaults.sh
CODE=https://github.com/ufs-community/UFS_UTILS.git
HASH=develop
export compiler=${chgres_compiler}

export target=${m_target}
build_file=${CODE_DIR}/UFS_UTILS/modulefiles/build.${target}.${compiler}.lua
sed -i 's/--sfcio_ver/sfcio_ver/' ${build_file}
sed -i 's/--load(pathJoin("sfcio"/load(pathJoin("sfcio"/' ${build_file}
mkdir -p ${CODE_DIR} && cd ${CODE_DIR}

git clone ${CODE}
cd ${CODE_DIR}/UFS_UTILS
git checkout ${HASH}

# fix files
cd ${CODE_DIR}/UFS_UTILS/fix
bash link_fixdirs.sh emc ${m_target}

# compile
cd ${CODE_DIR}/UFS_UTILS
export CMAKE_OPTS="-DCHGRES_ALL=ON"
export sfcio_ver=1.4.2
bash build_all.sh
if (( ${?} != 0 )); then
    echo 'COMPILE failed'
    exit 1
fi

