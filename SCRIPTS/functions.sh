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
    echo "wget ${file_in} -O ${file_out}"
else
    echo "${file_out} already exist"
fi
}

GLOBUS_AWS () {
file_in=${1}
file_out=${2}
if [[ ! -f ${file_out} ]]; then
    ID=$( globus transfer ${UUID_AWS_S3_PUBLIC}\://${file_in} \
        ${UUID_HERA_DTN}\:${file_out} | \
        tail -n 1 | \
        awk '{print $3}' )
    (( ${#ID} != 36 )) && ID=9999
    echo ${ID}
fi
}

FIND_EMPTY_FILES () {
dir_in=${1}
n_empty=$( find ${dir_in} -type f -size -17k | grep -v ca_data | grep -v coupler.res | wc -l )
if (( ${n_empty} >> 0 )); then
    echo "Failed: empty files found"
    files=$( find ${dir_in} -type f -size -17k | grep -v ca_data | grep -v coupler.res )
    for f in ${files}; do
        echo "  removing:  "${f}
        rm ${f}
    done
    #find ${dir_in} -type f -size 0 -delete
    exit 1
fi
}
