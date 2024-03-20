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
    write(VERSIONS_PATH, sprint() do io
        TOML.print(io, VERSIONS_DICT[])
    end)
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

get_github_esm_url(v) = "https://github.com/disberd/PlotlyArtifactsESM/releases/download/v$(VersionNumber(v))/plotly-esm-min.mjs"
get_plotly_cdn_url(v) = "https://cdn.plot.ly/plotly-$(VersionNumber(v)).min.js"

"""
mapping a path like "/home/user/.julia/blabla/plotly-1.2.3.min.js" to its contents, read as String
"""
const plotly_dep_contents = Dict{String, String}()

function get_local_plotly_contents(v)
    maybe_add_plotly_local(v)
    path = get_local_path(v)
    get!(plotly_dep_contents, path) do
        read(path, String)
    end
end

get_local_path(v) = joinpath(DATA_FOLDER, "$(get_local_name(v)).min.js")
get_local_name(v) = "plotlyjs-$(VersionNumber(v))"

function maybe_add_plotly_local(v)
    ver = VersionNumber(v)
    # Check if the artifact already exists
    path = get_local_path(ver)
    if !isfile(path)
        # We download bundle and save locally
        @info "Downloading a local version of plotly@$v"
        bundle_url = get_github_esm_url(ver)
        download(bundle_url, path)
    end
    nothing
end


function src_type(input)
    type = lowercase(string(input))
    @assert type in ["esm", "cdn", "local"]
    type
end

function get_plotly_import(v, force = "local")
    force = src_type(force)
    if force == "esm"
        _ImportedRemoteJS(get_esm_url(v))
    elseif force == "cdn"
        _ImportedRemoteJS(get_plotly_cdn_url(v))
    elseif force == "local"
        import_local_js(get_local_plotly_contents(v))
    end
end


struct _ImportedRemoteJS
    src::String
end

function Base.show(io, m::MIME"text/javascript", i::_ImportedRemoteJS)
    write(io, 
        "await import($(repr(i.src)))"
    )
end


struct _ImportedLocalJS
    published
end

function Base.show(io, m::MIME"text/javascript", i::_ImportedLocalJS)
    write(io, 
        """
        await (() => {
        window.created_imports = window.created_imports ?? new Map();
        let code = """
    )
    Base.show(io, m, i.published)

    write(io,
        """;
        if(created_imports.has(code)){
            return created_imports.get(code);
        } else {
            let blob_promise = new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = async () => {
                    try {
                        resolve(await import(reader.result));
                    } catch(e) {
                        reject();
                    }
                }
                reader.onerror = () => reject();
                reader.onabort = () => reject();
                reader.readAsDataURL(
                    new Blob([code], {type : "text/javascript"}))
                });
                created_imports.set(code, blob_promise);
                return blob_promise;
            }
        })()
        """
    )
end

function import_local_js(code::AbstractString)

    code_js = 
        try
        AbstractPlutoDingetjes.Display.published_to_js(code)
    catch e
        @warn "published_to_js did not work" exception=(e,catch_backtrace()) maxlog=1
        repr(code)
    end

    _ImportedLocalJS(code_js)
end


"""
    enable_plutoplotly_offline
Creates a script that loads the plotly library on the current browser session so that it is available even when not connected to internet.
"""
function enable_plutoplotly_offline(;version = get_plotly_version())
    @htl("""
        <script>
            const imports = {
                $version: ($(import_local_js(get_local_plotly_contents(version)))).default
            }
            window.plutoplotly_imports = imports
        </script>
    """)
end


