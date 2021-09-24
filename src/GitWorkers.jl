module GitWorkers
    
    import LibGit2
    import TOML

    using FilesTreeTools
    using Dates
    using Serialization

    include("ExternalCmds/run_cmd.jl")
    include("ExternalCmds/force_kill.jl")
    include("ExternalCmds/julia.jl")

    include("Core/config.jl")
    include("Core/sys_globals.jl")
    include("Core/repo_update.jl")
    include("Core/sync_script.jl")
    include("Core/gen_id.jl")
    include("Core/utils.jl")

    include("Routines/routines.jl")
    include("Routines/routines_templates.jl")
    include("Routines/utils.jl")
    
    include("FileSystem/gitwr_dirs.jl")
    include("FileSystem/filter_gitwr.jl")
    include("FileSystem/utils.jl")
    
    include("Client/setup_gitworker.jl")
    include("Client/gwspawn.jl")
    include("Client/gwpush.jl")
    
    include("Server/run_server.jl")
    include("Server/loop_control.jl")
    
    include("Maintenance/gitignore.jl")
    include("Maintenance/todel.jl")
    include("Maintenance/gc_old_files.jl")
    
    include("Tasks/spawn_task.jl")
    include("Tasks/tasks.jl")
    
    include("Events/FileTracker.jl")
    
    include("Test/test_repos.jl")
    include("Test/monkey_delete.jl")
    include("Test/create_test_engine.jl")

    function __init__()
        !Sys.isunix() && error("Non-unix system are not yet supported!")
    end
    
end
