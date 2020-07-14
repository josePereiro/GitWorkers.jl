function long_tasks_tests()

    # ------------------- CREATING TREE -------------------
    root = TEST_DIR_ROOT |> abspath
    rm(root; force = true, recursive = true)
    @assert mkdir(root) |> isdir
    @assert mkdir(joinpath(root, ".git")) |> isdir

    # add worker
    workerroot = joinpath(root, "Worker")
    worker = workerroot |> GW.build_worker_file |> GW.create_file
    @assert workerroot |> isdir
    @assert worker |> isfile

    # add task
    taskroot = joinpath(workerroot, "Task")
    task = taskroot |> GW.build_task_file |> GW.create_file
    @assert taskroot |> isdir
    @assert task |> isfile

    # reset worker
    GW.reset()
    @test GW.ORIGIN_CONFIG |> isempty
    @test GW.LOCAL_STATUS |> isempty

    # ------------------- PREPARE TASK -------------------
    origin_dir = task |> dirname
    @test origin_dir |> isdir
    local_dir = joinpath(taskroot, GW.LOCAL_FOLDER_NAME)
    @assert local_dir |> mkdir |> isdir

    taskname = task |> GW.get_taskname
    exec_order = rand(1:1000)
    test_origin_config = Dict{String, Any}(
        taskname => Dict{String, Any}(
            GW.EXEC_ORDER_KEY => Dict(GW.VALUE_KEY => exec_order)
        )
    )
    GW.write_config(test_origin_config, worker)
    @test GW.read_config(worker) == test_origin_config

    test_file = joinpath(taskroot, "test_file.jl")
    @assert !isfile(test_file)
    stdout_secret = rand(Int128) |> string
    stderr_secret = rand(Int128) |> string

    # Program task
    iters = 50
    wtime = 5
    write(task, 
        """
            write("$test_file", getpid() |> string);
            sleep(1) # for the file to be created
            for i in 1:$iters
                sleep($wtime/$iters)
            end
        """
    )

    # Run the task
    @test begin
        GW.worker_loop(worker; verbose = false, deb = true, 
            iters = 1, maxwt = 0)
        true
    end
    # The task must be labeled as not running, this will be updated in the next iter
    @test !GW.LOCAL_STATUS[taskname][GW.RUNNING_STATUS_KEY][GW.VALUE_KEY]

    # Check task runs
    wait_for() do
        isfile(test_file)
    end
    @test isfile(test_file)
    task_pid = read(test_file, String)

    # ------------------- FOLLOW THE TASK EXECUTION -------------------
    # for some time (< wtime) the task must be labeled as running
    wait_for(wtime = wtime/3) do
        GW.worker_loop(worker; verbose = false, deb = true, 
            iters = 1, maxwt = 0)
            
        @test GW.LOCAL_STATUS[taskname][GW.RUNNING_STATUS_KEY][GW.VALUE_KEY]
        false
    end
    
    # ------------------- KILL TASK -------------------
    test_origin_config[taskname][GW.KILL_SIGN_KEY] = Dict(GW.VALUE_KEY => GW.KILL_SIGN)
    GW.write_config(test_origin_config, worker)
    @test GW.read_config(worker) == test_origin_config
    
    @test begin
        GW.worker_loop(worker; verbose = false, deb = true, 
        iters = 1, maxwt = 0)
        true
    end

    @test !isnothing(GW.get_status(taskname, GW.KILL_STATUS_KEY, GW.VALUE_KEY))
    # The same than last time
    @test GW.get_status(taskname, GW.KILL_STATUS_KEY, GW.VALUE_KEY)

    # the task must be killed at some point!!!
    wait_for(wtime = wtime * 2) do
        GW.worker_loop(worker; verbose = false, deb = true, 
            iters = 1, maxwt = 0)
            
        return !GW.get_status(taskname, GW.RUNNING_STATUS_KEY, GW.VALUE_KEY)
    end
    @test !GW.get_status(taskname, GW.RUNNING_STATUS_KEY, GW.VALUE_KEY)

    # testing control dicts
    @test !isnothing(GW.get_config(taskname, GW.EXEC_ORDER_KEY, GW.VALUE_KEY))
    # After many loops the status must be the same, workes can't change this
    @test GW.get_config(taskname, GW.EXEC_ORDER_KEY, GW.VALUE_KEY) == exec_order

    # After many loops the status must be equal to the current (and unique) exec order
    @test !isnothing(GW.get_status(taskname, GW.EXEC_STATUS_KEY, GW.LAST_EXEC_ORDER_KEY))
    @test GW.get_status(taskname, GW.EXEC_STATUS_KEY, GW.LAST_EXEC_ORDER_KEY) == exec_order
    # After many loops the status must be 'false', the last exec order was updated
    @test !isnothing(GW.get_status(taskname, GW.EXEC_STATUS_KEY, GW.VALUE_KEY))
    @test !GW.get_status(taskname, GW.EXEC_STATUS_KEY, GW.VALUE_KEY)

    @test !isnothing(GW.get_status(taskname, GW.RUNNING_STATUS_KEY, GW.VALUE_KEY))
    # After many loops the status must be 'false', the task is too fast for have 
    # a running state at this point
    @test !GW.get_status(taskname, GW.RUNNING_STATUS_KEY, GW.VALUE_KEY)

    # clear
    rm(root; force = true, recursive = true)

end
long_tasks_tests()