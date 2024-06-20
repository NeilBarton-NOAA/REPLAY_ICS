#!/bin/sh
set -xu
WGET_AWS () {
file_in=${1}
file_out=${2}
if [[ ! -s ${file_out} ]]; then
    rm ${file_out}
fi
if [[ ! -f ${file_out} ]]; then
    wget ${file_in} -O ${file_out} 
else
    echo "${file_out} already exist"
fi
}

FIND_EMPTY_FILES () {
dir_in=${1}
n_empty=$( find ${dir_in} -size 0 | grep -v ca_data.nc | wc -l )
if (( ${n_empty} >> 0 )); then
    echo "Failed: empty files found"
    files=$( find ${dir_in} -size 0 | grep -v ca_data.nc )
    echo "  removing:  "${files}
    find ${dir_in} -type f -size 0 -delete
    exit 1
fi
}
