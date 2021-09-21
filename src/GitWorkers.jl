module GitWorkers
    
    import LibGit2
    import TOML

    using DataFileNames
    using FilesTreeTools
    using Dates
    using Serialization

    include("ExternalCmds/run_cmd.jl")
    include("ExternalCmds/force_kill.jl")
    include("ExternalCmds/julia.jl")

    include("Core/config.jl")
    include("Core/sys_globals.jl")
    include("Core/sync.jl")
    include("Core/locks.jl")
    include("Core/gen_id.jl")
    include("Core/utils.jl")
    
    include("FileSystem/gitwr_dirs.jl")
    include("FileSystem/filter_gitwr.jl")
    
    include("Client/setup_gitworker.jl")
    include("Client/gitworker.jl")
    include("Client/gwpush.jl")
    
    include("Server/run_server.jl")
    
    include("Maintenance/gitignore.jl")
    include("Maintenance/todel.jl")
    
    include("Tasks/spawn_task.jl")
    include("Tasks/tasks.jl")
    
    include("Events/FileTracker.jl")
    
    include("Test/test_repos.jl")
    include("Test/monkey_delete.jl")
    include("Test/create_test_engine.jl")
    
end
