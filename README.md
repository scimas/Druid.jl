# Druid.jl

[Apache Druid](https://druid.apache.org) querying library.

## Installation
```julia
pkg> add Druid
```

## Usage

### Native Query
Druid native queries
[documentation](https://druid.apache.org/docs/latest/querying/querying.html)
```julia
using Druid

client = Client("http://localhost:8888")

timeseries_query = Timeseries(
    dataSource=Table("wikipedia"),
    intervals=[Interval("2015-09-12","2015-09-13")],
    granularity=SimpleGranularity("hour"),
    aggregations=[Count("total_rows"), SingleField("longSum", "added", "documents_added")]
)

println(execute(client, timeseries_query))
```

### SQL Query
Druid [SQL
documentation](https://druid.apache.org/docs/latest/querying/sql.html)
```julia
using Druid

client = Client("http://localhost:8888")

sql_query = Sql(query="""
    SELECT FLOOR(__time TO HOUR) AS "timestamp", COUNT(*) AS "total_rows", SUM("added") AS "documents_added"
    FROM wikipedia
    WHERE __time >= TIMESTAMP '2015-09-12' AND __time < TIMESTAMP '2015-09-13'
    GROUP BY FLOOR(__time TO HOUR)
    ORDER BY "timestamp" ASC
""")

println(execute(client, sql_query))
```

### Tables.jl compatibility
Most native queries return the query response as an object compatible with the
`Tables.jl` interface. So it is quite easy to convert the result into a
`DataFrame`.

```julia
result = execute(client, query)
df = DataFrame(result)
```

Compatible queries: `Timeseries`, `TopN`, `GroupBy`, `Scan`, `Search`.

`TimeBoundary`, `SegmentMetadata` and `DatasourceMetadata` return their results
as `Dict`s.

`Sql` query returns the result as a `String`. Supporting the `Tables.jl`
interface for SQL queries is planned.
