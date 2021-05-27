"""
    Interval(first::String, last::String)

A type to represent ISO8601 intervals.
"""
struct Interval
    first::String
    last::String
end

JSON.lower(i::Interval) = i.first * '/' * i.last
