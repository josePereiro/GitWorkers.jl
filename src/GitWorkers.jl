module GitWorkers

    import GitLinks
    import GitLinks: GitLink
    import ExternalCmds
    import Dates
    import Pkg
    
    import TOML
    import Serialization: serialize, deserialize

    import Logging
    import LoggingExtras

    # Type (Order matters)
    include("Worker/GitWorker.jl")
    include("Tasks/GWTask.jl")

    # Orderless
    include("Worker/state_reg.jl")
    include("Worker/worker.jl")
    include("Worker/gitlink.jl")
    
    include("Utils/rand_str.jl")
    include("Utils/toml_utils.jl")
    include("Utils/fatal_err.jl")
    include("Utils/run.jl")
    include("Utils/flush.jl")
    include("Utils/hash_file.jl")
    include("Utils/printerr.jl")

    include("TreeStruct/tree_struct.jl")
    include("TreeStruct/utils.jl")

    include("ProcManager/proc_reg.jl")
    include("ProcManager/utils.jl")
    include("ProcManager/safe_kill.jl")

    include("Client/upload_task.jl")
    include("Client/gw_setup.jl")
    include("Client/gw_curr.jl")
    include("Client/gw_ping.jl")
    include("Client/gw_spawn.jl")
    
    include("Tasks/gwt_env.jl")
    include("Tasks/parse_args.jl")
    include("Tasks/readme.jl")
    include("Tasks/runme.jl")
    include("Tasks/task_toml.jl")
    include("Tasks/taskdat.jl")
    include("Tasks/taskid.jl")
    include("Tasks/utils.jl")
    include("Tasks/write_task.jl")

    include("TasksManager/spawn_task.jl")
    
    include("DevLand/gw_create_devland.jl")
    include("DevLand/test_gw.jl")

    export gw_setup, gw_curr, gw_ping
    
    function __init__()
        !Sys.isunix() && error("Non-unix systems are not yet supported!")
    end
    
end
