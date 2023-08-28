using Test
using DataFrames
using PlutoPlotly

function fresh_data()
    t1 = scatter(;y=[1, 2, 3])
    t2 = scatter(;y=[10, 20, 30])
    t3 = scatter(;y=[100, 200, 300])
    l = Layout(;title="Foo")
    p = Plot([copy(t1), copy(t2), copy(t3)], copy(l)) |> PlutoPlot
    t1, t2, t3, l, p
end

@testset "Test api methods on Plot" begin

    # @testset "test helpers" begin
    #     @test PlotlyBase._prep_restyle_vec_setindex([1, 2], 2) == [1, 2]
    #     @test PlotlyBase._prep_restyle_vec_setindex([1, 2], 3) == [1, 2, 1]
    #     @test PlotlyBase._prep_restyle_vec_setindex([1, 2], 4) == [1, 2, 1, 2]

    #     @test PlotlyBase._prep_restyle_vec_setindex((1, [42, 4]), 2) == Any[1, [42, 4]]
    #     @test PlotlyBase._prep_restyle_vec_setindex((1, [42, 4]), 3) == Any[1, [42, 4], 1]
    #     @test PlotlyBase._prep_restyle_vec_setindex((1, [42, 4]), 4) == Any[1, [42, 4], 1, [42, 4]]
    # end

    # @testset "test _update_fields" begin
    #     t1, t2, t3, l, p = fresh_data()
    #     # test dict version
    #     o = copy(t1)
    #     PlotlyBase._update_fields(o, 1, Dict{Symbol,Any}(:foo => "Bar"))
    #     @test o["foo"] == "Bar"
    #     # kwarg version
    #     PlotlyBase._update_fields(o, 1; foo="Foo")
    #     @test o["foo"] == "Foo"

    #     # dict + kwarg version. Make sure dict gets through w/out replacing _
    #     PlotlyBase._update_fields(o, 1, Dict{Symbol,Any}(:fuzzy_wuzzy => "Bear");
    #                             fuzzy_wuzzy="?")
    #     @test o.fields[:fuzzy_wuzzy] == "Bear"
    #     @test isa(o.fields[:fuzzy], Dict)
    #     @test o["fuzzy.wuzzy"] == "?"
    # end

    @testset "test relayout!" begin
        t1, t2, t3, l, p = fresh_data()
        # test on plot object
        relayout!(p, Dict{Symbol,Any}(:title => "Fuzzy"); xaxis_title="wuzzy")
        @test p.layout["title"] == "Fuzzy"
        @test p.layout["xaxis.title.text"] == "wuzzy"

        # test on layout object
        relayout!(l, Dict{Symbol,Any}(:title => "Fuzzy"); xaxis_title="wuzzy")
        @test l["title"] == "Fuzzy"
        @test l["xaxis.title.text"] == "wuzzy"
        end

    @testset "test react!" begin
        t1, t2, t3, l, p = fresh_data()
        t4 = bar(x=[1, 2, 3], y=[42, 242, 142])
        l2 = Layout(xaxis_title="wuzzy")
        react!(p, [t4], l2)
        
        @test length(p.data) == 1
        @test p.data[1] == t4
        @test p.layout == l2
    end

    @testset "test purge!" begin
        t1, t2, t3, l, p = fresh_data()
        purge!(p)
        @test p.data == []
        @test p.layout == Layout()
    end

    @testset "test restyle!" begin
        t1, t2, t3, l, p = fresh_data()
        # test on trace object
        restyle!(t1, 1, Dict{Symbol,Any}(:opacity => 0.4); marker_color="red")
        @test t1["opacity"] == 0.4
        @test t1["marker.color"] == "red"

        # test for single trace in plot
        restyle!(p, 2, Dict{Symbol,Any}(:opacity => 0.4); marker_color="red")
        @test p.data[2]["opacity"] == 0.4
        @test p.data[2]["marker.color"] == "red"

        # test for multiple trace in plot
        restyle!(p, [1, 3], Dict{Symbol,Any}(:opacity => 0.9); marker_color="blue")
        @test p.data[1]["opacity"] == 0.9
        @test p.data[1]["marker.color"] == "blue"
        @test p.data[3]["opacity"] == 0.9
        @test p.data[3]["marker.color"] == "blue"

        # test for all traces in plot
        restyle!(p, 1:3, Dict{Symbol,Any}(:opacity => 0.42); marker_color="white")
        for i in 1:3
        @test p.data[i]["opacity"] == 0.42
            @test p.data[i]["marker.color"] == "white"
        end

        @testset "test restyle with vector attributes applied to all traces" begin
            # test that short arrays repeat
            restyle!(p, marker_color=["red", "green"])
            @test p.data[1]["marker.color"] == "red"
            @test p.data[2]["marker.color"] == "green"
            @test p.data[3]["marker.color"] == "red"

            # test that array of arrays is repeated and applied everywhere
            restyle!(p, marker_color=(["red", "green"],))
            @test p.data[1]["marker.color"] == ["red", "green"]
            @test p.data[2]["marker.color"] == ["red", "green"]
            @test p.data[3]["marker.color"] == ["red", "green"]

            # test that array of arrays is repeated and applied everywhere
            restyle!(p, marker_color=(["red", "green"], "blue"))
            @test p.data[1]["marker.color"] == ["red", "green"]
            @test p.data[2]["marker.color"] == "blue"
            @test p.data[3]["marker.color"] == ["red", "green"]
        end

        @testset "test restyle with vector attributes applied to vector of traces" begin
            # test that short arrays repeat
            restyle!(p, 1:3, marker_color=["red", "green"])
            @test p.data[1]["marker.color"] == "red"
            @test p.data[2]["marker.color"] == "green"
            @test p.data[3]["marker.color"] == "red"

            # test that array of arrays is repeated and applied everywhere
            restyle!(p, 1:3, marker_color=(["red", "green"],))
            @test p.data[1]["marker.color"] == ["red", "green"]
            @test p.data[2]["marker.color"] == ["red", "green"]
            @test p.data[3]["marker.color"] == ["red", "green"]

            # test that array of arrays is repeated and applied everywhere
            restyle!(p, 1:3, marker_color=(["red", "green"], "blue"))
            @test p.data[1]["marker.color"] == ["red", "green"]
            @test p.data[2]["marker.color"] == "blue"
            @test p.data[3]["marker.color"] == ["red", "green"]
        end

        @testset "test restyle with vector attributes applied to trace object" begin
            restyle!(t1, 1, x=[1, 2, 3])
            @test t1["x"] == 1

            restyle!(t1, 1, x=([1, 2, 3],))
            @test t1["x"] == [1, 2, 3]
        end

        @testset "test restyle with vector attributes applied to single trace " begin
            restyle!(p, 2, x=[1, 2, 3])
            @test p.data[2]["x"] == 1

            restyle!(p, 2, x=([1, 2, 3],))
            @test p.data[2]["x"] == [1, 2, 3]
        end
    end

    @testset "test addtraces!" begin
        t1, t2, t3, l, p = fresh_data()
        p2 = Plot()

        # test add one trace to end
        addtraces!(p2, t1)
        @test length(p2.data) == 1
        @test p2.data[1] == t1

        # test add two traces to end
        addtraces!(p2, t2, t3)
        @test length(p2.data) == 3
        @test p2.data[2] == t2
        @test p2.data[3] == t3

        # test add one trace middle
        t4 = scatter()
        addtraces!(p2, 2, t4)
        @test length(p2.data) == 4
        @test p2.data[1] == t1
        @test p2.data[2] == t4
        @test p2.data[3] == t2
        @test p2.data[4] == t3

        # test add multiple trace middle
        t5 = scatter()
        t6 = scatter()
        addtraces!(p2, 2, t5, t6)
        @test length(p2.data) == 6
        @test p2.data[1] == t1
        @test p2.data[2] == t5
        @test p2.data[3] == t6
        @test p2.data[4] == t4
        @test p2.data[5] == t2
        @test p2.data[6] == t3
    end

    @testset "test deletetraces!" begin
        t1, t2, t3, l, p = fresh_data()

        # test delete one trace
        deletetraces!(p, 2)
        @test length(p.data) == 2
        @test p.data[1]["y"] == t1["y"]
        @test p.data[2]["y"] == t3["y"]

        # test delete multiple traces
        deletetraces!(p, 1, 2)
        @test length(p.data) == 0
    end

    @testset "test movetraces!" begin
        t1, t2, t3, l, p = fresh_data()

        # test move one trace to end
        movetraces!(p, 2)  # now 1 3 2
        @test p.data[1]["y"] == t1["y"]
        @test p.data[2]["y"] == t3["y"]
        @test p.data[3]["y"] == t2["y"]

        # test move two traces to end
        movetraces!(p, 1, 2) # now 2 1 3
        @test p.data[1]["y"] == t2["y"]
        @test p.data[2]["y"] == t1["y"]
        @test p.data[3]["y"] == t3["y"]

        # test move from/to
        movetraces!(p, [1, 3], [2, 1])  # 213 -> 123 -> 312
        @test p.data[1]["y"] == t3["y"]
        @test p.data[2]["y"] == t1["y"]
        @test p.data[3]["y"] == t2["y"]
    end


    @testset "test update_XXX! layout props" begin
        t1, t2, t3, l, p = fresh_data()
        p2 = [p p]
        @test PlotlyBase._isempty(p2.layout.xaxis2_showticklabels)
        @test PlotlyBase._isempty(p2.layout.xaxis_showticklabels)
        update_xaxes!(p2, showticklabels=true)

        @test p2.layout.xaxis2_showticklabels
        @test p2.layout.xaxis_showticklabels
        
        p3 = [p; p]
        @test PlotlyBase._isempty(p3.layout.yaxis2_showticklabels)
        @test PlotlyBase._isempty(p3.layout.yaxis_showticklabels)
        update_yaxes!(p3, showticklabels=true)

        @test p3.layout.yaxis2_showticklabels
        @test p3.layout.yaxis_showticklabels


        for ann in p2.layout.annotations
            @test ann[:font][:size] != 1
        end
        update_annotations!(p2, font_size=1)
        for ann in p2.layout.annotations
            @test ann[:font][:size] == 1
        end
    end

    @testset "add_trace!" begin
        df = stack(DataFrame(x=1:10, one=1, two=2, three=3, four=4, five=5, six=6, seven=7), Not(:x))
        p = plot(df, x=:x, y=:value, facet_col=:variable, facet_col_wrap=2)
        @test length(p.data) == 7
        @test size(p.layout.subplots.grid_ref) == (4, 2)

        add_trace!(p, scatter(x=1:4, y=(1:4).^2), row="all")  # add to all rows in col 1
        @test length(p.data) == 11

        add_trace!(p, scatter(x=1:4, y=(1:4).^2), col="all")  # add to all cols in row 1
        @test length(p.data) == 13

        add_trace!(p, scatter(x=1:4, y=(1:4).^2), col=Colon(), row=3)  # add to all cols in row 3
        @test length(p.data) == 15

        add_trace!(p, scatter(x=1:4, y=(1:4).^2), row="all", col="all")
        @test length(p.data) == 23  # adds 8 because we get full 4x2 grid
    end
