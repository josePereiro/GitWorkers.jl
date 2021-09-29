const _FILE_TRACKER_MTIME_UTILITY_DB_ = Dict{String, Float64}()
const _FILE_TRACKER_MTIME_DB = Dict{String, Float64}()
const _FILE_TRACKER_SIZE_DB = Dict{String, Float64}()
const _FILE_TRACKER_CONTENT_HASH_DB = Dict{String, UInt64}()

function _reset_file_trakers!()
    empty!(_FILE_TRACKER_MTIME_UTILITY_DB_)
    empty!(_FILE_TRACKER_MTIME_DB)
    empty!(_FILE_TRACKER_SIZE_DB)
    empty!(_FILE_TRACKER_CONTENT_HASH_DB)
end

function _reset_file_trakers!(file::AbstractString)
    delete!(_FILE_TRACKER_MTIME_UTILITY_DB_, file)
    delete!(_FILE_TRACKER_MTIME_DB, file)
    delete!(_FILE_TRACKER_SIZE_DB, file)
    delete!(_FILE_TRACKER_CONTENT_HASH_DB, file)
end

function _event_handler!(userfun::Function, file::AbstractString, event::Function, new_datfun::Function, DB, dbdef, dofirst)
    
    file = abspath(file)
    !isfile(file) && (delete!(DB, file); return false)
    
    isfirst = !haskey(DB, file)
    old_ = get!(DB, file, dbdef)
    new_ = new_datfun(file)
    DB[file] = new_
    
    (isfirst && !dofirst) && return false 
    event(old_, new_) && (userfun(); return true)
    
    return false 
end

_default_event(old_, new_) = (old_ != new_)

_on_mtime_event(fun::Function, file::AbstractString; event = _default_event, dofirst = false) =
    _event_handler!(fun, file, event, mtime, _FILE_TRACKER_MTIME_DB, -1.0, dofirst)

_on_size_event(fun::Function, file::AbstractString; event = _default_event, dofirst = false) =
    _event_handler!(fun, file, event, filesize, _FILE_TRACKER_SIZE_DB, -1.0, dofirst)
    
function _file_content_hash(file) 
    hash_ = hash("")
    isfile(file) && for line in eachline(file)
        hash_ = hash(line, hash_)
    end
    return hash_
end

function _on_content_event(fun::Function, file::AbstractString; event = _default_event, dofirst = false)
    # check if mtime changes (performance)
    _event_handler!(file, _default_event, mtime, _FILE_TRACKER_MTIME_UTILITY_DB_, -1.0, true) do
        _event_handler!(fun, file, event, _file_content_hash, _FILE_TRACKER_CONTENT_HASH_DB, UInt64(0.0), dofirst)
    end
end
    
