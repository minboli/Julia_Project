using Markdown
using InteractiveUtils
using PowerModelsDistribution
using Ipopt
function calculate_pq_in_IEEE_13_bus_system(file_path::String)
    # pmd_path = joinpath(dirname(pathof(PowerModelsDistribution)), "..")
    ipopt_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6, "print_level"=>0)
    eng = parse_file(file_path; import_all=true)
    for bus_numer in eng["load"]
        eng["load"][bus_numer]["dss"]["kw"] = 2 .* eng["load"][bus_numer]["dss"]["kw"]
        eng["load"][bus_numer]["dss"]["kv"] = 2 .* eng["load"][bus_numer]["dss"]["kv"]
        eng["load"][bus_numer]["dss"]["kvar"] = 2 .* eng["load"][bus_numer]["dss"]["kvar"]
    end
    for capacitor_num in eng["shunt"]
        eng["shunt"]["capcitor_num"]["dss"]["kv"] = 2 .* eng["shunt"]["capcitor_num"]["dss"]["kv"]
        eng["shunt"]["capcitor_num"]["dss"]["kvar"] = 2 .* eng["shunt"]["capcitor_num"]["dss"]["kvar"]
    result = solve_mc_opf(eng, ACPUPowerModel, ipopt_solver)
    print(eng)
end

printIn(calculate_pq_in_IEEE_13_bus_system("C:/Users/minboli/Desktop/IEEE 13 Bus Data/IEEE13_Assets.dss"))



# [ PowerModelsDistribution | Info ] : basemva=100 is the default value, you may want to adjust sbase_default for better convergence
# Dict{String, Any} with 13 entries:
#   "xfmrcode"       => Dict{String, Any}("regleg"=>Dict{String, Any}("sm_ub"=>2499.0, "source_id"=>"xfmrcode.regleg", "sm_nom"=>[1666.0, 1666.0], "tm_fix"=>Vector{Bool}[[1], [1]], "…
#   "conductor_ids"  => [1, 2, 3, 4]
#   "bus"            => Dict{String, Any}("671"=>Dict{String, Any}("rg"=>Float64[], "grounded"=>Int64[], "status"=>ENABLED, "terminals"=>[1, 2, 3], "xg"=>Float64[]), "680"=>Dict{Stri…
#   "name"           => "ieee13nodecktassets"
#   "settings"       => Dict{String, Any}("sbase_default"=>100000.0, "vbases_default"=>Dict{String, Real}("sourcebus"=>66.3953), "voltage_scale_factor"=>1000.0, "power_scale_factor"=…
#   "files"          => ["C:/Users/limin/Desktop/IEEE 13 Bus Data/IEEE13_Assets.dss"]
#   "switch"         => Dict{String, Any}("671692"=>Dict{String, Any}("cm_ub"=>[600.0, 600.0, 600.0], "xs"=>[0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0], "f_connections"=>[1, 2, 3], "stat…
#   "voltage_source" => Dict{String, Any}("source"=>Dict{String, Any}("source_id"=>"vsource.source", "rs"=>[0.166786 0.00640897 0.00640897 0.00640897; 0.00640897 0.166786 0.00640897 …
#   "line"           => Dict{String, Any}("632670"=>Dict{String, Any}("cm_ub"=>[600.0, 600.0, 600.0], "xs"=>[0.000653882 0.000299058 0.000241464; 0.000299058 0.000632756 0.000273149;…
#   "data_model"     => ENGINEERING
#   "transformer"    => Dict{String, Any}("xfm1"=>Dict{String, Any}("source_id"=>"transformer.xfm1", "polarity"=>[1, 1], "xfmrcode"=>"fdrxfmr", "status"=>ENABLED, "connections"=>[[1,…
#   "shunt"          => Dict{String, Any}("cap1"=>Dict{String, Any}("source_id"=>"capacitor.cap1", "status"=>ENABLED, "model"=>CAPACITOR, "connections"=>[1, 2, 3], "controls"=>Dict{S…
#   "load"           => Dict{String, Any}("634a"=>Dict{String, Any}("source_id"=>"load.634a", "qd_nom"=>[110.0], "status"=>ENABLED, "model"=>POWER, "connections"=>[1, 4], "vm_nom"=>0…
