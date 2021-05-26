"""
    Table(name::String)

Table datasource.
"""
struct Table <: DataSource
    type::String
    name::String
    Table(name) = new("table", name)
end

"""
    Lookup(name::String)

Lookup datasource.
"""
struct Lookup <: DataSource
    type::String
    lookup::String
    Lookup(name) = new("lookup", name)
end

"""
    Unioned(names::Vector{String})

Union of table datasources.
"""
struct Unioned <: DataSource
    type::String
    dataSources::Vector{String}
    Unioned(names) = new("union", names)
end

"""
    Inline(column_names::Vector{String}, rows::Vector{Vector{T}})

Inline datasource.
"""
struct Inline <: DataSource
    type::String
    columnNames::Vector{String}
    rows::Vector{Vector{Any}}
    Inline(column_names, rows) = new("inline", column_names, rows)
end

"""
    QuerySource(query::Query)

Query datasource.
"""
struct QuerySource <: DataSource
    type::String
    query::Query
    QuerySource(query) = new("query", query)
end

"""
    INNER()

INNER join type.
"""
struct INNER <: JoinType end

"""
    LEFT()

LEFT join type.
"""
struct LEFT <: JoinType end

JSON.lower(::JoinType) = error("Unknown JoinType")
JSON.lower(::INNER) = "INNER"
JSON.lower(::LEFT) = "LEFT"

"""
    Join(left::Union{Table, Lookup, Inline, QuerySource, Join},
        right::Union{Lookup, Inline, QuerySource}, rightPrefix::String,
        condition::String, joinType::JoinType)

Join datasource.
"""
struct Join <: DataSource
    type::String
    left::Union{Table, Lookup, Inline, QuerySource, Join}
    right::Union{Lookup, Inline, QuerySource}
    rightPrefix::String
    condition::String
    joinType::JoinType
    Join(left, right, rightPrefix, condition, joinType) = new("join", left, right, rightPrefix, condition, joinType)
end

JSON.lower(d::DataSource) = non_nothing_dict(d)
