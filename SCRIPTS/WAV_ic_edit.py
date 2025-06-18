#!/usr/bin/env python3 
import argparse
import numpy as np
import os
import shutil
import sys
import xarray as xr

################################################
parser = argparse.ArgumentParser( description = "Edits the WAVE IC's Header")
parser.add_argument('-f', '--file', action = 'store', nargs = 1, \
        default=['/gpfs/f6/sfs-emc/scratch/Neil.Barton/ICs/REPLAY/C192mx025/sfs.19940430/18/mem000/model/wave/restart/19940501.000000.restart.glo_025'], \
        help="top directory to find model output files")

args = parser.parse_args()
# Open and over-write header
file = args.file[0]
print('EDITING', file)
with open(file, 'rb') as f:
    dat = bytearray(f.read())
i=26
dat[i:i+10] = b'2024-04-26'

# Write new binary file
file = file + '_newheader'
with open(file, 'wb') as f:
    f.write(dat)
print('WROTE', file)


