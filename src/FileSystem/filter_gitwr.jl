_keepout_git(path) = basename(path) == ".git"

_filter_gitwr(f::Function; keepout = _keepout_git, kwargs...) =
    filterdown(f, _gitwr_urldir(); keepout, onerr = rethrow, kwargs...)