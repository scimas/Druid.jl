JSON.lower(d::DataSource) = non_nothing_dict(d)

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
    Join(left::Union{Table, Lookup, Inline, QuerySource, Join},
        right::Union{Lookup, Inline, QuerySource}, rightPrefix::String,
        condition::String, joinType::String)

Join datasource.
"""
struct Join <: DataSource
    type::String
    left::Union{Table, Lookup, Inline, QuerySource, Join}
    right::Union{Lookup, Inline, QuerySource}
    rightPrefix::String
    condition::String
    joinType::String
    function Join(left, right, rightPrefix, condition, joinType)
        uppercase(joinType) ∈ ["INNER", "LEFT"] || error("Invalid joinType")
        new("join", left, right, rightPrefix, condition, uppercase(joinType))
    end
end
