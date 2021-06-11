JSON.lower(q::Query) = non_nothing_dict(q)
query_type(q::Query) = q.queryType
JSON.lower(ls::LimitSpec) = non_nothing_dict(ls)
Tables.istable(::QueryResult) = true

include("timeseries.jl")
include("topn.jl")
include("groupby.jl")

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

"""
    Search(dataSource::DataSource, intervals::Vector{<:Interval}, query::SearchQuerySpec; <keyword arguments>)

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
    granularity
    filter
    virtualColumns
    sort
    limit
    context
    function Search(
        dataSource, intervals, query;
        granularity=nothing, filter=nothing, virtualColumns=nothing, sort=nothing, limit=nothing, context=nothing
    )
        nothing_or_type(granularity, Granularity)
        nothing_or_type(filter, Filter)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        sort === nothing || (sort = lowercase(sort)) ∈ ["lexicographic", "alphanumeric", "numeric", "strlen"] || error("Invalid sort value")
        limit === nothing || (isa(limit, Integer) && limit >= 0) || error("limit must be a non-negative integer")
        nothing_or_type(context, Dict)
        new("search", dataSource, intervals, query, granularity, filter, virtualColumns, Dict("type" => sort), limit, context)
    end
end
Search(
    ; dataSource, intervals, query,
    granularity=nothing, filter=nothing, virtualColumns=nothing, sort=nothing, limit=nothing, context=nothing
) = Search(
    dataSource, intervals, query;
    granularity, filter, virtualColumns, sort, limit, context
)

"""
    TimeBoundary(dataSource::DataSource; <keyword arguments>)

A method with all arguments as keyword arguments is also provided.

# Arguments
- bound::String = nothing
- filter::Filter = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- context::Dict = nothing
"""
mutable struct TimeBoundary <: Query
    queryType::String
    dataSource::DataSource
    bound
    filter
    virtualColumns
    context
    function TimeBoundary(dataSource; bound=nothing, filter=nothing, virtualColumns=nothing, context=nothing)
        bound === nothing || bound ∈ ["minTime", "maxTime"] || error("Invalid bound")
        nothing_or_type(filter, Filter)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        nothing_or_type(context, Dict)
        new("timeBoundary", dataSource, bound, filter, virtualColumns, context)
    end
end
TimeBoundary(; dataSource, bound=nothing, filter=nothing, virtualColumns=nothing, context=nothing) =
    TimeBoundary(dataSource; bound, filter, virtualColumns, context)

"""
    SegmentMetadata(dataSource::DataSource; <keyword arguments>)

A method with all arguments as keyword arguments is also provided.

# Arguments
- intervals::Vector{<:Interval} = nothing
- toInclude::Union{String, Vector{String}} = nothing
- merge::Bool = nothing
- analysisTypes::Vector{String} = nothing
- lenientAggregatorMerge::Bool = nothing
- virtualColumns::Vector{<:VirtualColumn} = nothing
- context::Dict = nothing
"""
mutable struct SegmentMetadata <: Query
    queryType::String
    dataSource::DataSource
    intervals
    toInclude
    merge
    analysisTypes
    lenientAggregatorMerge
    virtualColumns
    context
    function SegmentMetadata(
        dataSource; intervals=nothing, toInclude=nothing, merge=nothing,
        analysisTypes=nothing, lenientAggregatorMerge=nothing, virtualColumns=nothing, context=nothing
    )
        nothing_or_type(intervals, Vector{<:Interval})
        nothing_or_type(toInclude, Union{String, Vector{String}})
        nothing_or_type(merge, Bool)
        analysisTypes === nothing || (isa(analysisTypes, Vector{String}) &&
            all(at -> at ∈ ["cardinality", "minmax", "size", "interval", "timestampSpec", "queryGranularity", "aggregators", "rollup"], analysisTypes)) ||
            error("Invalid analysisTypes")
        nothing_or_type(lenientAggregatorMerge, Bool)
        nothing_or_type(virtualColumns, Vector{<:VirtualColumn})
        nothing_or_type(context, Dict)
        if isa(toInclude, String)
            toInclude ∈ ["all", "none"] || error("Invalid toInclude")
            toInclude = Dict("type" => toInclude)
        else
            toInclude = Dict("type" => "list", "columns" => toInclude)
        end
        new("segmentMetadata", dataSource, intervals, toInclude, merge, analysisTypes, lenientAggregatorMerge, virtualColumns, context)
    end
end
SegmentMetadata(
    ; dataSource, intervals=nothing, toInclude=nothing, merge=nothing,
    analysisTypes=nothing, lenientAggregatorMerge=nothing, virtualColumns=nothing, context=nothing
) = SegmentMetadata(
    dataSource; intervals, toInclude, merge,
    analysisTypes, lenientAggregatorMerge, virtualColumns, context
)

"""
    DatasourceMetadata(dataSource::DataSource; context=nothing)

