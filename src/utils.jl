"Convert a structure into a Dict but only with the properties with non-nothing values."
function non_nothing_dict(s, d::Dict)
    for fname ∈ propertynames(s)
        val = getproperty(s, fname)
        if !(val === nothing)
            d[fname] = val
        end
    end
    d
end
non_nothing_dict(s) = non_nothing_dict(s, Dict())

function nothing_or_type(var, type)
    var === nothing || typeassert(var, type)
    true
end
