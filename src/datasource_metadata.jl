"""
    DatasourceMetadata(dataSource::DataSource; context=nothing)

Returns a Dict{String, String} with "timestamp" and "maxIngestedEventTime" as
keys.

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

function execute(client::Client, query::DatasourceMetadata; pretty=false)
    res = JSON.parse(execute_native_query(client, query; pretty))
    d = Dict{String, String}()
    d["timestamp"] = res[1]["timestamp"]
    d["maxIngestedEventTime"] = res[1]["result"]["maxIngestedEventTime"]
    d
end