end

@testset "add_shape!" begin
    p = plot(Layout(Subplots(rows=2, cols=2)))
    add_trace!(p, scatter(y=rand(4)), row="all", col="all")
    add_shape!(p, rect(x0=2, x1=4, y0=0.2, y1=0.5, line_color="purple"), row="all", col="all")
    @test length(p.layout.shapes) == 4
    @test all(s -> s.type == "rect", p.layout.shapes)
    @test all(s -> s.line_color == "purple", p.layout.shapes)

    add_shape!(p, line(x0=1, x1=3, y0=.5, y1=.9, line_color="yellow"), row="all", col=2)
    @test length(p.layout.shapes) == 6
    @test all(s -> s.type == "line", p.layout.shapes[5:6])
    @test all(s -> s.line_color == "yellow", p.layout.shapes[5:6])

    add_shape!(p, circle(x0=4, y0=0.2, x1=5, y1=0.7, line_color="black"), row=2)
    @test length(p.layout.shapes) == 8
    @test all(s -> s.type == "circle", p.layout.shapes[7:8])
    @test all(s -> s.line_color == "black", p.layout.shapes[7:8])
end

@testset "unpack namedtuple type figure" begin
    fig = (
        data = [
            (type = "scatter", x = 1:4, y = rand(4), mode = "markers", marker = (line = (color = "red", width = 2), size = 8)),
            (type = "scatter", x = 1:4, y = rand(4))
        ],
        layout = (hovermode = "unified",)
    )
    plots = PlutoPlot[
        plot(fig)
        plot((layout = fig.layout, data = fig.data))
        plot((;frames=[], fig...))
        plot((;fig..., frames=[]))
        plot((layout = fig.layout, frames = [], data = fig.data))
        plot((data = fig.data, frames = [], layout = fig.layout))
    ]
    p1 = plots[1];
    for p2 in plots[2:end]
        @test p1.layout == p2.layout
        @test p1.data == p2.data
    end
    @test p1.data[1] isa GenericTrace
    @test p1.data[1].marker isa Dict
    @test p1.data[1].marker_line isa Dict
    @test p1.data[1].marker_line_width isa Number

