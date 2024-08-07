module UnitfulExt

using PlutoPlotly: _process_with_names, PlutoPlotly, AttrName
using Unitful: Quantity, ustrip

PlutoPlotly._process_with_names(q::Quantity, fl::Val, @nospecialize(args::Vararg{AttrName})) = _process_with_names(ustrip(q), fl, args...)

end