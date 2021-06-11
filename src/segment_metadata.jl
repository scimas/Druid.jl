"""
    SegmentMetadata(dataSource::DataSource; <keyword arguments>)

Returns a Dict with the query output.

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

function execute(client::Client, query::SegmentMetadata; pretty=false)
    res = JSON.parse(execute_native_query(client, query; pretty))
    res[1]
end
