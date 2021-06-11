JSON.lower(ms::TopNMetricSpec) = non_nothing_dict(ms)

"""
    Numeric(metric::String)

Numeric topN metric spec.
"""
struct Numeric <: TopNMetricSpec
    type::String
    metric::String
    Numeric(metric) = new("metric", metric)
end

"""
    Dimension()
    Dimension(; ordering=nothing, previousStop=nothing)

Dimension topN metric spec.

ordering and previousStop should be `String`s if provided.
"""
struct Dimension <: TopNMetricSpec
    type::String
    ordering
    previousStop
    function Dimension(; ordering=nothing, previousStop=nothing)
        ordering === nothing || (ordering = lowercase(ordering)) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] || error("Invalid ordering")
        nothing_or_type(previousStop, String)
        new("dimension", ordering, previousStop)
    end
end

"""
    Inverted(metric::TopNMetricSpec)

Inverting topN metric spec.
"""
struct Inverted <: TopNMetricSpec
    type::String
    metric::TopNMetricSpec
    Inverted(metric) = new("inverted", metric)
end

"""
    TopN(dataSource::DataSource, intervals::Vector{Interval}, granularity::Granularity,
        dimension::DimensionSpec, threshold::Uint64, metric::TopNMetricSpec; <keyword arguments>)

A method with all arguments as keyword arguments is also provided.

# Arguments
- aggregations::Vector{<:Aggregator} = nothing
- postAggregations::Vector{<:PostAggregator} = nothing
- filter::Filter = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- context::Dict = nothing
"""
mutable struct TopN <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{<:Interval}
    granularity::Granularity
    dimension::DimensionSpec
    threshold::UInt64
    metric::TopNMetricSpec
    aggregations
    postAggregations
    filter
    virtualColumns
    context
    function TopN(
        dataSource, intervals, granularity, dimension, threshold, metric;
        aggregations=nothing, postAggregations=nothing, filter=nothing, virtualColumns=nothing, context=nothing
    )
        nothing_or_type(aggregations, Vector{<:Aggregator})
        nothing_or_type(postAggregations, Vector{<:PostAggregator})
        nothing_or_type(filter, Filter)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        nothing_or_type(context, Dict)
        if !isa(metric, Numeric) && !(isa(metric, Inverted) && isa(metric.metric, Numeric))
            if !(aggregations === nothing) || !(postAggregations === nothing)
                error("Aggregations and post aggregations can only be specified for Numeric metric specs")
            end
        end
        new(
            "topN", dataSource, intervals, granularity, dimension, threshold, metric,
            aggregations, postAggregations, filter, virtualColumns, context
        )
    end
end
TopN(
    ; dataSource, intervals, granularity, dimension, threshold, metric,
    aggregations=nothing, postAggregations=nothing, filter=nothing, virtualColumns=nothing, context=nothing
) = TopN(
    dataSource, intervals, granularity, dimension, threshold, metric;
    aggregations, postAggregations, filter, virtualColumns, context
)

function execute(client::Client, query::TopN; pretty=false)
    res = convert(Vector{Dict}, JSON.parse(execute_native_query(client, query; pretty)))
    prefixes = ["top" * string(i) * '_' for i in 1:query.threshold]
    names = vec([Symbol(p * k) for (p, k) ∈ Iterators.product(prefixes, keys(res[1]["result"][1]))])
    push!(names, :timestamp)
    TopNResult(names, res)
end

struct TopNResult <: QueryResult
    names::Vector{Symbol}
    inner_array::Vector{Dict}
end

names(tr::TopNResult) = getfield(tr, :names)

Base.getindex(tr::TopNResult, i::Int) = getfield(tr, :inner_array)[i]

Tables.rowaccess(::TopNResult) = true
Tables.rows(tr::TopNResult) = tr

Base.eltype(::TopNResult) = TopNRow
Base.length(tr::TopNResult) = length(getfield(tr, :inner_array))
Base.iterate(tr::TopNResult, state=1) = state > length(tr) ? nothing : (TopNRow(state, tr), state + 1)

struct TopNRow
    row::Int
    source::TopNResult
end

function Tables.getcolumn(tr::TopNRow, name::Symbol)
    if name == :timestamp
        getfield(tr, :source)[getfield(tr, :row)][string(name)]
    else
        pattern = r"^top(\d)_(.*)$"
        m = match(pattern, string(name))
        getfield(tr, :source)[getfield(tr, :row)]["result"][parse(Int, m.captures[1])][m.captures[2]]
    end
end

Tables.getcolumn(tr::TopNRow, i::Int) = Tables.getcolumn(tr, names(getfield(tr, :source))[i])
Tables.columnnames(tr::TopNRow) = names(getfield(tr, :source))

function Base.show(io::IO, tr::TopNRow)
    print(io, getfield(tr, :source)[getfield(tr, :row)])
end
