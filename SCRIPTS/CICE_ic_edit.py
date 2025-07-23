#!/usr/bin/env python3 
####################################################################################
# from Dave Bailey: What is likely happening is that you are initializing with the 
#                   same thickness in two categories where thickness is vicen / aicen.
#ncks -A kmtu_cice_NEMS_mx025.nc cice_model.res.nc
#ncap2 -s where(kmt==0) aicen=0.0 cice_model.res.nc
#ncap2 -s where(kmt==0) vicen=0.0 cice_model.res.nc
#ncap2 -s where(kmt==0) vsnon=0.0 cice_model.res.nc
#ncap2 -s where(kmt==0) Tsfcn=0.0 cice_model.res.nc
#ncap2 -s 'where(aicen.total($ncat) == 0) vicen=0' cice_model.res.fix.nc cice_model.res.fix2.nc
#ncap2 -s 'where(aicen.total($ncat) == 0) vsnon=0' cice_model.res.fix2.nc cice_model.res.fix3.nc
####################################################################################
import argparse
import os
import requests
import xarray as xr

################################################
# parser for file
parser = argparse.ArgumentParser( description = "Looks for Errors in CICE restart file")
parser.add_argument('-f', '--file', action = 'store', nargs = 1, \
        help="cice file to edit")
args = parser.parse_args()
infile = args.file[0]
print(infile)
ds_res = xr.open_dataset(infile)
sic = ds_res['aicen'].sum(axis = 0)
#from matplotlib import pyplot as plt
#plt.imshow(sic, origin = 'lower'); plt.colorbar(); plt.show()

############
# remove ice variables over land
mask_file = 'tmask_mx025.nc'
if not os.path.exists(mask_file):
    print('mask file not found, wget from github')
    raw_url='https://raw.githubusercontent.com/NeilBarton-NOAA/REPLAY_ICS/main/SCRIPTS/' + mask_file
    response = requests.get(raw_url)
    with open(mask_file, 'wb') as f:
        f.write(response.content)
ds_mask = xr.open_dataset(mask_file)
mask = ds_mask['tmask']
mask = mask.broadcast_like(ds_res['aicen'])

print('Checking for ice values over land points')
vs = ['aicen', 'vicen', 'vsnon', 'Tsfcn']
for v in vs:
    test = ds_res[v].where(mask == 0)
    if test.max().values != 0 or test.min().values != 0:
        print(' ', v, 'has non zero values over land, setting these values to zero')
    ds_res[v] = ds_res[v].where(mask != 0, 0)

############
# remove ice and snow where there is no ice
vs = ['vicen', 'vsnon']
sic = sic.broadcast_like(ds_res['aicen'])
print('Checking for ice values at grid points of aicen.sum() values of zero')
for v  in vs:
    test = ds_res[v].where(sic == 0)
    if test.max().values != 0 or test.min().values != 0:
        print(' ', v, 'has non zero values, setting these values to zero')
    ds_res[v] = ds_res[v].where(sic != 0, 0)

#########################
# save file
new_file = infile.split('.nc')[0] + '_new.nc'
if os.path.exists(new_file):
    os.remove(new_file)
ds_res.to_netcdf(new_file)
print('SAVED: ' + new_file)

