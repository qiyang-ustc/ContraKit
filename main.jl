using OMEinsum, OMEinsumContractionOrders, YAML, JSON

"""
    A helper function to eval value of String, from a given dict: locals
"""
function parse_eval_dict(s::AbstractString, locals)
    ex = Meta.parse(s)
    assignments = [:($(Symbol(sym)) = $val) for (sym,val) in locals]
    eval(:(let $(assignments...); $ex; end))
end

"""
    Transfer expression in edges to number.
"""
function eval_edges(edges_dict,variable_dict)
    results_dict = Dict()
    for key in keys(edges_dict)
        expression = edges_dict[key]
        if typeof(expression) == Int # need to eval:
            results_dict[key] = edges_dict[key]
        else
            results_dict[key] = parse_eval_dict(expression,variable_dict)
        end
    end
    return results_dict
end

function main(file, resfile; show_complexity=true)
    net = YAML.load_file(file)
    vertices = Dict{String,Vector}(net["vertices"])
    edges = Dict{Int,Int}(eval_edges(net["edges"],net["variables"])) # get number edges
    alg=TreeSA(sc_target=29, βs=0.1:0.1:20,ntrials=5, niters=30, sc_weight=2.0) # <<<<<<<<<Alg develop here>>>>>>>>>

    # generate eincode:
    tensor_names = reverse(collect(keys(vertices)))
    tensor_inds  = map(N -> Tuple(x for x in N), reverse(collect(values(vertices))))
    out_inds = Tuple(x for x in net["output"])
    code = EinCode((tensor_inds..., ), out_inds)

    # optimize eincode:
    optcode = optimize_code(code, edges, alg, MergeVectors())
    if show_complexity
        contraction_complexity(optcode, edges)
    end

    # write to YAML
    cache_json = "tmp.json"
    writejson(cache_json,optcode)
    einsrule = postprocess(cache_json)

    write_einsrule(resfile, einsrule, tensor_names)
end

function rename_tensor(id, tensor_names)
    return Tuple(x for x in [ i<0 ? i : tensor_names[i] for i in id])
end

function write_einsrule(resfile, einsrule, tensor_names)
    io = open(resfile, "w");
    for i = 1:length(einsrule)
        localeins = einsrule[i]
        eins, tensor_src, tensor_dst = localeins
        einsrc, eindst = eins

        print(io,"Step: $(i)\n")
        print(io,"    Eins:\n")
        print(io,"        Input: $(einsrc)\n")
        print(io,"        Output: $(eindst)\n")
        print(io,"\n")
        print(io,"    Tensors:\n")
        print(io,"        Input: $(rename_tensor(tensor_src,tensor_names))\n")
        print(io,"        Output: $(rename_tensor(tensor_dst,tensor_names))\n")
        print(io,"\n\n")
    end
    close(io)
end

function readeins(dict::Dict{String, Any})
    ixs, iy = map(N->Tuple(x for x in N),dict["ixs"]), Tuple(x for x in dict["iy"])
    return Tuple(x for x in ixs), iy
end

function postprocess(json_file)
    code = JSON.parsefile(json_file; dicttype=Dict, inttype=Int64, use_mmap=true) 
    
    einsrule = []
    add_aux_label(code["tree"],[-1])
    visit_leaf(einsrule,code["tree"])
    einsrule = reverse(einsrule)

    return einsrule
end

function add_aux_label(dict::Dict, unused_label)
    if dict["isleaf"]
        nothing
    else
        dict["tensorindex"] = unused_label[1]
        unused_label[1] = unused_label[1]-1
        for leaf in dict["args"]
            add_aux_label(leaf ,unused_label)
        end
    end
end

function visit_leaf(einsrule, dict)
    if dict["isleaf"]
        nothing
    else
        localeins = readeins(dict["eins"])
        source = [leaf["tensorindex"] for leaf in dict["args"]]
        push!(einsrule, (localeins,Tuple(x for x in source),dict["tensorindex"]))
        for leaf in dict["args"]
            visit_leaf(einsrule, leaf)
        end
    end
end


function load_order(file)
    nothing
end

function write_order(file)
    nothing
end

function load_alg(file)
    nothing
end

# resfile = "./examples/res.yaml"
# file = "./examples/net.yaml"

main(ARGS[1], ARGS[2]; show_complexity=true)