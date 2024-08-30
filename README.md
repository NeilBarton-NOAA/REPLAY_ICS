# REPLAY_ICS
Scripts to Process Replay ICs for GEFS/SFS

DEPENDENCIES:
    cylc, python3 (matplotlib, xesmf, xarray, others), nco

USE of CYCL:
    if this is the first time using cylc, you'll likely need to add a
    ~/.cylc/flow/global.cylc
    examine and copy ~${BARTON_HOME}/.cylc/flow/global.cylc
    set a variable called CYLC_WORKDIR to a scratch directory (this is where cylc does work)

MODULES FOR DEPENDENCIES:
    Must load on command line!
        module use -a ~${BARTON_HOME}/TOOLS/modulefiles
        module conda 
    Other modules loaded in Scripts

TO RUN:
    open flow.cylc and edit top parameters if needed
        e.g.: MAIL_ADDRESS
    validate suite
        cylc va ${DIRECTORY_OF_FLOW_FILE}
    run suite
        cylc vip -n ${NAME} ${DIRECTORY_OF_FLOW_FILE}
    check to see what is running
        cylc tui $NAME 

OTHER USEFUL CYLC COMMANDS:
    cylc stop -k $NAME (shutdown and kill all tasks associated with the suite)
    cylc clean $NAME (if changes are made in the .rc file, the suite most be validated and reloaded for these changes to take effect)
    cylc trigger ${ID} (retrigger task)
    *note* use cylc --help !!!
