JSON.lower(hf::HavingSpec) = non_nothing_dict(hf)

struct EqualTo <: HavingSpec
    type::String
    aggregation::String
    value::Real
    EqualTo(aggregation, value) = new("equalTo", aggregation, value)
end

struct GreaterThan <: HavingSpec
    type::String
    aggregation::String
    value::Real
    GreaterThan(aggregation, value) = new("greaterThan", aggregation, value)
end

struct LessThan <: HavingSpec
    type::String
    aggregation::String
    value::Real
    LessThan(aggregation, value) = new("lessThan", aggregation, value)
end

struct DimSelector <: HavingSpec
    type::String
    dimension::String
    value
    DimSelector(dimension, value) = new("dimSelector", dimension, value)
end

struct AndH <: HavingSpec
    type::String
    havingSpecs::Vector{HavingSpec}
    AndH(havingSpecs) = new("and", havingSpecs)
end

struct OrH <: HavingSpec
    type::String
    havingSpecs::Vector{HavingSpec}
    OrH(havingSpecs) = new("or", havingSpecs)
end

struct NotH <: HavingSpec
    type::String
    havingSpec::HavingSpec
    NotH(havingSpec) = new("not", havingSpec)
end
