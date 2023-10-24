function Load_Battery_1phase_delta(Capacity,Soc,N_num,eff_ch,eff_dis,N_bat)

    Bat_aggr_1d_Capacity = Float64[]
    Bat_aggr_1d_DSS_node = Float64[]
    Bat_aggr_1d_soc = Float64[]
    Bat_aggr_1d_eff_ch = Float64[]
    Bat_aggr_1d_eff_dis = Float64[]
    Bat_aggr_1d_number = Float64[]

    push!(Bat_aggr_1d_Capacity, Capacity)
    push!(Bat_aggr_1d_DSS_node, N_num)
    push!(Bat_aggr_1d_soc, Soc)
    push!(Bat_aggr_1d_eff_ch,eff_ch)
    push!(Bat_aggr_1d_eff_dis,eff_dis)
    push!(Bat_aggr_1d_number,N_bat)

    return Bat_aggr_1d_Capacity, Bat_aggr_1d_DSS_node, Bat_aggr_1d_soc,Bat_aggr_1d_eff_ch,Bat_aggr_1d_eff_dis,Bat_aggr_1d_number
end
