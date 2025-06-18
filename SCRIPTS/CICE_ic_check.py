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
import numpy as np
import os
import shutil
import sys
import xarray as xr

################################################
parser = argparse.ArgumentParser( description = "Looks for Errors in CICE restart file")
parser.add_argument('-f', '--file', action = 'store', nargs = 1, \
        default=['/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/2017100503/iced.2017-10-05-10800.nc'], \
        help="top directory to find model output files")
args = parser.parse_args()
infile = args.file[0]

dat = xr.open_dataset(infile)
print(infile)

########################
# get variables to zero out when ice is removed

exit(1)
cat_vars = []
for var in dat.variables:
    if (var != 'aicen') and (dat['aicen'].size == dat[var].size):
        cat_vars.append(var)

########################
# sea ice thickness method
if method == 'thickness':
    print('Sea Ice Thickness Method:', limit)
    limit_sic = 0.15
    v_max = 0.15
    new_file = dir_f + '/newIC_THICKNESSDIFF_' + str(limit) + '_ICE_' + str(limit_sic) + '_' + name_f
    title = 'Sea Ice Differences: Thickness Threshold: ' + str(limit) + '\n' + name_f 
    fig_name = 'IC_edit_ICE_THICKNESS_threshold_' + str(limit) + '.png'
    # hin (thickness) = vicen (volume) /aicen (area/fraction).
    dat['hin'] = (dat['vicen'].dims, 
        np.divide(dat['vicen'].values, dat['aicen'].values, \
        out = np.zeros_like(dat['vicen'].values), where = dat['aicen'].values != 0))
    t_hin = dat['hin'].sel(ncat = dat['ncat'].values[0:-1]).values.copy()
    b_hin = dat['hin'].sel(ncat = dat['ncat'].values[1::]).values.copy()
    dat['diff'] = (('cat',) + dat['aicen'].dims[1::], np.abs(t_hin - b_hin).copy())
    dat['aicen_orig']  = (dat['aicen'].dims, dat['aicen'].values.copy())
    for c, cat in enumerate(dat['cat'].values):
        dat['aicen'][c,:,:] = np.where(((dat['diff'][c,:,:] < limit) & (dat['aicen'][c,:,:] < limit_sic)), \
            0.0, dat['aicen'][c,:,:])
        dat['aicen'][c+1,:,:] = np.where(((dat['diff'][c,:,:] < limit) & (dat['aicen'][c+1,:,:] < limit_sic)), \
            0.0, dat['aicen'][c+1,:,:])
        for var in cat_vars:
            dat[var][c,:,:] = np.where(((dat['diff'][c,:,:] < limit) & (dat['aicen'][c,:,:] < limit_sic)), \
                0.0, dat[var][c,:,:])
            dat[var][c+1,:,:] = np.where(((dat['diff'][c,:,:] < limit) & (dat['aicen'][c+1,:,:] < limit_sic)), \
                0.0, dat[var][c+1,:,:])

########################
# sea ice edge method 
if method == 'edgesic':
    v_max = limit
    new_file = dir_f + '/newIC_EDGE_SIC' + str(limit) + '_' + name_f
    title = 'Sea Ice Differences: Edge and SIC Threshold: ' + str(limit) + '\n' + name_f 
    fig_name = 'IC_edit_EDGE_ICE_SIC_threshold_' + str(limit) + '.png'
    print('Sea Ice Edge and SIC Method:', limit)
    dat['aicen_orig']  = (dat['aicen'].dims, dat['aicen'].values.copy())
    sic = dat['aicen'].sum(axis = 0)
    edge_limit = 0.15
    for c, cat in enumerate(dat['ncat'].values):
        d = dat['aicen'][c].values.copy()
        d[(sic < edge_limit) & (d < limit)] = 0.0
        dat['aicen'][c,:,:] = d
        for var in cat_vars:
            v = dat[var][c].values.copy()
            v[(sic < edge_limit) & (d < limit)] = 0.0
            dat[var][c,:,:] = v

########################
# sea ice edge method 
if method == 'edgethickness':
    new_file = dir_f + '/newIC_EDGE_Thickness' + str(limit) + '_' + name_f
    title = 'Sea Ice Differences: Edge and Thickness Threshold: ' + str(limit) + '\n' + name_f 
    fig_name = 'IC_edit_EDGE_ICE_THICKNESS_threshold_' + str(limit) + '.png'
    print('Sea Ice Edge and Thickness Method:', limit)
    dat['aicen_orig']  = (dat['aicen'].dims, dat['aicen'].values.copy())
    dat['hin'] = (dat['vicen'].dims, 
        np.divide(dat['vicen'].values, dat['aicen'].values, \
        out = np.zeros_like(dat['vicen'].values), where = dat['aicen'].values != 0))
    t_hin = dat['hin'].sel(ncat = dat['ncat'].values[0:-1]).values.copy()
    b_hin = dat['hin'].sel(ncat = dat['ncat'].values[1::]).values.copy()
    dat['diff'] = (('cat',) + dat['aicen'].dims[1::], np.abs(t_hin - b_hin).copy())
    sic = dat['aicen'].sum(axis = 0)
    edge_limit = 0.15
    v_max = edge_limit
    for c, cat in enumerate(dat['cat'].values):
        diff = dat['diff'][c].values.copy()
        d = dat['aicen'][c].values.copy()
        d[(sic < edge_limit) & ( diff < limit)] = 0.0
        dat['aicen'][c] = d
        d = dat['aicen'][c+1].values.copy()
        d[(sic < edge_limit) & ( diff < limit)] = 0.0
        dat['aicen'][c+1] = d
        for var in cat_vars:
            d = dat[var][c].values.copy()
            d[(sic < edge_limit) & ( diff < limit)] = 0.0
            dat[var][c] = d
            d = dat[var][c+1].values.copy()
            d[(sic < edge_limit) & ( diff < limit)] = 0.0
            dat[var][c+1] = d

