JSON.lower(g::Granularity) = non_nothing_dict(g)

"""
    SimpleGranularity(name::String)

One of the simple predefined granularities of Druid.
"""
struct SimpleGranularity <: Granularity
    name::String
    function SimpleGranularity(name)
        name = lowercase(name)
        name ∈ [
            "all", "none", "second", "minute", "fifteen_minute", "thirty_minute",
            "hour", "day", "week", "month", "quarter", "year"
        ] || error("Unknown type of simple granularity")
        new(name)
    end
end

JSON.lower(sg::SimpleGranularity) = sg.name

"""
    DurationGranularity(duration::UInt64; origin=nothing)

Duration type granularity where the duration is specified as milliseconds since
origin.

Specifying origin is not required (defaults to Druid's default), but should be a
ISO8601 datetime string if you do specify it.
"""
struct DurationGranularity <: Granularity
    type::String
    duration::UInt64
    origin
    function DurationGranularity(duration; origin=nothing)
        nothing_or_type(origin, String)
        new("duration", duration, origin)
    end
end

"""
    PeriodGranularity(period::String; origin=nothing, timezone=nothing)

Period type granularity where the period is specified as an ISO8601 period
string. Period starts on origin in the timezone.

Specifying origin and timezone is not required (defaults to Druid's default).
But if you do specify them, origin should be a ISO8601 datetime string and
timezone should be one of those [supported by
Druid](https://druid.apache.org/docs/latest/querying/granularities.html#supported-time-zones).
"""
struct PeriodGranularity <: Granularity
    type::String
    period::String
    origin
    timeZone
    function PeriodGranularity(period; origin=nothing, timezone=nothing)
        nothing_or_type(origin, String)
        nothing_or_type(timezone, String)
        new("period", period, origin, timezone)
    end
end
