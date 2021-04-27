module ParameterSweeps

using JSON
using DataFrames

function load_params(params_dict::Dict{Symbol,<:Any})
    filename = joinpath(prod(ARGS), "params.json")
    ispath(filename) && open(filename, "r") do f
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
    return Dict(Symbol(k)=>v for (k,v) in params)
end

function get_df(sim::String, cols::Symbol...)
    rfs = readdir(joinpath(sim,"rfs"))
    params = get_params.(sim,rfs)
    df = DataFrame(ID=rfs)
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
    return [filter(row->all(isequal(row[a],v) for (a,v) in zip(axes,vals)),df)
        for vals in Base.product(vars...)], collect(vars)
end

function get_by_rf(rf::String, data_file::String; parse=file->read(file), fun=identity)
    if ~isfile(joinpath("rfs",rf,data_file))
        return Missing
    end
    data = open(joinpath("rfs",rf,data_file)) do file
        parse(file)
    end
    return fun(data)
end

function get_first_by_df(df, data_file, parse, fun)
    return get_by_rf(df[1,:ID], data_file, parse, fun)
end

end # module
