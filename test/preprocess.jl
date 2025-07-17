@testitem "Preprocess" begin
    using PlutoPlotly: _process_with_names, AttrName
    l = Layout(;
        title_text = "asd",
        title_x = 0.5
    )
    d = _process_with_names(l, Val(true), AttrName(:layout))
    @test d[:title] isa Dict
    tit = d[:title]
    @test haskey(tit, :text) && tit[:text] == "asd"
    @test haskey(tit, :x) && tit[:x] == 0.5

    # Add a test for nested attrs (Cause of issue #65)
    l = Layout(;
        sliders = [attr(;
            steps = [
                attr(;
                    label = "Step 1",
                    value = 1
                )
            ]
        )]
    )
    d = _process_with_names(l)
    @test d[:sliders][1][:steps][1] isa Dict{Symbol}
end