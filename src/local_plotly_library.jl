const DATA_FOLDER = BaseDirs.User.data("plutoplotly/")
isdir(DATA_FOLDER) || mkpath(DATA_FOLDER)
const VERSIONS_PATH = joinpath(DATA_FOLDER, "plotly_versions")
const VERSIONS_DICT = Ref(
    try
        TOML.tryparsefile(VERSIONS_PATH)
    catch
        Dict{String, Any}()
    end
    )

function pluto_server_folder()
    is_inside_pluto() || return nothing
    ml = methods(Main.PlutoRunner.embed_display)
    m = first(ml)
    plutorunner_path = string(m.file)
    parts = splitpath(plutorunner_path)
	idx = findfirst(x -> x === "Pluto", parts)
    idx !== nothing || error("Could not automatically extract the Pluto root.")
    pluto_root = joinpath(parts[1:idx+1])
end
function maybe_put_plotly_in_pluto(v)
    name = get_local_name(v)
    pluto_path = pluto_server_folder()
    pluto_path !== nothing || return false
    maybe_add_plotly_local(v)
    # We check whether the plotly library has been already loaded in this Pluto location, and we copy it otherwise
    for subdir in ("frontend-dist", "frontend")
        dist_path = joinpath(pluto_path, subdir)
        isdir(dist_path) || (subdir === "frontend" ? error("Could not find the `frontend` folder inside pluto root:
$pluto_path") : continue)
        file_path = joinpath(dist_path, "plotlyjs", "$name.min.js")
        if !isfile(file_path)
            isdir(joinpath(dist_path, "plotlyjs")) || mkpath(joinpath(dist_path, "plotlyjs"))
            cp(get_local_path(v), file_path)
        end
    end
    return true
end

function update_versions_file()
    open(VERSIONS_PATH, "w") do io
        TOML.print(io, VERSIONS_DICT[])
    end
end
function get_esm_url(v)
    v = string(v)
    d = VERSIONS_DICT[]
    url = if haskey(d, v)
        d[v]
    else
        line = last(eachline(download("https://esm.sh/plotly.js-dist-min@$(v)")))
        parsed_url = "https://esm.sh$(match(r"\".*\"", line).match[2:end-1])"
        d[v] = parsed_url
        update_versions_file()
        parsed_url
    end

end

get_plotly_cdn_url(v) = "https://cdn.plot.ly/plotly-$(VersionNumber(v)).min.js"
get_local_pluto_src(v) = let
    try 
        maybe_put_plotly_in_pluto(v)
    catch e
        @warn("Encountered the following error while trying to copy the plotly library to the Pluto server's frontend:", e)
    end
    "./plotlyjs/$(get_local_name(v)).min.js"
end

get_local_path(v) = joinpath(DATA_FOLDER, "$(get_local_name(v)).min.js")
get_local_name(v) = "plotlyjs-$(VersionNumber(v))"

function maybe_add_plotly_local(v)
    ver = VersionNumber(v)
    # Check if the artifact already exists
    path = get_local_path(v)
    if !isfile(path)
        # We download bundle and save locally
        @info "Downloading a local version of plotly@$v"
        base_url = get_esm_url(v)
        bundle_url = replace(base_url, r".(\w+)$" => s".bundle.\1")
        download(bundle_url, path)
    end
    nothing
end

function get_plotly_src(v, force = "local")
    if lowercase(string(force)) === "esm"
        get_esm_url(v)
    elseif lowercase(string(force)) === "cdn"
        get_plotly_cdn_url(v)
    elseif lowercase(string(force)) === "local"
        get_local_pluto_src(v)
    end
end
    
