"""
    Client

    Client(url::URIs.URI)
    Client(url::AbstractString)
    Client(host, port, endpoint, scheme)

Druid SQL query endpoint connection information store.

#Examples
```julia-repl
julia> client = Client("http://localhost:8888/druid/v2/sql")
Client(URI("http://localhost:8888/druid/v2/sql"))

julia> client = Client("localhost", 8082, "druid/v2/sql", "http")
Client(URI("http://localhost:8082/druid/v2/sql"))
```
"""
struct Client
    url::URI
end
Client(host, port, endpoint, scheme) = 
    Client(joinpath(URI(;scheme=scheme, host=host, port=port), endpoint))
Client(url::AbstractString) = Client(URI(url))