context should be a Dict if provided.
"""
mutable struct DatasourceMetadata <: Query
    queryType::String
    dataSource::DataSource
    context
    function DatasourceMetadata(dataSource; context=nothing)
        nothing_or_type(context, Dict)
        new("dataSourceMetadata", dataSource, context)
    end
end
DatasourceMetadata(;dataSource, context=nothing) = DatasourceMetadata(dataSource; context)

"""
    Parameter(type::String, value)

SQL query parameter, where `type` is one of the Druid SQL data types and `value`
is the parameter value.
"""
struct Parameter
    type::String
    value
    function Parameter(type, value)
        type ∈ [
            "CHAR", "VARCHAR",
            "DECIMAL", "FLOAT", "REAL", "DOUBLE",
            "BOOLEAN", "TINYINT", "SMALLINT", "INTEGER", "BIGINT",
            "TIMESTAMP", "DATE", "OTHER"
        ] || error("Invalid 'type'")
        new(type, value)
    end
end
JSON.lower(p::Parameter) = non_nothing_dict(p)

"""
    Sql(query::String; <keyword arguments>)

A method with all arguments as keyword arguments is also provided.

# Arguments
- parameters::Vector{Parameter} = nothing
- resultFormat::String = nothing
- header::Bool = nothing
- context::Dict = nothing
"""
mutable struct Sql <: Query
    query::String
    parameters
    resultFormat
    header
    context
    function Sql(query; parameters=nothing, resultFormat=nothing, header=nothing, context=nothing)
        nothing_or_type(parameters, Vector{Parameter})
        resultFormat === nothing || resultFormat ∈ ["object", "array", "objectLines", "arrayLines", "csv"] || error("Invalid resultFormat")
        nothing_or_type(header, Bool)
        nothing_or_type(context, Dict)
        new(query, parameters, resultFormat, header, context)
    end
end
Sql(; query, parameters=nothing, resultFormat=nothing, header=nothing, context=nothing) =
    Sql(query; parameters, resultFormat, header, context)

query_type(::Sql) = "SQL"

"""
    execute(client, query; pretty=false)

Executes the native Druid `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.
"""
execute(client::Client, query::Query; pretty=false) = execute_native_query(client, query; pretty)

function execute_native_query(client::Client, query::Query; pretty=false)
    url = joinpath(client.url, "druid/v2")
    if pretty
        url = merge(url, query="pretty")
    end
    do_query(url, query)
end

"""
    execute(client, query::Sql)

Executes the Druid SQL `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.

# Examples
```julia-repl
julia> query = Sql("SELECT * FROM some_datasource LIMIT 10")
julia> execute(client, query)
"[...\\n]"

julia> query = Sql("SELECT * FROM non_existent_datasource")
julia> execute(client, query)
ERROR: Druid error during query execution
Dict{String,Any}("errorClass" => "org.apache.calcite.tools.ValidationException"...
```
"""
function execute(client::Client, query::Sql)
    url = joinpath(client.url, "druid/v2/sql")
    do_query(url, query)
end

function do_query(url, post_data)
    local response
    try
        response = request("POST", url, ["Content-Type" => "application/json"], json(post_data))
    catch err
        if isa(err, IOError)
            error("I/O Error during query execution")
        elseif isa(err, StatusError)
            local err_message
            try
                err_message = JSON.parse(String(err.response.body))
            catch
                error("Druid error during query execution, error message unavailable\n", "Error status: $(err.status)")
            end
            error("Druid error during query execution\n", err_message, "\nError status: $(err.status)")
        end
    end
    String(response.body)
end

function Base.show(io::IO, q::Query)
    print(io, query_type(q), '(')
    firstprint = true
    for fname in propertynames(q)
        val = getproperty(q, fname)
        if !(val === nothing)
            firstprint || print(io, ", ")
            if firstprint
                firstprint = false
            end
            print(io, fname, '=', repr(val, context=io))
        end
    end
    print(io, ')')
end
