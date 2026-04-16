### A Pluto.jl notebook ###
# v0.20.24

#> custom_attrs = ["hide-enabled"]

using Markdown
using InteractiveUtils

# ╔═╡ 1ca8ff87-b6f9-408b-b8c2-c0748ce7013a
begin
	using PlutoDevMacros
	using PlutoUI
	using PlutoExtras
end

# ╔═╡ acf6a6e2-9698-4aee-b8e5-1b47812370d0
@fromparent begin
	using ^
	using >.HypertextLiteral
	using >.ColorSchemes
end

# ╔═╡ 4adc5050-9909-4895-88fc-68d47b2fe269
md"""
# Packages
"""

# ╔═╡ 76b25629-60d4-4e00-92a3-e29063b87f63
ExtendedTableOfContents()

# ╔═╡ f105aa5f-4036-4343-8c64-4fca54335647
default_plotly_template("none")

# ╔═╡ 4528c942-59c7-4fdf-9f72-49baef0ad172
md"""
# Utilities
"""

# ╔═╡ 18fa9797-2b96-4c72-894d-78b90240d690
md"""
## sample_colorscheme
"""

# ╔═╡ 7665aebd-fc16-4381-a0a5-911f1c96927f
md"""
This function can be used to create a smaller subset of an existing colorscheme, useful when intending to create a discrete colorscale with the `discrete_colorscale` function
"""

# ╔═╡ 6c7025ac-b377-4b3f-a6d2-c5a06cd8151a
sample_colorscheme(colorschemes[:viridis], [0, .3, .9, 1])

# ╔═╡ 4bd23d28-5967-42f7-a5d0-185bba8036f2
md"""
The function can be called with a symbol to directly index the `colorschemes` Dict from `ColorSchemes.jl`.\
Additionally, the optional keyword argument `alpha` can be used to create a colorscheme with a custom opacity
"""

# ╔═╡ 3cfe58c4-177c-4757-a214-fd3989cba6b9
sample_colorscheme(:magma, 5; alpha = .3)

# ╔═╡ 3f94cc82-ba4e-4219-8e6d-81ff98851f8a
md"""
When called with a colorscheme (or with a Symbol) without any second argument, the full colorscheme will be returned
"""

# ╔═╡ c33548ba-39ce-4cf7-87c1-ea59accd7911
sample_colorscheme(:julia)

# ╔═╡ 0267b25f-84f2-4ade-bf96-9e93773cdd81
md"""
The function returns a `ColorScheme` object, which can be directly used in PlutoPlotly as input to the `colorscale` property of `heatmap` and other traces/layouts.
"""

# ╔═╡ eb295bde-d3fa-4d1f-b91b-27c5c88d5c78
plot(heatmap(; z = rand(5,8), colorscale = sample_colorscheme(:viridis; alpha = .5)))

# ╔═╡ 6291f4a8-30ca-4994-b635-1919431e0e4b
md"""
## discrete\_colorscale
"""

# ╔═╡ 63c36746-07a5-4b0e-8f0a-e0094d121e8c
md"""
A problem with the previous approach is that if one wants to have a colorbar which has discrete colors rather than a gradient, a simple colorschemes with a few discrete colors is not sufficient, as the resulting plot will still interpolate colors into a gradient.
"""

# ╔═╡ 14a75659-dca5-4e52-8536-49f2616aa56c
begin
	z = rand(4,8)
	plot(heatmap(; z, colorscale = sample_colorscheme(:viridis, 4)))
end

# ╔═╡ 03989bce-4704-412a-83b4-2ef8d74a3393
md"""
For this reason, PlutoPlotly provides another convenience function which simplify the creation of discrete colorscales.

The `discrete_colorscale` function takes basically the same arguments as the `sample_colorscheme` one (in fact it calls it internally for most of its valid methods), and return an object that can be used to effectively create a discrete colorbar:
"""

# ╔═╡ b219af04-97be-4743-97ae-fbd018c29531
plot(heatmap(; z, colorscale = discrete_colorscale(:viridis, 4)))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoDevMacros = "a0499f29-c39b-4c5c-807c-88074221b949"
PlutoExtras = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoDevMacros = "~0.9.2"
PlutoExtras = "~0.7.18"
PlutoUI = "~0.7.80"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "2ea3db7c52622e7c4606710c0b55655e89d00bdd"

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

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "REPL", "UUIDs"]
git-tree-sha1 = "cfb7a2e89e245a9d5016b70323db412b3a7438d5"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "3.0.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

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
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "58927c485919bf17ea308d9d82156de1adf4b006"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.10.12"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoDevMacros]]
deps = ["JuliaInterpreter", "Logging", "MacroTools", "Pkg", "TOML"]
git-tree-sha1 = "709c36a806ec0af91840184f3052bb3c6cc60915"
uuid = "a0499f29-c39b-4c5c-807c-88074221b949"
version = "0.9.2"

[[deps.PlutoExtras]]
deps = ["AbstractPlutoDingetjes", "DocStringExtensions", "HypertextLiteral", "InteractiveUtils", "Markdown", "PlutoUI", "REPL", "Random"]
git-tree-sha1 = "ba293b0d67584aa71badebdf8e5e572ba61d0246"
uuid = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
version = "0.7.18"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "fbc875044d82c113a9dee6fc14e16cf01fd48872"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.80"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
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
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

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
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"
"""

# ╔═╡ Cell order:
# ╟─4adc5050-9909-4895-88fc-68d47b2fe269
# ╠═1ca8ff87-b6f9-408b-b8c2-c0748ce7013a
# ╠═acf6a6e2-9698-4aee-b8e5-1b47812370d0
# ╠═76b25629-60d4-4e00-92a3-e29063b87f63
# ╠═f105aa5f-4036-4343-8c64-4fca54335647
# ╟─4528c942-59c7-4fdf-9f72-49baef0ad172
# ╟─18fa9797-2b96-4c72-894d-78b90240d690
# ╟─7665aebd-fc16-4381-a0a5-911f1c96927f
# ╠═6c7025ac-b377-4b3f-a6d2-c5a06cd8151a
# ╟─4bd23d28-5967-42f7-a5d0-185bba8036f2
# ╠═3cfe58c4-177c-4757-a214-fd3989cba6b9
# ╟─3f94cc82-ba4e-4219-8e6d-81ff98851f8a
# ╠═c33548ba-39ce-4cf7-87c1-ea59accd7911
# ╟─0267b25f-84f2-4ade-bf96-9e93773cdd81
# ╠═eb295bde-d3fa-4d1f-b91b-27c5c88d5c78
# ╟─6291f4a8-30ca-4994-b635-1919431e0e4b
# ╟─63c36746-07a5-4b0e-8f0a-e0094d121e8c
# ╠═14a75659-dca5-4e52-8536-49f2616aa56c
# ╟─03989bce-4704-412a-83b4-2ef8d74a3393
# ╠═b219af04-97be-4743-97ae-fbd018c29531
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
