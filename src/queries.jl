JSON.lower(q::Query) = non_nothing_dict(q)
query_type(q::Query) = q.queryType
JSON.lower(ls::LimitSpec) = non_nothing_dict(ls)
Tables.istable(::QueryResult) = true

include("timeseries.jl")
include("topn.jl")
include("groupby.jl")
include("scan.jl")
include("search.jl")
include("timeboundary.jl")
include("segment_metadata.jl")
include("datasource_metadata.jl")

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
