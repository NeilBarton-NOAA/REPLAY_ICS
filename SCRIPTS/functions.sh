#!/bin/sh
set -xu
WGET_AWS () {
file_in=${1}
file_out=${2}
if [[ ! -f ${file_out} ]]; then
    wget ${file_in} -O ${file_out} 
else
    echo "${file_out} already exist"
fi
}

