@hl mutable struct MasterColumn <: Variable
    solution::PrimalSolution

    # ```
    # Determines whether this column was generated by a subproblem with the
    # "enumerated" status. This flag may have an impact on the column
    # coefficients in master cuts.
    # ```
    enumerated_flag::Bool

    # ```
    # Flag telling whether or not the column is part of the convexity constraint.
    # ```
    belongs_to_convexity_constraint::Bool
end

# function VariableBuilder(counter::VarConstrCounter, name::String, 
#         costrhs::Float64, sense::Char, vc_type::Char, flag::Char, directive::Char, 
#         priority::Float64, lowerBound::Float64, upperBound::Float64)

function build_memberships(col::MasterColumn)
    for (var, val) in col.solution.var_val_map
        for (constr, coef) in var.master_constr_coef_map
            if constr.status == Active
                add_membership(col, constr, val * coef)
            end
        end
        var.master_col_coef_map[col] = val
    end
end

function MasterColumnBuilder(counter::VarConstrCounter, 
                             sp_sol::PrimalSolution) where P
    cost = compute_original_cost(sp_sol)
    return tuplejoin(VariableBuilder(counter, string("MC", counter.value), 
            cost, 'P', 'I', 'd', 'D', -1.0, 0.0, Inf),
            sp_sol, false #= enumeration not supported =#, true)
         
    #TODO add membership using sp_sol        
end

function MasterColumnConstructor(counter::VarConstrCounter, 
                                 sp_sol::PrimalSolution) where P
    col = MasterColumn(counter, sp_sol)
    build_memberships(col)
    return col
end
