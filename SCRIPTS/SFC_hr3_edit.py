#!/usr/bin/env python3 
################################################
# edits surface restarts for FV3 due to 
# mismatch in grids from replay to current branch
################################################
import argparse
from matplotlib import pyplot as plt
import numpy as np
import os
import sys
import xarray as xr

################################################
parser = argparse.ArgumentParser( description = "Edits Surfaces Files do to Differences in Grid between Replay and Develop Branch")
parser.add_argument('-f', '--files', action = 'store', nargs = 6, \
        help="surface files to edit")
parser.add_argument('-c', '--canopy', action = 'store_true', \
        help="only edit canpoy")
parser.add_argument('-dtg', '--dtg', action = 'store', nargs = 1, \
        help="date of surface files")
parser.add_argument('-s', '--static', action = 'store', nargs = 1, \
        help="land static file")
parser.add_argument('-ld', '--landdirectory', action = 'store', nargs = 1, \
        help="land static file")

args = parser.parse_args()
files = args.files
canopy = args.canopy
if not canopy:
    dtg = args.dtg[0]
    static_file = args.static[0]
    land_dir = args.landdirectory[0]

# open SFC data
ds_rs = xr.open_mfdataset(files, combine='nested', concat_dim='tile')

ntiles = len(files)
nx = int(ds_rs.coords['xaxis_1'].max().values)
ny = int(ds_rs.coords['yaxis_1'].max().values)
nlevs = int(ds_rs.coords['zaxis_1'].max().values)
data_dir = files[0].split('/sfc_data')[0]

if not canopy:
    # open new EC data
    land_file = land_dir + '/ufs_land_restart.' + dtg[0:4] + '-' + dtg[4:6] + '-01_03-00-00.nc'
    ds_su = xr.open_dataset(land_file)
    ds_stat = xr.open_dataset(static_file)
    land = np.array(  nx*ny*(ds_stat['cube_tile'][:].values-1) \
                + nx*(ds_stat['cube_j'][:].values-1) \
                + ds_stat['cube_i'][:].values -1).astype(int)

    var_mapping={\
    'snow_water_equiv':'sheleg',\
    'soil_moisture_vol':'smc',\
    'soil_liquid_vol':'slc',\
    'temperature_soil':'stc',\
    'snow_depth':'snwdph'}
    ds_su = ds_su.rename(var_mapping)
    for v in ds_rs.variables.keys():
        print(v)
        print(ds_rs[v])

    #for var in ['sheleg','snwdph']:
    #    tmp = ds_rs[var][:,0].values.ravel()
    #    tmp2 = ds_su[var][0,:].values
    #    tmp[land] = tmp2
    #    tmp3 = np.reshape(tmp,[ntiles,1,ny,nx])
    #    ds_rs[var][:] = tmp3
    #    #del ds_rs[var].attrs['checksum']

    for var in ['smc','slc','stc']:
        for lev in np.arange(1,nlevs):
            tmp = ds_rs[var][:,0,lev].values.ravel()
            tmp2 = ds_su[var][0,lev,:].values
            tmp[land]=tmp2
            tmp3=np.reshape(tmp,[ntiles,1,ny,nx])
            ds_rs[var][:,:,lev]=tmp3
        #del ds_rs[var].attrs['checksum']
    ds_su.close()

# change canopy value
var = 'canopy' 
dat = ds_rs[var].values
dat[dat > 0.5] = 0.5
ds_rs[var] = (ds_rs[var].dims, dat)
ds_rs.assign_attrs({'File Edited' : 'canopy values reset to 0.5'})

for tile in np.arange(1,ntiles+1):
    ds_out=ds_rs.isel(tile=tile-1)
    f = data_dir + '/sfc_data.tile' + str(tile) + '.nc'
    os.remove(f)
    #os.rename(f, data_dir + '/ORIG_sfc_data.tile' + str(tile) + '.nc')
    print("saving: ", f)
    ds_out.to_netcdf(f)
    ds_out.close()

