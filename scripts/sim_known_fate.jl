using Random, Distributions, DataFrames, Statistics

# R's plogis equivalent 
plogis(x) = (1 + tanh(x / 2)) / 2

# Test ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
n = 10000                   # number of adults with transmitters
n_years = 50          # number of years
ϕ_mean = 0.80           # population average survival
ϕ_lin  = log(ϕ_mean / (1 - ϕ_mean)) # linearized probabiltiy - log(p/(1-p))
# d = Poisson(5)
#    first = rand(d, n) .+ 1 # generate random capture times using poisson distribution
# first[first .> n_years] .= n_years # ensure capture years aren't greater than n_years

# capture history matrix and survival effect matrix
y = phi = Array{Any,2}(undef, n, n_years)

# heterogenous effects for year and individual
individual = rand(Normal(0.0, 0.25), n)
year = rand(Normal(0, 0.5), n_years)

# individual = zeros(n)
# year = zeros(n_years)

for i in 1:n
    for t in 1:n_years
        phi[i,t] = plogis.(ϕ_lin .+ 1 .* year[t] .+ 1 .* individual[i] .+ -0.5 .* t-1)
        y[i,t] = rand(Binomial(1, phi[i,t]))
    end
end

survival_individual = mean(eachrow(y))
survival_year = mean(eachcol(y))

plot(1:15, survival_year[1:15])