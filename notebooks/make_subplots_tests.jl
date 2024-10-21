### A Pluto.jl notebook ###
# v0.20.0

#> custom_attrs = ["hide-enabled"]

using Markdown
using InteractiveUtils

# ╔═╡ 5a2798a7-d2e4-42a5-9007-6262d7c3b411
begin
	using PlutoDevMacros
	using PlutoUI
	using PlutoExtras
end

# ╔═╡ dd8ddf0a-9085-4c9d-821d-8e7ed78d33c3
@fromparent begin
	using ^
	using >.HypertextLiteral
end

# ╔═╡ d1251ff9-5b35-406c-877f-28e559ac6b46
md"""
# Packages
"""

# ╔═╡ 8a7f8c23-488d-4133-8da6-799343fe00de
ExtendedTableOfContents()

# ╔═╡ 724c19c9-b4a9-4b3b-99aa-9e803b6d412b
default_plotly_template("none")

# ╔═╡ b68cb4f2-fdbe-414f-9a6a-59786720b29f
md"""
# Tests
"""

# ╔═╡ 5e45b2bd-02a5-40c3-8665-ec453997193a
md"""
These are subplots tests taken from [https://github.com/JuliaPlots/PlotlyJS.jl/blob/master/examples/subplots.jl](https://github.com/JuliaPlots/PlotlyJS.jl/blob/master/examples/subplots.jl)
"""

# ╔═╡ 46144daf-e075-4440-8054-6293cff1f228
md"""
## with\_make_subplots1
"""

# ╔═╡ e90ed0c4-efb4-4f76-9093-abe381f6ef5c
let
    # The `shared_xaxes` argument to `make_subplots` can be used to link the x
    # axes of subplots in the resulting figure. The `vertical_spacing` argument
    # is used to control the vertical spacing between rows in the subplot grid.

    # Here is an example that creates a figure with 3 vertically stacked
    # subplots with linked x axes. A small vertical spacing value is used to
    # reduce the spacing between subplot rows.

	p = make_subplots(rows=3, cols=1, shared_xaxes=true, vertical_spacing=0.02)
    add_trace!(p, scatter(x=0:2, y=10:12), row=3, col=1)
    add_trace!(p, scatter(x=2:4, y=100:10:120), row=2, col=1)
    add_trace!(p, scatter(x=3:5, y=1000:100:1200), row=1, col=1)
    relayout!(p, title_text="Stacked Subplots with Shared X-Axes")
    p
end

# ╔═╡ 96e17c39-3bfc-4372-9a3b-78dd1974f4ab
md"""
## with\_make_subplots2
"""

# ╔═╡ 429c68e6-b9ed-42a8-aeac-1e78ba91e768
let
    p = make_subplots(rows=2, cols=2, shared_yaxes=true)
    add_trace!(p, scatter(x=0:2, y=10:12), row=1, col=1)
    relayout!(p, title_text="Multiple Subplots with Shared Y-Axes")
	p.layout.template
end

# ╔═╡ a975e09b-7ff1-4a3b-a667-62448770ab68
let
	# The `shared_yaxes` argument to `make_subplots` can be used to link the y
    # axes of subplots in the resulting figure.

    # Here is an example that creates a figure with a 2 x 2 subplot grid, where
    # the y axes of each row are linked.

    p = make_subplots(rows=2, cols=2, shared_yaxes=true)
    add_trace!(p, scatter(x=0:2, y=10:12), row=1, col=1)
    add_trace!(p, scatter(x=20:10:40, y=1:3), row=1, col=2)
    add_trace!(p, scatter(x=3:5, y=600:100:800), row=2, col=1)
    add_trace!(p, scatter(x=3:5, y=1000:100:1200), row=2, col=2)
    relayout!(p, title_text="Multiple Subplots with Shared Y-Axes")
    p
 end

# ╔═╡ 55ebabe9-e864-4905-82e7-d4ccc2eab75d
md"""
## with\_make_subplots3
"""

# ╔═╡ b0e75a40-158e-488d-9aa3-2ffdcfed139e
let
	# The `specs` argument to `make_subplots` is used to configure per-subplot
    # options.  `specs` must be a `Matrix` with dimensions that match those
    # provided as the `rows` and `cols` arguments. The elements of `specs` may
    # either be `missing`, indicating no subplot should be initialized starting
    # with this grid cell, or an instance of `Spec` containing subplot options.
    # The `colspan` subplot option specifies the number of grid columns that the
    # subplot starting in the given cell should occupy.  If unspecified,
    # `colspan` defaults to 1.

    # Here is an example that creates a 2 by 2 subplot grid containing 3
    # subplots. The subplot `specs` element for position (2, 1) has a `colspan`
    # value of 2, causing it to span the full figure width. The subplot `specs`
    # element f or position (2, 2) is `None` because no subplot begins at this
    # location in the grid.
    p = make_subplots(
        rows=2, cols=2,
        specs=[Spec() Spec(); Spec(colspan=2) missing],
        subplot_titles=["First Subplot" "Second Subplot"; "Third Subplot" missing]
    )

    add_trace!(p, scatter(x=[1, 2], y=[1, 2]), row=1, col=1)
    add_trace!(p, scatter(x=[1, 2], y=[1, 2]), row=1, col=2)
    add_trace!(p, scatter(x=[1, 2, 3], y=[2, 1, 2]), row=2, col=1)

    relayout!(p, showlegend=false, title_text="Specs with Subplot Title")
    p
