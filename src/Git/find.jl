
"""
    Look up for a .git dir. Return the parent dir absolute path.
    Or throw an error. 
"""
function find_reporoot(dir = pwd())
    git_dir = find_up(is_repo, dir) |> dirname
    isnothing(git_dir) && error("Repo not found, dir ($dir) must be in a git repo")
    return git_dir
end

findall_repo(fun::Function) = findall_down(fun, find_reporoot());
findall_repo(name::AbstractString) = 
    findall_repo((path) -> basename(path) == name);

findin_repo(fun::Function) = find_down(fun, find_reporoot());
findin_repo(name::AbstractString) = 
    findin_repo((path) -> basename(path) == name);

"""
    Look down in the dirtree for the first files or dirs 
    that make 'fun' returns true. 'fun' will receive 
    the abspath of each dir or file. 
    Returns an abspath or nothing 
"""
function findup_repo(fun::Function, path = pwd())
    rootparent = find_reporoot(path) |> dirname
    founds = findall_up(fun, path; 
        retfun = (path, container) -> length(container) == 1 &&
        path == rootparent
    )
    return isempty(founds) ? nothing : founds |> first
end
findup_repo(name::String, path = pwd()) = 
    findup_repo((path) -> basename(path) == name, path);