########################
# sea ice edge method 
if method == 'edge':
    v_max = limit
    new_file = dir_f + '/newIC_EDGE_' + str(limit) + '_' + name_f
    title = 'Sea Ice Differences: Edge Threshold: ' + str(limit) + '\n' + name_f 
    fig_name = 'IC_edit_EDGE_ICE_threshold_' + str(limit) + '.png'
    print('Sea Ice Edge Method:', limit)
    dat['aicen_orig']  = (dat['aicen'].dims, dat['aicen'].values.copy())
    sic = dat['aicen'].sum(axis = 0)
    for c, cat in enumerate(dat['ncat'].values):
        dat['aicen'][c,:,:] = np.where(sic > limit, dat['aicen'][c,:,:], 0.0)
        for var in cat_vars:
            dat[var][c,:,:] = np.where(sic > limit, dat[var][c,:,:], 0.0)

########################
# blunt method to remove sea ice concentrations of a value
if method == 'sic':
    v_max = limit
    print('Sea Ice Concentrations:', limit)
    new_file = dir_f + '/newIC_' + str(limit) + '_' + name_f
    title = 'Sea Ice Differences: Ice Threshold: ' + str(limit) + '\n' + name_f 
    fig_name = 'IC_edit_ICE_threshold_' + str(limit) + '.png'
    for var in cat_vars:
        dat[var][:] = np.where(dat['aicen'].values > limit, dat[var], 0.0)
    dat['aicen_orig']  = (dat['aicen'].dims, dat['aicen'].values.copy())
    dat['aicen'][:] = np.where(dat['aicen'].values > limit, dat['aicen'], 0.0)

#########################
# save file
if os.path.exists(new_file):
    os.remove(new_file)
dat.to_netcdf(new_file)
print('SAVED: ' + new_file)

########################
# plot differences in data
if plot:
    print("Plotting only works on hear")
    import cartopy.crs as ccrs
    import matplotlib.pyplot as plt
    sys.path.append('/home/Neil.Barton/TOOLS')
    import PYTHON_TOOLS as npb
    fig = plt.figure()
    ax1 = fig.add_subplot(2,2,1, projection=ccrs.NorthPolarStereo())
    ax1 = npb.base_maps.Arctic(ax1, labels = False)
    ax1 = npb.base_maps.add_features(ax1)
    ax2 = fig.add_subplot(2,2,2, projection=ccrs.SouthPolarStereo())
    ax2 = npb.base_maps.Antarctic(ax2, labels = False)
    ax2 = npb.base_maps.add_features(ax2)
    ax3 = fig.add_subplot(2,2,3, projection=ccrs.NorthPolarStereo())
    ax3 = npb.base_maps.Arctic(ax3, labels = False)
    ax3 = npb.base_maps.add_features(ax3)
    ax4 = fig.add_subplot(2,2,4, projection=ccrs.SouthPolarStereo())
    ax4 = npb.base_maps.Antarctic(ax4, labels = False)
    ax4 = npb.base_maps.add_features(ax4)
    cmap = plt.get_cmap('Blues')
    mask_orig = dat['aicen_orig'].sum(axis = 0)
    mask = dat['aicen'].sum(axis=0)
    area = xr.open_dataset(os.environ['NPB_WORKDIR'] + '/ICs/cice_area.nc') # need lat/lons
    # total concentration difference
    d = mask_orig - mask
    print(np.min(d).values, np.max(d).values)
    cf = ax1.pcolormesh(area['TLON'].values, area['TLAT'].values, d, cmap = cmap, \
        vmin = 0, vmax = v_max, transform = ccrs.PlateCarree())
    cf = ax2.pcolormesh(area['TLON'].values, area['TLAT'].values, d, cmap = cmap, \
        vmin = 0, vmax = v_max, transform = ccrs.PlateCarree())
    ax1.text(270, 50, 'Ice Concentration', rotation = 'vertical', \
        ha = 'center', va = 'center', transform = ccrs.PlateCarree())
    # ice edge diference
    #v_min = -1
    #v_max = 1
    d = np.where(mask_orig > 0.15, 1.0, 0.0) - np.where(mask > 0.15, 1.0, 0.0)
    print(np.min(d), np.max(d))
    cf = ax3.pcolormesh(area['TLON'].values, area['TLAT'].values, d, cmap = cmap, \
        vmin = 0, vmax = v_max, transform = ccrs.PlateCarree())
    cf = ax4.pcolormesh(area['TLON'].values, area['TLAT'].values, d, cmap = cmap, \
        vmin = 0, vmax = v_max, transform = ccrs.PlateCarree())
    ax3.text(270, 50, 'Ice Mask', rotation = 'vertical', \
        ha = 'center', va = 'center', transform = ccrs.PlateCarree())
    # colorbar
    cax = fig.add_axes([0.22, 0.05, 0.6, 0.03])
    fig.colorbar(cf, cax = cax, orientation = 'horizontal')
    # title and save
    fig.suptitle(title, y = 0.95)
    plt.savefig(fig_name, dpi = 600)
    print('SAVED: ', fig_name)
    plt.show()
    plt.close()

