using Distributions, Random, Turing, DataFrames, Distributed, Plots, MCMCChains, StatsPlots, CSV


 
# Chapter 7.4.1 - Fixed Time Effects ~~~~~~~~~~~~~~~~~~~~

#= 
From the book:
We now assume that survival and recapture vary independently over time, that is, 
we regard time as a fixed-effects factor. to implement this model, we impose the 
following constraints: ϕᵢₜ = αₜ and pᵢₜ = βₜ where αₜ and βₜ are the time-specific
survival and recapture probabilities, respectively.
=#

path = "/Volumes/GoogleDrive/My Drive/NuWCRU/Analysis/emhedlin/tuvu_mr/data/tuvu_ch.csv"
df = CSV.read(path, DataFrame; delim=',')




# helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Probability of individual being alive and not captured.
function prob_uncaptured(n_ind, n_occ, p, phi) 
    z = Matrix{Real}(undef, n_ind, n_occ)
    for i in 1:n_ind
        z[i, n_occ] = 1.0;
        for t in 1:n_occ - 1
            t_curr = n_occ - t;
            t_next = t_curr + 1;
            z[i, t_curr] = (1 - phi[i, t_curr]) + phi[i, t_curr] * (1 - p[i, t_next - 1]) * z[i, t_next];
        end
    end
    return z        
end

for i in 1:size(y)[1]
    println(first_capture(y[i,:]))
end


function first_capture(y_i)
    for k in 1:length(y_i)
        if y_i[k] == 1
            return k
        end
    end
end

function last_capture(y_i) 
    for k_rev in 0:(length(y_i) - 1)
      k = length(y_i) - k_rev;
      if y_i[k] == 1
        return k
      end
    end
end



# Model Specification ~~~~~~~~~~~~~~~~~~~

@model cjs_cc_marg(y) = begin
    
    # data dimensions
    n_ind,n_occ = size(y)

    # Create empty matrices
    phi = Matrix{Real}(undef, n_ind, n_occ-1)
    p   = Matrix{Real}(undef, n_ind, n_occ-1)
    first = Vector{Int}(undef, n_ind)
    last  = Vector{Int}(undef, n_ind)

    # calculate first and last capture occasions
    for i in 1:n_ind
        first[i] = first_capture(y[i,:])
        last[i] = last_capture(y[i,:])
    end
    
        # ~~~~ Priors ~~~~
    mean_phi ~ Uniform(0,1)
    mean_p   ~ Uniform(0,1)
    
    # Constraints on phi and p
    for i in 1:n_ind
        for t in 1:first[i]-1
            phi[i,t] = 0
            p[i,t] = 0
        end
        
        for t in first[i]:n_occ - 1
            phi[i,t] = mean_phi # this is where you add linear models
            p[i,t] = mean_p     # this is where you add linear models
        end
    end
    
    z = prob_uncaptured(n_ind, n_occ, p, phi)
    
    # ~~~~ Likelihood ~~~~~
    for i in 1:n_ind
        
        if first[i] > 0 
            for t in (first[i]+1):last[i]
                1 ~ Bernoulli(phi[i,t-1])
                y[i,t] ~ Bernoulli(p[i, t-1])
            end
        end
    1 ~ Bernoulli(z[i,last[i]])
    end
end

# Sample ~~~~~~~~~~~~~~~~~~~

# get rid of first columns, tag ID and age category
y = df[:, 4:size(df)[2]]
chain = sample(cjs_cc_marg(y),  NUTS(100, 0.65), 2500)
chain = sample(cjs_cc_marg(y), NUTS(100, 0.65), MCMCThreads(), 1000, 4)

size(y)


plot(chain)





# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Age as Fixed            
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


