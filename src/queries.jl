DataSourceType = Union{AbstractString,Dict{T,U}} where {T<:AbstractString, U}
IntervalType = Union{AbstractString,Tuple{AbstractString,AbstractString}}

abstract type Query end

mutable struct Timeseries <: Query
end

mutable struct TopN <: Query
end

mutable struct GroupBy <: Query
end

mutable struct Scan <: Query
end

mutable struct Search <: Query
end

mutable struct TimeBoundary <: Query
end

mutable struct SegmentMetadata <: Query
end

mutable struct DatasourceMetadata <: Query
end

mutable struct Sql <: Query
end

query_type(q) = error("Unknown query type. Please implement `query_type` for ", typeof(q))
query_type(::Timeseries) = "timeseries"
query_type(::TopN) = "topN"
query_type(::GroupBy) = "groupBy"
query_type(::Scan) = "scan"
query_type(::Search) = "search"
query_type(::TimeBoundary) = "timeBoundary"
query_type(::SegmentMetadata) = "segmentMetadata"
query_type(::DatasourceMetadata) = "dataSourceMetadata"
