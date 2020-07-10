# A worker is a folder with an origin-config file
# test st file://./../../test/prepare_tests.jl#55s

is_origin_config_file(path) = isfile(path) && is_workerroot(path |> dirname) && basename(path) == ORIGIN_CONFIG_FILE_NAME

build_origin_config_file(workerroot) = joinpath(workerroot, ORIGIN_CONFIG_FILE_NAME)


"""

"""
function read_origin_config(path = pwd())
    origin_config_file = find_origin_config_file(path, allow_missing = false)
    return read_json(origin_config_file)
end

"""

"""
function write_origin_config(dict::Dict = ORIGIN_CONFIG, path = pwd(); create = true)
    origin_config_file = find_origin_config_file(path, allow_missing = create)
    if create && isnothing(origin_config_file)
        ownerroot = find_ownerworker(path) |> get_workerroot
        origin_config_file = build_origin_config_file(ownerroot)
        create_file(origin_config_file)
    end
    return write_json(origin_config_file, dict)
end
