"""
    Druid

A Druid SQL querying library.

See also: [Client](@ref), [execute](@ref)
"""
module Druid
using URIs:URI
using HTTP: request, IOError, StatusError
using JSON: json, parse
using JSONTables:jsontable

export Client, execute

"""
    Client

Druid SQL query endpoint connection information store.
"""
struct Client
    url::URI
end
Client(host, port, endpoint, scheme) = 
    Client(joinpath(URI(;scheme=scheme, host=host, port=port), endpoint))

"""
    execute(client, query)

Executes the Druid SQL `query` on the `client::Client`. Returns a `JSONTable` -
compatible with Tables.jl interface.
"""
function execute(client::Client, query)
    post_data = Dict("query" => query)
    response = try
        request("POST", client.url, ["Content-Type" => "application/json"], json(post_data))
    catch err
        if isa(err, IOError)
            println("I/O Error happened during query execution")
            println(err.e)
            throw(Base.IOError)
        elseif isa(err, StatusError)
            if err.status ÷ 100 == 5
                err_message = try
                    parse(String(err.response.body))
                catch _e
                    println("Druid error during query execution, error message unavailable")
                    println("Query: ", query)
                    throw(Base.IOError)
                end
                println("Failed Query: ", query)
                println(err_message)
                throw(ErrorException("Couldn't execute query"))
            throw(ErrorException("Query failed with status $(err.status)"))
            end
        end
    end
    jsontable(response.body)
end

end # module
