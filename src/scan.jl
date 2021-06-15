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
    if length(res) != 0
        names = Symbol.(res[1]["columns"])
        num_rows = sum(length(subres["events"]) for subres ∈ res)
    else
        names = Symbol[]
        num_rows = 0
    end
    ScanResult(names, num_rows, res)
end

struct ScanResult <: QueryResult
    names::Vector{Symbol}
    num_rows::Int
    inner_array::Vector{Dict}
end

names(sr::ScanResult) = getfield(sr, :names)

Base.summary(io::IO, sr::ScanResult) = print(io, string(length(sr)) * "-element " * string(typeof(sr)))
Base.getindex(sr::ScanResult, i::Int) = (i <= length(sr) || throw(BoundsError(sr, i))) && ScanRow(i, sr)

Tables.rowaccess(::ScanResult) = true
Tables.rows(sr::ScanResult) = sr

Base.eltype(::ScanResult) = ScanRow
Base.length(sr::ScanResult) = getfield(sr, :num_rows)
Base.iterate(sr::ScanResult, state=1) = state > length(sr) ? nothing : (ScanRow(state, sr), state + 1)

function Tables.schema(sr::ScanResult)
    if length(sr) != 0
        types = [typeof(cl) for cl in sr[1]]
    else
        types = DataType[]
    end
    Tables.Schema(names(sr), types)
end

struct ScanRow <: Tables.AbstractRow
    row::Int
    source::ScanResult
end

function Tables.getcolumn(sr::ScanRow, name::Symbol)
    elems = 0
    i = getfield(sr, :row)
    for subres ∈ getfield(getfield(sr, :source), :inner_array)
        subelems = length(subres["events"])
        if i <= elems + subelems
            return subres["events"][i - elems]
        end
        elems += subelems
    end
end

Tables.getcolumn(sr::ScanRow, i::Int) = Tables.getcolumn(sr, names(getfield(sr, :source))[i])
Tables.columnnames(sr::ScanRow) = names(getfield(sr, :source))
