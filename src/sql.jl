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
- header::Bool = true
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

struct SqlResult{ResultFormat} <: QueryResult
    names::Vector{Symbol}
    inner_data::ResultFormat
end

Tables.istable(::SqlResult) = false

struct SqlRow{T} <: Tables.AbstractRow
    row::Int
    source::SqlResult{T}
end

# resultFormat = "object", "objectLines"
Tables.istable(::SqlResult{Vector{Dict{String, T}}}) where {T} = true
names(sr::SqlResult{Vector{Dict{String, T}}}) where {T} = getfield(sr, :names)

Base.summary(io::IO, sr::SqlResult{Vector{Dict{String, T}}}) where {T} = print(io, string(length(sr)) * "-element " * string(typeof(sr)))
Base.getindex(sr::SqlResult{Vector{Dict{String, T}}}, i::Int) where {T} = (i <= length(sr) || throw(BoundsError(sr, i))) && SqlRow(i, sr)

Tables.rowaccess(::SqlResult{Vector{Dict{String, T}}}) where {T} = true
Tables.rows(sr::SqlResult{Vector{Dict{String, T}}}) where {T} = sr

Base.eltype(::SqlResult{Vector{Dict{String, T}}}) where {T} = SqlRow{Vector{Dict{String, T}}}
Base.length(sr::SqlResult{Vector{Dict{String, T}}}) where {T} = length(getfield(sr, :inner_data))
Base.iterate(sr::SqlResult{Vector{Dict{String, T}}}, state=1) where {T} = state > length(sr) ? nothing : (SqlRow(state, sr), state + 1)

function Tables.schema(sr::SqlResult{Vector{Dict{String, T}}}) where {T}
    if length(sr) != 0
        types = [typeof(cl) for cl in sr[1]]
    else
        types = DataType[]
    end
    Tables.Schema(names(sr), types)
end

Tables.getcolumn(sr::SqlRow{Vector{Dict{String, T}}}, name::Symbol) where {T} = getfield(getfield(sr, :source), :inner_data)[getfield(sr, :row)][string(name)]
Tables.getcolumn(sr::SqlRow{Vector{Dict{String, T}}}, i::Int) where {T} = Tables.getcolumn(sr, names(getfield(sr, :source))[i])
Tables.columnnames(sr::SqlRow{Vector{Dict{String, T}}}) where {T} = names(getfield(sr, :source))

function transform_result(res, header, ::Val{:object}; names=:auto)
    local interm
    try
        interm = JSON.parse(res)
    catch e
        println("Corrupted response received from Druid, unable to parse")
        rethrow(e)
    end
    d = convert(Vector{Dict{String, Any}}, interm)
    if names == :auto
        if header == true
            names = Symbol.(keys(popfirst!(d)))
        elseif length(d) != 0
            names = Symbol.(keys(d[1]))
        else
            names = Symbol[]
        end
    end
    SqlResult(names, d)
end

function transform_result(res, header, ::Val{:objectLines}; names=:auto)
    length(res) >= 2 && res[end - 1:end] == "\n\n" || error("Corrupted response received from Druid, unable to parse")
    interm = strip(res)
    if interm == ""
        d = Dict{String, Any}[]
    else
        d = JSON.parse.(split(interm, '\n'))
    end
    if names == :auto
        if header == true
            names = Symbol.(keys(popfirst!(d)))
        elseif length(d) != 0
            names = Symbol.(keys(d[1]))
        else
            names = Symbol[]
        end
    end
    SqlResult(names, d)
end

# resultFormat = "array", "arrayLines"
Tables.istable(::SqlResult{Matrix{T}}) where {T} = true
names(sr::SqlResult{Matrix{T}}) where {T} = getfield(sr, :names)

Base.summary(io::IO, sr::SqlResult{Matrix{T}}) where {T} = print(io, string(length(sr)) * "-element " * string(typeof(sr)))
Base.getindex(sr::SqlResult{Matrix{T}}, i::Int) where {T} = (i <= length(sr) || throw(BoundsError(sr, i))) && SqlRow(i, sr)

