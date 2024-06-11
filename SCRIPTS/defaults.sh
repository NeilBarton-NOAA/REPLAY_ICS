set -xu
SCRIPT_DIR=${SCRIPT_DIR:-$PWD}

############
# number of ensembles
dow=$(date -d "${dtg:0:8}" +%A)
if [[ ${dow} == "Thursday" ]] || [[ ${dow} == "Monday" ]]; then
    NENS=10
else
    NENS=5
fi
############
# time stamp for files
DTG_TEXT=${dtg:0:8}.030000 # restarts valid at 

############
# top IC directory
IC_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/REPLAY_ICs/${ATMRES}${OCNRES}
if [[ ${C96_REPLAY} == "True" ]]; then
    IC_DIR=${IC_DIR}_C96REPLAY
fi
mkdir -p ${IC_DIR}

############
# Replay Restarts
# https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/index.html
aws_path="https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/${dtg:0:4}/${dtg:4:2}/${dtg:0:8}06"



########################
# CODE Directory
CODE_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/CODE/REPLAY

########################
# compiler used for chgres
export chgres_compiler=gnu
export APRUN="srun -n 6"

