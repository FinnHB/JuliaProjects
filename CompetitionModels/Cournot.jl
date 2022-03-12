#================#
#==  PACKAGES  ==#
#================#
using Optim, Plots

#cd("E:\\Projects\\Julia\\GitHubRepos\\CompetitionModels")

f(a) = 120*5*(1-a) + 1000*a^3
optimize(x->f(first(x)), [0.0])

optimize(x->f(first(x)), [initial_x])

plot([f(x) for x in 0:0.001:1])


f(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
x0 = [0.0]
optimize(x->f(x[1]), x0)

first([1,2,3])
