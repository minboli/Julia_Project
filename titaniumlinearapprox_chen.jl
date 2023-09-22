using MAT
using LinearAlgebra
include("blockdiag.jl")
function TitaniumLinearApprox_v1(x, Vref, V0, Y_net)
    The_File_Path_Of_titaniumlinearapprox_chen = "C:\\Users\\minboli\\Desktop\\matlab data\\Xincode\\Xincode\\Titanium_nodes_Y.mat"
    vars = matread(The_File_Path_Of_titaniumlinearapprox_chen)
    Nnode = floor(max(vars[Seq_numbers]))
    Y_net_reshaped = reshape(vars["Y_net"], 369 , 369)
    rows, cols = size(Y_net_reshaped)
    NmultiNode = rows
    YLL = Y_net_reshaped[4:rows,4:cols]
    Y00 = Y_net_reshaped[1:3,1:3]
    Y0L = Y_net_reshaped[1:3,4:cols]
    YL0 = Y_net_reshaped[4:rows,1:3]
    YLLi = inv(YLL)
    w = -YLLi*YL0*V0
    Seq_numbers_round = floor.(Seq_numbers)
    N = size(Swye_DSS,1)
    Gamma = [1 -1 0; 0 1 -1; -1 0 1]
    H = []
    index_max = max(Seq_numbers_round)
    node_sequence = zeros(index_max)
    k=1 
    for i in 4:N
        if Seq_numbers_round[i] != Seq_numbers_round[i-1]
            node_sequence[k] = Seq_numbers_round[i]
            k += 1
        end
    end
    node_num = length(node_sequence)
    find_indices(arr, val) = findall(x -> x == val, arr)
    for ii in 1:node_num
        point_ii = Seq_numbers[find_indices(Seq_numbers_round, node_sequence[ii])]
        point_ii = round.(mod.(point_ii, 1) * 10)
        if length(point_ii) == 3
            gamma_temp = Gamma
        elseif length(point_ii) == 2
            gamma_temp = [1, -1]
        elseif length(point_ii) == 1
            gamma_temp = [1]
        else
            print("something wrong with H matrix construction")
        end
        H = block_diag(H,gamma_temp)
    end 
    G_matrix = zeros(3, NmultiNode - 3)
    for i = 4:NmultiNode
        phase = (Seq_numbers[i] - Seq_numbers_round[i]) * 10
        if phase == 1
            G_matrix[1, i-3] = -1
        elseif phase == 2
            G_matrix[2, i-3] = -1
        else
            G_matrix[3, i-3] = -1
        end
    end
    if x == 1
        Vref = w
    end
    jay = im
    coeffWye = [YLL \ (inv(Diagonal(conj.(Vref)))), -im * YLL \ (inv(Diagonal(conj.(Vref))))]
    coeffDelta = [YLL \ (H' / (Diagonal(H * conj.(Vref)))), -im * YLL \ (H' / (Diagonal(H * conj.(Vref))))]
    coeffMagWye, coeffMagDelta = magnitudeDerivative(Vref, coeffWye, coeffDelta)
    coeffWyeP0 = real(Diagonal(V0) * conj(Y0L) * conj.(coeffWye))
    coeffDeltaP0 = real(Diagonal(V0) * conj(Y0L) * conj.(coeffDelta))
    m = real(Diagonal(V0) * (G_matrix * conj(YL0) * conj.(V0) + G_matrix * conj(YLL) * conj.(w)))
    w = abs.(w)
    return Nnode, NmultiNode, coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, w, m
end