Tables.rowaccess(::SqlResult{Matrix{T}}) where {T} = true
Tables.rows(sr::SqlResult{Matrix{T}}) where {T} = sr

Base.eltype(::SqlResult{T}) where {T<:Matrix} = SqlRow{T}
Base.length(sr::SqlResult{Matrix{T}}) where {T} = size(getfield(sr, :inner_data), 1)
Base.iterate(sr::SqlResult{Matrix{T}}, state=1) where {T} = state > length(sr) ? nothing : (SqlRow(state, sr), state + 1)

function Tables.schema(sr::SqlResult{Matrix{T}}) where {T}
    if length(sr) != 0
        types = [typeof(cl) for cl in sr[1]]
    else
        types = DataType[]
    end
    Tables.Schema(names(sr), types)
end

Tables.getcolumn(sr::SqlRow{Matrix{T}}, i::Int) where {T} = getfield(getfield(sr, :source), :inner_data)[getfield(sr, :row), i]
Tables.getcolumn(sr::SqlRow{Matrix{T}}, name::Symbol) where {T} = Tables.getcolumn(sr, findfirst(name .== names(getfield(sr, :source))))
Tables.columnnames(sr::SqlRow{Matrix{T}}) where {T} = names(getfield(sr, :source))

function transform_result(res, header, ::Val{:array}; names=:auto)
    local interm
    try
        interm = JSON.parse(res)
    catch e
        println("Corrupted response received from Druid, unable to parse")
        rethrow(e)
    end
    if names == :auto
        if header == true
            names = Symbol.(popfirst!(interm))
        elseif length(interm) != 0
            names = [Symbol("Column" * string(i)) for i ∈ 1:length(interm[1])]
        else
            names = Symbol[]
        end
    end
    if interm == []
        d = Matrix{Any}(undef, 0, 0)
    else
        d = permutedims(reduce(hcat, interm))
    end
    SqlResult(names, d)
end

function transform_result(res, header, ::Val{:arrayLines}; names=:auto)
    length(res) >= 2 && res[end - 1:end] == "\n\n" || error("Corrupted response received from Druid, unable to parse")
    stripped = strip(res)
    if stripped == ""
        interm = Vector{Any}[]
    else
        interm = JSON.parse.(split(stripped, '\n'))
    end
    if names == :auto
        if header == true
            names = Symbol.(popfirst!(interm))
        elseif length(interm) != 0
            names = [Symbol("Column" * string(i)) for i ∈ 1:length(interm[1])]
        else
            names = Symbol[]
        end
    end
    if interm == []
        d = Matrix{Any}(undef, 0, 0)
    else
        d = permutedims(reduce(hcat, interm))
    end
    SqlResult(names, d)
end

# resultFormat = "csv"
function transform_result(res, header, ::Val{:csv}; names=:auto)
    (length(res) >= 2 && res[end - 1:end] == "\n\n") || 
        (length(res) == 1 && res[end] == '\n') || error("Corrupted response received from Druid, unable to parse")
    if names == :auto
        if header == true
            return CSV.File(IOBuffer(res); header)
        else
            return CSV.File(IOBuffer(res); header=false)
        end
    else
        return CSV.File(IOBuffer(res); header=names)
    end
end

"""
    execute(client, query::Sql; names=:auto)

Executes the Druid SQL `query` on the `client::Client`. Returns the query
results as a String. Throws exception if query execution fails.

A Vector{Symbol} can be provided for the column names through `names`.

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
function execute(client::Client, query::Sql, names=:auto)
    names == :auto || typeassert(names, Vector{Symbol})
    url = joinpath(client.url, "druid/v2/sql")
    header = query.header == true
    if query.resultFormat === nothing
        resultFormat = "object"
    else
        resultFormat = query.resultFormat
    end
    transform_result(do_query(url, query), header, Val(Symbol(resultFormat)); names=names)
end
