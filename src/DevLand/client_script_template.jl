using GitWorkers

## ---------------------------------------------------------------
# cmd for run the server
# julia 'SERVER_SCRIPT_PATH'

## ---------------------------------------------------------------
# run to reset all
# gw_create_devland(;
#     sys_root = "SYSTEM_ROOT",
#     clear_repos = true, 
#     clear_scripts = false,
#     verbose = false,
#     deb = false,
# )

## ---------------------------------------------------------------
gw_setup(;
    sys_root = "CLIENT_ROOT",
    url = "REMOTE_URL",
)

## ---------------------------------------------------------------
# Make your stuff here
