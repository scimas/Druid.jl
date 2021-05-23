struct Table <: DataSource
    name::String
end

struct Lookup <: DataSource
    name::String
end

struct Unioned <: DataSource
    names::Vector{String}
end

struct Inline <: DataSource
    columns::Vector{String}
    rows::Vector{Vector{Any}}
end

struct QuerySource <: DataSource
    query::Query
end

abstract type JoinType end
struct INNER <: JoinType end
struct LEFT <: JoinType end

JSON.lower(j::JoinType) = error("Unknowns JoinType ", typeof(j), ". Implement JSON.lower for it.")
JSON.lower(::INNER) = "INNER"
JSON.lower(::LEFT) = "LEFT"

struct Join <: DataSource
    left::Union{Table, Lookup, Inline, QuerySource, Join}
    right::Union{Lookup, Inline, QuerySource}
    rightPrefix::String
    condition::String
    joinType::JoinType
end

JSON.lower(d::DataSource) = error("Unknown DataSource ", typeof(d), ". Implement JSON.lower for it.")
JSON.lower(t::Table) = Dict("type" => "table", "name" => t.name)
JSON.lower(l::Lookup) = Dict("type" => "lookup", "lookup" => l.name)
JSON.lower(u::Unioned) = Dict("type" => "union", "dataSources" => u.names)
JSON.lower(i::Inline) = Dict("type" => "inline", "columnNames" => i.columns, "rows" => i.rows)
JSON.lower(q::QuerySource) = Dict("type" => "query", "query" => q.query)
JSON.lower(j::Join) = Dict(
    "type" => "join",
    "left" => j.left, "right" => j.right, "rightPrefix" => j.rightPrefix,
    "condition" => j.condition, "joinType" => j.joinType
)