end

# ╔═╡ dff22380-9496-4615-8fad-516086dadf40
md"""
## with\_make_subplots4
"""

# ╔═╡ 8b1ebbce-c0a2-4ac8-8cf8-52afeda5cb72
let
	# Here is an example that uses the `rowspan` and `colspan` subplot options
    # to create a custom subplot layout with subplots of mixed sizes.
    p = make_subplots(
        rows=5, cols=2,
        specs=[Spec() Spec(rowspan=2)
               Spec() missing
               Spec(rowspan=2, colspan=2) missing
               missing missing
               Spec() Spec()]
    )

    add_trace!(p, scatter(x=[1, 2], y=[1, 2], name="(1,1)"), row=1, col=1)
    add_trace!(p, scatter(x=[1, 2], y=[1, 2], name="(1,2)"), row=1, col=2)
    add_trace!(p, scatter(x=[1, 2], y=[1, 2], name="(2,1)"), row=2, col=1)
    add_trace!(p, scatter(x=[1, 2], y=[1, 2], name="(3,1)"), row=3, col=1)
    add_trace!(p, scatter(x=[1, 2], y=[1, 2], name="(5,1)"), row=5, col=1)
    add_trace!(p, scatter(x=[1, 2], y=[1, 2], name="(5,2)"), row=5, col=2)

    relayout!(p, height=600, width=600, title_text="specs examples")
    p
end

# ╔═╡ bdb3efbb-7a07-494b-bf8e-3ced7ffc49c5
md"""
## hcat
"""

# ╔═╡ 5f711a53-0e31-4e38-b640-5a1cb2a5c8d6
hcat(plot(rand(4)), plot(rand(4)))

# ╔═╡ 9cf8e6ef-d06d-4140-8730-1d2f9720f9dd
md"""
## vcat
"""

# ╔═╡ c0fa557c-4922-4729-8e45-75c2c4c6f065
vcat(plot(rand(4)), plot(rand(4)))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoDevMacros = "a0499f29-c39b-4c5c-807c-88074221b949"
PlutoExtras = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoDevMacros = "~0.5.8"
PlutoExtras = "~0.7.10"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "783a712e7e33acbda630018c7e39842b9b0c76ad"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoDevMacros]]
deps = ["HypertextLiteral", "InteractiveUtils", "MacroTools", "Markdown", "Pkg", "Random", "TOML"]
git-tree-sha1 = "6ce1d9f7c078b493812161349c48735dee275466"
uuid = "a0499f29-c39b-4c5c-807c-88074221b949"
version = "0.5.8"

[[deps.PlutoExtras]]
deps = ["AbstractPlutoDingetjes", "DocStringExtensions", "HypertextLiteral", "InteractiveUtils", "Markdown", "PlutoUI", "REPL", "Random"]
git-tree-sha1 = "681f89bdd5c1da76b31a524af798efb5eb332ee9"
uuid = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
version = "0.7.13"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─d1251ff9-5b35-406c-877f-28e559ac6b46
# ╠═5a2798a7-d2e4-42a5-9007-6262d7c3b411
# ╠═dd8ddf0a-9085-4c9d-821d-8e7ed78d33c3
# ╠═8a7f8c23-488d-4133-8da6-799343fe00de
# ╠═724c19c9-b4a9-4b3b-99aa-9e803b6d412b
# ╟─b68cb4f2-fdbe-414f-9a6a-59786720b29f
# ╟─5e45b2bd-02a5-40c3-8665-ec453997193a
# ╟─46144daf-e075-4440-8054-6293cff1f228
# ╠═e90ed0c4-efb4-4f76-9093-abe381f6ef5c
# ╟─96e17c39-3bfc-4372-9a3b-78dd1974f4ab
# ╠═429c68e6-b9ed-42a8-aeac-1e78ba91e768
# ╠═a975e09b-7ff1-4a3b-a667-62448770ab68
# ╟─55ebabe9-e864-4905-82e7-d4ccc2eab75d
# ╠═b0e75a40-158e-488d-9aa3-2ffdcfed139e
# ╟─dff22380-9496-4615-8fad-516086dadf40
# ╠═8b1ebbce-c0a2-4ac8-8cf8-52afeda5cb72
# ╟─bdb3efbb-7a07-494b-bf8e-3ced7ffc49c5
# ╠═5f711a53-0e31-4e38-b640-5a1cb2a5c8d6
# ╟─9cf8e6ef-d06d-4140-8730-1d2f9720f9dd
# ╠═c0fa557c-4922-4729-8e45-75c2c4c6f065
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