end

@testset "subplots" begin

    labels = ["1st", "2nd", "3rd", "4th", "5th"]

    # Define color sets of paintings
    night_colors = ["rgb(56, 75, 126)", "rgb(18, 36, 37)", "rgb(34, 53, 101)",
                    "rgb(36, 55, 57)", "rgb(6, 4, 4)"]
    sunflowers_colors = ["rgb(177, 127, 38)", "rgb(205, 152, 36)", "rgb(99, 79, 37)",
                        "rgb(129, 180, 179)", "rgb(124, 103, 37)"]
    irises_colors = ["rgb(33, 75, 99)", "rgb(79, 129, 102)", "rgb(151, 179, 100)",
                    "rgb(175, 49, 35)", "rgb(36, 73, 147)"]
    cafe_colors =  ["rgb(146, 123, 21)", "rgb(177, 180, 34)", "rgb(206, 206, 40)",
                    "rgb(175, 51, 21)", "rgb(35, 36, 21)"]

    # Create subplots, using "domain" type for pie charts
    layout = Layout(Subplots(rows=2, cols=2, specs=fill(Spec(kind="domain"), 2, 2)))
    fig = plot(layout)
    

    # Define pie charts
    add_trace!(fig, pie(labels=labels, values=[38, 27, 18, 10, 7], name="Starry Night",
                        marker_colors=night_colors), row=1, col=1)
    add_trace!(fig, pie(labels=labels, values=[28, 26, 21, 15, 10], name="Sunflowers",
                        marker_colors=sunflowers_colors), row=1, col=2)
    add_trace!(fig, pie(labels=labels, values=[38, 19, 16, 14, 13], name="Irises",
                        marker_colors=irises_colors), row=2, col=1)
    add_trace!(fig, pie(labels=labels, values=[31, 24, 19, 18, 8], name="The Night Café",
                        marker_colors=cafe_colors), row=2, col=2)

    # Tune layout and hover info
    restyle!(fig, hoverinfo="label+percent+name", textinfo="none")
    relayout!(fig, title_text="Van Gogh: 5 Most Prominent Colors Shown Proportionally",
            showlegend=false)

    @test !isempty(fig.data[1].domain_y)
    @test !isempty(fig.data[1].domain_x)

end

@testset "Random Additional Coverage Tests" begin
        t1, t2, t3, l, p = fresh_data()
        # test on plot object
        p2 = relayout(p, Dict{Symbol,Any}(:title => "Fuzzy"); xaxis_title="wuzzy")
        relayout!(p, Dict{Symbol,Any}(:title => "Fuzzy"); xaxis_title="wuzzy")
        @test p2.layout == p.layout
        @test p2.layout !== p.layout

        @test_nowarn [p p;p p]
end