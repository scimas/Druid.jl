JSON.lower(hf::HavingSpec) = non_nothing_dict(hf)

"""
    EqualTo(aggregation::String, value::Real)

aggregation = value filter.
"""
struct EqualTo <: HavingSpec
    type::String
    aggregation::String
    value::Real
    EqualTo(aggregation, value) = new("equalTo", aggregation, value)
end

"""
    GreaterThan(aggregation::String, value::Real)

aggregation >= value filter.
"""
struct GreaterThan <: HavingSpec
    type::String
    aggregation::String
    value::Real
    GreaterThan(aggregation, value) = new("greaterThan", aggregation, value)
end

"""
    LessThan(aggregation::String, value::Real)

aggregation <= value filter.
"""
struct LessThan <: HavingSpec
    type::String
    aggregation::String
    value::Real
    LessThan(aggregation, value) = new("lessThan", aggregation, value)
end

"""
    DimSelector(dimension::String, value)

dimension = value filter.
"""
struct DimSelector <: HavingSpec
    type::String
    dimension::String
    value
    DimSelector(dimension, value) = new("dimSelector", dimension, value)
end

"""
    AndH(havingSpecs::Vector{HavingSpec})

Match all `havingSpecs`.
"""
struct AndH <: HavingSpec
    type::String
    havingSpecs::Vector{<:HavingSpec}
    AndH(havingSpecs) = new("and", havingSpecs)
end

"""
    OrH(havingSpecs::Vector{HavingSpec})

Match at leats one of the `havingSpecs`.
"""
struct OrH <: HavingSpec
    type::String
    havingSpecs::Vector{<:HavingSpec}
    OrH(havingSpecs) = new("or", havingSpecs)
end

"""
    NotH(havingSpec::HavingSpec)

Do not match the `havingSpec`.
"""
struct NotH <: HavingSpec
    type::String
    havingSpec::HavingSpec
    NotH(havingSpec) = new("not", havingSpec)
end
