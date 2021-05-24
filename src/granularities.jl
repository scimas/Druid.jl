JSON.lower(::Granularity) = error("Unknown granularity")

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
    DurationGranularity(duration::UInt64; origin)

Duration type granularity where the duration is specified as milliseconds since
origin.

Specifying origin is not required (defaults to Druid's default), but should be a
ISO8601 datetime string if you do specify it.
"""
struct DurationGranularity <: Granularity
    duration::UInt64
    origin
end

DurationGranularity(duration; origin=nothing) = DurationGranularity(duration, origin)

function JSON.lower(dg::DurationGranularity)
    d = Dict()
    d["type"] = "duration"
    d["duration"] = dg.duration
    if !(dg.origin === nothing)
        d["origin"] = dg.origin
    end
    d
end

"""
    PeriodGranularity(period::String; origin, timezone)

Period type granularity where the period is specified as an ISO8601 period
string. Period starts on origin in the timezone.

Specifying origin and timezone is not required (defaults to Druid's default).
But if you do specify them, origin should be a ISO8601 datetime string and
timezone should be one of those [supported by
Druid](https://druid.apache.org/docs/latest/querying/granularities.html#supported-time-zones).
"""
struct PeriodGranularity <: Granularity
    period::String
    origin
    timezone
end

PeriodGranularity(period; origin=nothing, timezone=nothing) = PeriodGranularity(period, origin, timezone)

function JSON.lower(pg::PeriodGranularity)
    d = Dict()
    d["type"] = "period"
    d["period"] = pg.period
    if !(pg.origin === nothing)
        d["origin"] = pg.origin
    end
    if !(pg.timezone === nothing)
        d["timeZone"] = pg.timezone
    end
    d
end
