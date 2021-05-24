struct Interval
    first::String
    last::String
end

JSON.lower(i::Interval) = i.first * '/' * i.last
