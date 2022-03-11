### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
begin
	using Pkg, Optim, Plots
	Pkg.activate("Project.toml")
end

# ╔═╡ 9bc05bc5-1648-4ac7-b313-1cb626bde821
md"""
# Optimisation For Economics

## Introduction

This notebook lays out the basics of how to solve optimsation problems for economics in Julia. This notebook is aimed at laying out a framework for solving these problems computationally using the Optim.jl package.

The notebook is not meant to be a comprehensive overview of optimisation problems, and only addresses fairly simple optimisation problems in Microeconomics. However, hopefully the objective functions can be tailored to your own needs to solve your own optimisation problems. For pedagogical reasons, all the problems in this notebook can easily be solved by hand if you wish to validate the results.
"""

# ╔═╡ 9a0de994-7a32-4a37-9ca8-b013bec86434
md"""
## A Simple Example

Imagine the following worked example.

*note: this example was part of a case-study and I am not the original author of the questions*.

###### Example parameters
"""

# ╔═╡ ec0280b8-2dd5-4e09-9cf4-1614684f2111
begin
	Q = 100
	intensity_CO₂ = 0.05
	tax_CO₂ = 120
	nothing
end

# ╔═╡ 7a9efb6b-0790-414e-815e-a774043bb904
md"""
###### 1.a
- A firm produces $Q units of output per year.
- Producing one unit of output currently leads to $intensity_CO₂ tonnes of CO``_2`` emissions
- The government now levies a carbon tax of USD $tax_CO₂ per tonne of CO``_2``
- Firms can abate a fraction $a$ of their emissions where ``a \in [0,1]``
- The cost of abating $a$ is given by ``c(a) = 1000 * a^3`` per tonne of initial CO``_2`` emissions

Once the carbon tax of USD $tax_CO₂ per ton of CO``_2`` comes into effect, how much CO``_2`` will the firm emit and what is the total annual cost of the carbon tax policy to the firm?
"""

# ╔═╡ d3ff6a61-2ed8-4a3f-b2c2-9d9b4ad1f427
md"""
###### Answer

Solving this with Julia is straight forward. All we need to do is specify what our objective function is, and determine what we want to minimise. Once that is done, **Optim.jl** does the rest.
"""

# ╔═╡ e22a64a9-f57d-44f1-b77c-697dbc9116c7
f_objective(a) = Q*(Q*intensity_CO₂)*(1-a) + 1000*a^3;

# ╔═╡ 3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
result = optimize(x->f_objective(x[1]), [0.])

# ╔═╡ 11c8bf82-06d1-4d70-b445-3e87ce8ff9f6
f_objective(result.minimum) > f_objective(0.45)

# ╔═╡ 9e867ead-3a11-4216-9e6b-7f9d077d9503
plot([f_objective(x) for x in 0:0.01:1])

# ╔═╡ Cell order:
# ╠═cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
# ╟─9bc05bc5-1648-4ac7-b313-1cb626bde821
# ╟─9a0de994-7a32-4a37-9ca8-b013bec86434
# ╠═ec0280b8-2dd5-4e09-9cf4-1614684f2111
# ╟─7a9efb6b-0790-414e-815e-a774043bb904
# ╟─d3ff6a61-2ed8-4a3f-b2c2-9d9b4ad1f427
# ╠═e22a64a9-f57d-44f1-b77c-697dbc9116c7
# ╠═3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
# ╠═11c8bf82-06d1-4d70-b445-3e87ce8ff9f6
# ╠═9e867ead-3a11-4216-9e6b-7f9d077d9503
