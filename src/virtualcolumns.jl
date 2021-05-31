JSON.lower(vc::VirtualColumn) = non_nothing_dict(vc)

"""
    Expression(name::String, expression::String; outputType=nothing)

Create a virtual column using `expression`.

outputType should be String if provided.
"""
struct Expression <: VirtualColumn
    type::String
    name::String
    expression::String
    outputType
    function Expression(name, expression; outputType=nothing)
        outputType === nothing ||
            (outputType = uppercase(outputType)) ∈ ["LONG", "FLOAT", "DOUBLE", "STRING"] ||
            error("Invalid outputType")
        new("expression", name, expression, outputType)
    end
end
