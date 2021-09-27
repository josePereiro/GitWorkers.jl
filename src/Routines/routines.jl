## ------------------------------------------------------------------
const _GITWR_ROUTINE_FILE_EXT = ".gwrt"

const _GITWR_UPLOCAL_RTDIR = ".uplocal_rtdir"
const _GITWR_UPREPO_RTDIR = ".uprepo_rtdir"

_is_rtfile(rtfile) = isfile(rtfile) && endswith(rtfile, _GITWR_ROUTINE_FILE_EXT)
_uplocal_rtfile(name) = _repodir(_GITWR_UPLOCAL_RTDIR, string(name, _GITWR_ROUTINE_FILE_EXT))
_uprepo_rtfile(name) = _repodir(_GITWR_UPREPO_RTDIR, string(name, _GITWR_ROUTINE_FILE_EXT))

## ------------------------------------------------------------------

function _serialize_rt(rtid, ex::Expr, rtfile::String; long = true)
    
    !Meta.isexpr(ex, :block) && error("A 'begin' block was expected. Ex: '@gitworker begin println(\"Hi\")' end")

    __routine__ = (;
        id = rtid, 
        rtfile = _rel_urlpath(rtfile), 
    )

    expr = quote
        let
            __routine__ = $(__routine__)
            $(ex)
            return nothing
        end
    end

    rtdat = (;
        id = rtid, 
        rtfile = _rel_urlpath(rtfile),
        expr, 
        long
    )

    serialize(rtfile, rtdat)

end

## ------------------------------------------------------------------
_serialize_repo_rt(rtid, expr::Expr; kwargs...) = _serialize_rt(rtid, expr, _uprepo_rtfile(rtid); kwargs...)
_serialize_repo_rt(expr::Expr; kwargs...) = _serialize_repo_rt(_gen_id(), expr; kwargs...)

_serialize_local_rt(rtid, expr::Expr; kwargs...) = _serialize_rt(rtid, expr, _uplocal_rtfile(rtid); kwargs...)
_serialize_local_rt(expr::Expr; kwargs...) = _serialize_local_rt(_gen_id(), expr; kwargs...)

# outfile = _rel_urlpath(outfile), 
# errfile = _rel_urlpath(errfile)