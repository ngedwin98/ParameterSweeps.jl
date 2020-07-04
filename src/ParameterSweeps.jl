module ParameterSweeps

using JSON

function load_params(params_dict::Dict{Symbol,<:Number})
    length(ARGS) > 0 && open(joinpath(ARGS[1],"params.json"), "r") do f
        json_dict = JSON.parse(f)
        for k in keys(params_dict)
            params_dict[k] = json_dict[String(k)]
        end
    end
    for (k,v) in params_dict
        Core.eval(Main, :($k = $v))
    end
    return params_dict
end

function get_params(sim::String, rf::String)
    params = JSON.parsefile(joinpath(sim,"rfs",rf,"params.json"))
    return Dict{Symbol,Number}(Symbol(k)=>v for (k,v) in params)
end

function get_df(sim::String, cols::Symbol...)
    rfs = readdir(joinpath(sim,"rfs"))
    params = get_params.(sim,rfs)
    df = DataFrame(ID=rfs)
    if isempty(cols)
        cols = keys(first(params))
    end
    for c in cols
        df[!,c] = getindex.(params,c)
    end
    return df
end

function convert_col!(df::DataFrame, col::Symbol, col_type::DataType)
    df[!,col] .= convert.(col_type, df[!,col])
    return df
end

function slice_df(df::DataFrame, axes::Symbol...)
    df = sort(df, reverse(collect(axes)))
    vars = (unique(df[!,a]) for a in axes)
    return [filter(row->all(row[a]≈v for (a,v) in zip(axes,vals)),df)
        for vals in Base.product(vars...)], collect(vars)
end

end # module
