"""
    deb = true just for testing
"""
function worker_loop(path = pwd(); maxwt = 10, verbose = true, 
        iters::Int = typemax(Int), deb = false)

    # This loop must be run from a wirker dir
    worker = find_ownerworker(path)

    # TODO: run some checks

    for it in 1:iters

        try

            # Wait a random time
            sleep(maxwt * rand())

            verbose && println(
            "\n------------------- SYNC REPO -------------------\n\n")

            # ------------------- FORCE "PULL" -------------------
            # This force the local repo to be equal to the origin
            # This is a fundamental design desition. This way the 
            # worker is more robust    
            verbose && println("Force pull from origin")    
            !deb && git_pull(force = true; print = verbose)
            
            # ------------------- UPDATE REPO TASKS LOCALS -------------------
            # The local directories of the repo will be overwritten by
            # its peers in the copy
            # This implements downstream -> upstream comunication 
            sync_taskdirs(FROM_COPY, LOCAL_FOLDER_NAME, worker)

            # ------------------- UPDATE LOCAL STATUS FILE -------------------
            # the updated local status in written in the file
            # The next repo sync will reflect that
            verbose && println()
            verbose && println("Updating $(LOCAL_STATUS_FILE_NAME) from LOCAL_STATUS")
            write_local_status(LOCAL_STATUS, worker; create = true)
            verbose && println()

            # TODO: introduce checks before pushing
            # ------------------- PUSH ORIGINS -------------------
            verbose && println("Adding to local repo")
            !deb && git_add_all(print = verbose)
            msg = get_workername(worker) * " update"
            verbose && println("\nCommiting, -m '$msg'")
            !deb && git_commit(msg; print = verbose)
            verbose && println("\nPushing to origin")
            !deb && git_push(print = verbose)
            
            # ------------------- UPDATE LOCAL ORIGINS -------------------
            # The origin directories of the copy will be overwritten by
            # its peers in the repo
            # This implements upstream -> downstream comunication 
            sync_taskdirs(FROM_REPO, ORIGIN_FOLDER_NAME, worker)

            verbose && println(
            "\n------------------- MANAGING TASKS -------------------\n\n")

            # ------------------- UPDATE ORIGIN_CONFIG -------------------
            # Now ORIGIN_CONFIG is up to date with the data from origin
            verbose && println("Updating ORIGIN_CONFIG from $(ORIGIN_CONFIG_FILE_NAME)")
            global ORIGIN_CONFIG = read_origin_config(worker)
            verbose && println()
            flush(stdout)

            # ------------------- TASKS MANNAGING -------------------
            tasks = findtasks_worker(worker)
            copytasks = filter((file) -> file |> get_taskroot |> is_copytaskroot, tasks)
            for copytask in copytasks

                taskname = get_taskname(copytask)
                update_kill_status(taskname)
                update_execution_status(taskname)
                update_running_status(taskname)

                # This will know whta to do with the task depending
                # of the status
                mannage_task(copytask; verbose = verbose)

                verbose && summary_task(taskname)
                verbose && println()
                flush(stdout)

            end # foreach task

        catch err

            deb && rethrow(err)
            verbose && println(
            "\n------------------- ERROR -------------------\n")
            flush(stdout)
            verbose && showerror(stderr, err, catch_backtrace())
            verbose && println()
            flush(stderr)

            err isa InterruptException && return
        end

        flush(stdout)
        
    end # while
end