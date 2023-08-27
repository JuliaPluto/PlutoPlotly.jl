module UnitfulExt

using PlutoPlotly: _preprocess, PlutoPlotly
using Unitful: Quantity, ustrip

PlutoPlotly._preprocess(q::Quantity) = _preprocess(ustrip(q))

end