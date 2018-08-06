module mbuffers13

using StaticArrays

function test_tda(N, NLOOP)
    Kedim = N
    mdim = 2
    gradN = rand(N, 2)
    Ke = fill(0.0, Kedim, Kedim)
    multiplier = 2.0
    t = @elapsed for loop = 1:NLOOP
        for nx = 1:Kedim # Do: Ce  =  Ce + gradN*((Jac*w[j]))*gradN' ;
            @inbounds for px = 1:mdim
                a = (multiplier)*gradN[nx, px]
                @inbounds for mx = 1:nx # only the upper triangle
                    Ke[mx, nx] +=  gradN[mx, px] * a
                end
            end
        end
    end 
    return t ./ NLOOP
end 

function test_tsa(::Val{N}, NLOOP) where {N}
    mdim = 2
    gradN = MMatrix{N, 2, Float64}(rand(N, 2))
    Ke = MMatrix{N, N, Float64}(fill(0.0, N, N))
    multiplier = 2.0
    t = @elapsed for loop = 1:NLOOP
        for nx = 1:N # Do: Ce  =  Ce + gradN*((Jac*w[j]))*gradN' ;
            @inbounds for px = 1:mdim
                a = (multiplier)*gradN[nx, px]
                @inbounds for mx = 1:nx # only the upper triangle
                    Ke[mx, nx] +=  gradN[mx, px] * a
                end
            end
        end
    end 
    return t ./ NLOOP
end 

function test_tsa2(N, NLOOP) 
    mdim = 2
    gradN = MMatrix{N, 2, Float64}(rand(N, 2))
    Ke = MMatrix{N, N, Float64}(fill(0.0, N, N))
    multiplier = 2.0
    function multiplyem(gradN, Ke, multiplier)
        t = @elapsed for loop = 1:NLOOP
            for nx = 1:N # Do: Ce  =  Ce + gradN*((Jac*w[j]))*gradN' ;
                @inbounds for px = 1:mdim
                    a = (multiplier)*gradN[nx, px]
                    @inbounds for mx = 1:nx # only the upper triangle
                        Ke[mx, nx] +=  gradN[mx, px] * a
                    end
                end
            end
        end 
        return t
    end 
    return multiplyem(gradN, Ke, multiplier) ./ NLOOP
end 

function test_tsabad(N, NLOOP)
    mdim = 2
    gradN = MMatrix{N, 2, Float64}(rand(N, 2))
    Ke = MMatrix{N, N, Float64}(fill(0.0, N, N))
    multiplier = 2.0
    t = @elapsed for loop = 1:NLOOP
        for nx = 1:N # Do: Ce  =  Ce + gradN*((Jac*w[j]))*gradN' ;
            @inbounds for px = 1:mdim
                a = (multiplier)*gradN[nx, px]
                @inbounds for mx = 1:nx # only the upper triangle
                    Ke[mx, nx] +=  gradN[mx, px] * a
                end
            end
        end
    end 
    return t ./ NLOOP
end 

function test(N)
    println("N = $(N)")
    NLOOP = 100000
    @time tda = test_tda(N, NLOOP)
    @time tsa = test_tsa(Val(N), NLOOP)
    @time tsa2 = test_tsa2(N, NLOOP)
    @time tsabad = test_tsabad(N, NLOOP)
    vec([tda tsa tsa2 tsabad])
end

end

using .mbuffers13

NS = [3, 9, 16, 25] # , 36, 49, 64, 225, 900
ts = []
for N in NS
    push!(ts, mbuffers13.test(N))
end 
@show ts

using Gaston
set(axis="loglog", plotstyle="linespoints", linewidth=2, pointsize = 1, color = "black", xlabel = "N", ylabel = "Time [microseconds]", grid="on", title = "")
f = figure()
# TS = [1.0e6 * t[1] for t in ts] # Time in Microseconds
# plot(NS, TS, legend = "Complete triangle")
TS = [1.0e6 * t[1] for t in ts] # Time in Microseconds
plot(NS, TS, legend = "Dynamic", gpcom = """set terminal wxt font ",6" """, box = "left top")
TS = [1.0e6 * t[2] for t in ts] # Time in Microseconds
plot!(NS, TS, legend = "Static" )
TS = [1.0e6 * t[3] for t in ts] # Time in Microseconds
plot!(NS, TS, legend = "Static 2" )
TS = [1.0e6 * t[4] for t in ts] # Time in Microseconds
plot!(NS, TS, legend = "Static BAD" )
figure(f)