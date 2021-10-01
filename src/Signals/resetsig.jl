# ------------------------------------------------------
# RESET SIG
const _GITGW_RESETSIG_EXT = ".resetsig"
_resetsig_name() = _GITGW_RESETSIG_EXT
_is_resetsig_file(fn) = endswith(fn, _GITGW_RESETSIG_EXT)
_local_resetsig_file() = _local_sigdir(_resetsig_name())
_repo_resetsig_file() = _repo_sigdir(_resetsig_name())

_set_resetsig(;update = false) = _write_toml(_repo_resetsig_file(); update)