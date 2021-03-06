function follow_exec(exec_order, path = pwd(); wt = 10, init_margin = 50)

    # checks
    check_gitignores(path)

    task = find_ownertask(path)
    taskroot = task |> get_taskroot
    workername = path |> find_ownerworker |> get_workername
    
    l0 = Dict()
    stdout_file = get_stdout_file(path, exec_order)
    l0[stdout_file] = !isfile(stdout_file) ? 1 : 
        max(1, length(readlines(stdout_file)) - init_margin)
    stderr_file = get_stderr_file(path, exec_order)
    l0[stderr_file] = !isfile(stderr_file) ? 1 : 
        max(1, length(readlines(stderr_file)) - init_margin)

    token = get_config(PUSH_TOKEN_KEY, VALUE_KEY)
    ismissing(token) || !token && @warn("$workername current push token: $token")

    while true

        try
            # Pulling
            git_pull(force = false, print = false)
            
            last_file = nothing
            for (file, color_) in [(stdout_file, :blue), (stderr_file, :red)]
                !isfile(file) && continue

                l0_ = l0[file]
                lines = readlines(file)
                length(lines) <= l0_ && continue 

                bn = basename(file)
                last_file != file && println()
                for (i, line) in lines[l0_:end] |> enumerate
                    printstyled("[", bn, "] ", l0_ + i - 1, ":  ", color = color_)
                    println(line)
                end
                l0[file] = length(lines) + 1
                last_file = file
            end

            sleep(wt)
        catch err
            err isa InterruptException && return
            rethrow(err)
        end
    end

end