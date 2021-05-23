"""
    Client

    Client(url::URIs.URI)
    Client(url::AbstractString)
    Client(host, port, scheme)

Druid queryable host connection information store.

Do not provide the endpoint, it will be set based on the type of query. For
example, "druid/v2/sql" for SQL queries and "druid/v2" for all other queries.

# Examples
```julia-repl
julia> client = Client("http://localhost:8888/")
Client(URI("http://localhost:8888/"))

julia> client = Client("localhost", 8082, "http")
Client(URI("http://localhost:8082"))
```
"""
struct Client
    url::URI
end
Client(host, port, scheme) = 
    Client(URI(;scheme=scheme, host=host, port=port))
Client(url::AbstractString) = Client(URI(url))
