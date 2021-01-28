using Random, Distributions

# R's plogis equivalent 
function plogis(x)
    (1+ tanh(x/2))/2
end

n = 20                    # number of adults with transmitters
n_years = 17              # number of years
ϕ_mean = 0.65           # population average survival
ϕ_lin  = log(ϕ_mean/(1-ϕ_mean)) # linearized probabiltiy - log(p/(1-p))
d = Poisson(5)
    first = rand(d, n) .+ 1 # generate random capture times using poisson distribution
first[first .> n_years] .= n_years # ensure capture years aren't greater than n_years


year = [1:1:n_years;] 
individual = rand(Normal(0,1), n)

y = phi = Array{Float64,2}(undef, n, n_years)
# y = phi = Array{Int}(undef, n, n_years)

for i in 1:n
  y[i, first[i]] = 1
  for t in (first[i]+1):n_years 
    phi[i, t] = plogis(1 + ϕ_lin + 1 .* year[t] + 1 .* individual[i] + -0.5 .* t) # -0.5*t is age, where -0.5 describes the declining survival
    y[i, t] = rand(Binomial(y[i, t-1] .* phi[i, t]))
  end
end



 x = rand(Bernoulli(y[i, t] * phi[i, t]), 1)

 rand(Bernoulli(0.5),1)


 using CSV
 using DataFrames

dataset = CSV.read("http://sites.google.com/site/hierarchicalmodelingcourse/home/datasets/lrDat.csv?attredirects=0")


x = 1:10

(x -> x % 6 == 0)




# create vector of 1's starting change


n = 10000                   # number of adults with transmitters
n_years = 50              # number of years
ϕ_mean = 0.7           # population average survival
ϕ_lin  = log(ϕ_mean/(1-ϕ_mean)) # linearized probabiltiy - log(p/(1-p))
d = Poisson(5)
    first = rand(d, n) .+ 1 # generate random capture times using poisson distribution
first[first .> n_years] .= n_years # ensure capture years aren't greater than n_years


ch = ones(Int, n, n_years)
ch = convert(DataFrame, ch)


for i in 1:nrow(ch)
    for t in 2:ncol(ch)

        # if individual was dead at t-1, keep individual dead
        if ch[i,t-1] == 0
           ch[i,t] = 0

        # if individual was alive at t-1, draw from binomial distribution to see if individual stays alive    
        # to create a more complicated simulation, we can replace the rand(binomial...) with a linear model    
        elseif ch[i,t] == 1
            ch[i,t] = rand(Binomial(1, ϕ_mean))

        # elseif ch[i,t] == 1
        #    ch[i,t] = rand(Binomial(1, plogis(ϕ_lin + 1 .* year[t] + 1 .* individual[i] + -0.5 .* t)))    

        end
    end
end


survival = count.(==(1), eachcol(ch)) ./ n
x = 1:length(survival)
y = survival

plot(x[1:20], y[1:20])