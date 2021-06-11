"""
    Search(dataSource::DataSource, intervals::Vector{<:Interval}, query::SearchQuerySpec; <keyword arguments>)

Returns a Druid.SearchResult which is compatible with the Tables.jl interface.

A method with all arguments as keyword arguments is also provided.

# Arguments
- granularity::Granularity = nothing
- filter::Filter = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- sort::String = nothing
- limit::Integer = nothing
- context::Dict = nothing
"""
mutable struct Search <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{<:Interval}
    query::SearchQuerySpec
    searchDimensions
    granularity
    filter
    virtualColumns
    sort
    limit
    context
    function Search(
        dataSource, intervals, query;
        searchDimensions=nothing, granularity=nothing, filter=nothing,
        virtualColumns=nothing, sort=nothing, limit=nothing, context=nothing
    )
        nothing_or_type(searchDimensions, Vector{<:DimensionSpec})
        nothing_or_type(granularity, Granularity)
        nothing_or_type(filter, Filter)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        sort === nothing || (sort = lowercase(sort)) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] || error("Invalid sort value")
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        nothing_or_type(context, Dict)
        new("search", dataSource, intervals, query, searchDimensions, granularity, filter, virtualColumns, Dict("type" => sort), limit, context)
    end
end
Search(
    ; dataSource, intervals, query,
    searchDimensions=nothing, granularity=nothing, filter=nothing, virtualColumns=nothing, sort=nothing, limit=nothing, context=nothing
) = Search(
    dataSource, intervals, query;
    searchDimensions, granularity, filter, virtualColumns, sort, limit, context
)

function execute(client::Client, query::Search; pretty=false)
    res = convert(Vector{Dict}, JSON.parse(execute_native_query(client, query; pretty)))
    names = [:timestamp, Symbol.(keys(res[1]["result"][1]))...]
    num_rows = sum(length(subres["result"]) for subres ∈ res)
    SearchResult(names, num_rows, res)
end

struct SearchResult <: QueryResult
    names::Vector{Symbol}
    num_rows::Int
    inner_array::Vector{Dict}
end

names(sr::SearchResult) = getfield(sr, :names)

function Base.getindex(sr::SearchResult, i::Int)
    i <= length(sr) || throw(BoundsError(sr, i))
    elems = 0
    for subres ∈ getfield(sr, :inner_array)
        subelems = length(subres["result"])
        if i <= elems + subelems
            row = Dict(subres["result"][i - elems])
            row["timestamp"] = subres["timestamp"]
            return row
        end
        elems += subelems
    end
end

Tables.rowaccess(::SearchResult) = true
Tables.rows(sr::SearchResult) = sr

Base.eltype(::SearchResult) = SearchRow
Base.length(sr::SearchResult) = getfield(sr, :num_rows)
Base.iterate(sr::SearchResult, state=1) = state > length(sr) ? nothing : (SearchRow(state, sr), state + 1)

struct SearchRow
    row::Int
    source::SearchResult
end

function Tables.getcolumn(sr::SearchRow, name::Symbol)
    getfield(sr, :source)[getfield(sr, :row)][string(name)]
end

Tables.getcolumn(sr::SearchRow, i::Int) = Tables.getcolumn(sr, names(getfield(sr, :source))[i])
Tables.columnnames(sr::SearchRow) = names(getfield(sr, :source))

function Base.show(io::IO, sr::SearchRow)
    print(io, getfield(sr, :source)[getfield(sr, :row)])
end