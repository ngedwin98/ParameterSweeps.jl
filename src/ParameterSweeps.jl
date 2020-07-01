module ParameterSweeps

function load_params(params_dict::Dict{Symbol,<:Number})
    length(ARGS) > 0 && open(path.join(ARGS[1],"params.json"), "r") do f
        json_dict = JSON.parse(f)
        for k in keys(params_dict)
            params_dict[k] = json_dict[String(k)]
        end
    end
    eval.(:($k = $v) for (k,v) in params_dict)
    return params_dict
end

end # module
