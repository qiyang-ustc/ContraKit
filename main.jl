using OMEinsum, OMEinsumContractionOrders, Yaml

function load_graphs(file)

end

function load_order(file)
    
end

function random_regular_eincode(n, k; optimize=nothing)
            g = Graphs.random_regular_graph(n, k)
            ixs = [minmax(e.src,e.dst) for e in Graphs.edges(g)]
            return EinCode((ixs..., [(i,) for i in     Graphs.vertices(g)]...), ())
           end

code = random_regular_eincode(220, 3);

optcode_tree = optimize_code(code, uniformsize(code, 2), TreeSA(sc_target=29, βs=0.1:0.1:20,
                                                             ntrials=5, niters=30, sc_weight=2.0));

timespace_complexity(optcode_tree, uniformsize(code, 2))

writejson("tensornetwork_permutation_optimized.json", optcode_tree)