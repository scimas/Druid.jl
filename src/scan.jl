"""
    Scan(dataSource::DataSource, intervals::Vector{<:Interval}; <keyword arguments>)

A method with all arguments as keyword arguments is also provided.

# Arguments
- columns::Vector{String} = nothing
- filter::Filter = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- order::String = nothing
- limit::Integer = nothing
- offset::Integer = nothing
- resultFormat::String = nothing
- batchSize::Integer = nothing
- context::Dict = nothing
- legacy::Bool = nothing
"""
mutable struct Scan <: Query
    queryType::String
    dataSource::DataSource
    intervals::Vector{<:Interval}
    columns
    filter
    virtualColumns
    order
    limit
    offset
    resultFormat
    batchSize
    context
    legacy
    function Scan(
        dataSource, intervals;
        columns=nothing, filter=nothing, virtualColumns=nothing, order=nothing,
        limit=nothing, offset=nothing, resultFormat=nothing,
        batchSize=nothing, context=nothing, legacy=nothing
    )
        nothing_or_type(columns, Vector{String})
        nothing_or_type(filter, Filter)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        order === nothing || (order = lowercase(order)) ∈ ["ascending", "descending", "none"] || error("Invalid order")
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        offset === nothing || (isa(offset, Integer) && offset >= 0) || error("offset must be a non-negative integer")
        resultFormat === nothing || resultFormat ∈ ["list", "compactedList"] || error("Invalid resultFormat")
        batchSize === nothing || (isa(batchSize, Integer) && batchSize >= 0) || error("batchSize must be a non-negative integer")
        nothing_or_type(context, Dict)
        nothing_or_type(legacy, Bool)
        new("scan", dataSource, intervals, columns, filter, virtualColumns, order, limit, offset, resultFormat, batchSize, context, legacy)
    end
end
Scan(
    ; dataSource, intervals,
    columns=nothing, filter=nothing, virtualColumns=nothing, order=nothing,
    limit=nothing, offset=nothing, resultFormat=nothing,
    batchSize=nothing, context=nothing, legacy=nothing
) = Scan(
    dataSource, intervals;
    columns, filter, virtualColumns, order, limit, offset, resultFormat,
    batchSize, context, legacy
)

function execute(client::Client, query::Scan; pretty=false)
    res = convert(Vector{Dict}, JSON.parse(execute_native_query(client, query; pretty)))
    names = Symbol.(res[1]["columns"])
    num_rows = sum(length(subres["events"]) for subres ∈ res)
    ScanResult(names, num_rows, res)
end

struct ScanResult <: QueryResult
    names::Vector{Symbol}
    num_rows::Int
    inner_array::Vector{Dict}
end

names(tr::ScanResult) = getfield(tr, :names)

function Base.getindex(tr::ScanResult, i::Int)
    i <= length(tr) || throw(BoundsError(tr, i))
    elems = 0
    for subres ∈ getfield(tr, :inner_array)
        subelems = length(subres["events"])
        if i <= elems + subelems
            return subres["events"][i - elems]
        end
        elems += subelems
    end
end

Tables.rowaccess(::ScanResult) = true
Tables.rows(tr::ScanResult) = tr

Base.eltype(::ScanResult) = ScanRow
Base.length(tr::ScanResult) = getfield(tr, :num_rows)
Base.iterate(tr::ScanResult, state=1) = state > length(tr) ? nothing : (ScanRow(state, tr), state + 1)

struct ScanRow
    row::Int
    source::ScanResult
end

Tables.getcolumn(tr::ScanRow, name::Symbol) = getfield(tr, :source)[getfield(tr, :row)][string(name)]
Tables.getcolumn(tr::ScanRow, i::Int) = Tables.getcolumn(tr, names(getfield(tr, :source))[i])
Tables.columnnames(tr::ScanRow) = names(getfield(tr, :source))

function Base.show(io::IO, tr::ScanRow)
    print(io, getfield(tr, :source)[getfield(tr, :row)])
end
