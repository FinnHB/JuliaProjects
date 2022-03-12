### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ e4e0036e-eccc-4a02-8be9-a44da57a194a
using Pkg; 	Pkg.activate("Project.toml")

# ╔═╡ cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
using Optim, Plots

# ╔═╡ 9bc05bc5-1648-4ac7-b313-1cb626bde821
md"""
# Optimisation For Economics

## Introduction

This notebook lays out the basics of how to solve optimsation problems for economics in Julia. This notebook is aimed at laying out a framework for solving these problems computationally using the Optim.jl package.

The notebook is not meant to be a comprehensive overview of optimisation problems, and only addresses fairly simple optimisation problems in Microeconomics. However, hopefully the objective functions can be tailored to your own needs to solve your own optimisation problems. For pedagogical reasons, all the problems in this notebook can easily be solved by hand if you wish to validate the results.
"""

# ╔═╡ 0a1828b1-cf6c-4bdd-a519-922fe1466615


# ╔═╡ 9a0de994-7a32-4a37-9ca8-b013bec86434
md"""
## A Simple Example

Imagine the following worked example.

*note: this example was part of a case-study and I am not the original author of the questions*.
"""

# ╔═╡ 8bcf859a-bfc9-4670-aec6-33504c88317d


# ╔═╡ 288b9f53-7184-4d51-a9b7-1990d7b359ad
md"""###### Problemset parameters"""

# ╔═╡ ec0280b8-2dd5-4e09-9cf4-1614684f2111
begin
	Q = 100
	intensity_CO₂ = 0.05
	tax_CO₂ = 120
	discount_rate = 0.05
	nothing
end

# ╔═╡ d8bb56e9-5045-4b80-804d-53b90692f765


# ╔═╡ 35388a65-ca44-4e96-840f-fea92f47eab9


# ╔═╡ 7a9efb6b-0790-414e-815e-a774043bb904
md"""
###### 1.a -- Firm's CO``_2`` Abatement Choice
- A firm produces $Q units of output per year.
- Producing one unit of output currently leads to $intensity_CO₂ tonnes of CO``_2`` emissions
- The government now levies a carbon tax of USD $tax_CO₂ per tonne of CO``_2``
- Firms can abate a fraction $a$ of their emissions where ``a \in [0,1]``
- The cost of abating $a$ is given by ``c(a) = 1000 * a^3`` per tonne of initial CO``_2`` emissions

Once the carbon tax of USD $tax_CO₂ per ton of CO``_2`` comes into effect, how much CO``_2`` will the firm emit and what is the total annual cost of the carbon tax policy to the firm?
"""

# ╔═╡ 15f3da24-b85c-4a9a-840e-5e8646688d8e


# ╔═╡ d3ff6a61-2ed8-4a3f-b2c2-9d9b4ad1f427
md"""
###### Answer

Solving this with Julia is straight forward. All we need to do is specify what our objective function is, and determine what we want to minimise. The objective functions is set, we just need to pass in the starting point, and **Optim.jl** finds the closest minima.
"""

# ╔═╡ e22a64a9-f57d-44f1-b77c-697dbc9116c7
f_objective(a) = Q*(Q*intensity_CO₂)*(1-a) + 1000*a^3;

# ╔═╡ 3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
result = optimize(x->f_objective(x[1]), [0.0]);

# ╔═╡ 276bfd3c-6406-49e9-b270-5e6ae286221c
md"""
To access the value which minimzes the our function we simply access the minimizer from our results.
"""

# ╔═╡ 11c8bf82-06d1-4d70-b445-3e87ce8ff9f6
a_optim = result.minimizer[1]

# ╔═╡ 9555c941-ed7d-4eb6-bdd8-0e62fa95f3c3
md"""
We can easily visualise the results for inspection. Note that the starting point can have an impact on the results of the objective have multiple minima, however, for most simple economics problem sets, this is not a major concern. 
"""

# ╔═╡ 9e867ead-3a11-4216-9e6b-7f9d077d9503
begin
	#Specified in a function to avoid reactivity issues with variable names
	function plot_results(result)
		#Extracting results
		min_x = result.minimizer[1]
		objectivef = [(x, f_objective(x)) for x in 0:0.01:1]
	
		#Annotation location
		annotation_yloc = f_objective(min_x) + 0.07*(maximum(objectivef)[2] - minimum(objectivef)[2])
		annot_string = "($(round(min_x, digits=2)) , $(round(f_objective(min_x), digits=2)))"
	
		#Plotting
		plot(objectivef, xticks=0:0.2:1, legend=false, lw=4)
		plot!([(min_x, f_objective(min_x))], seriestype=:scatter, mc=:red, ms=4)
		annotate!(min_x, annotation_yloc, text(annot_string, :black, :middle, 8))
		plot!(title="Objective Function Minimum", ylab=md"``f(x)``", xlab=md"``x``")
	end

	#Plotting results
    plot_results(result)
end

# ╔═╡ dfef4026-100a-47d3-ab63-55b80b6c6d35
begin
	a_optim_short = round(a_optim,digits=3)
	firm_co₂ = round(Q*intensity_CO₂*(1-a_optim),digits=3)
	abate_cost = round(f_objective(a_optim), digits=2)
	tax_cost = round((Q*intensity_CO₂*(1-a_optim)) * tax_CO₂, digits=2)
	total_cost = round((Q*intensity_CO₂*(1-a_optim)) * tax_CO₂ + f_objective(a_optim), digits=2)
	nothing
end

# ╔═╡ 1314ae51-4e3d-4993-9b9e-b948e0cd0600
md"""
From the above analysis, we can see that the optimal abatement rate for the firm would be $a_optim_short, costing the firm USD $abate_cost in abatement costs. This would mean that after abating their emissions, the firm would emit $firm_co₂ tCO``_2`` and pay USD $tax_cost in taxes; resulting in a total cost of USD $total_cost.
"""

# ╔═╡ 2275fa44-5c58-40ad-8be5-aa3a2fb563db


# ╔═╡ 586da741-9a05-4192-b491-22bdc84c35cc
md"""
###### 1.b Net Present Value (NPV)
Now suppose the government announces that the above policy will come into effect in 2025 and will stay in place forever. What is today's net present value of the cost to the firm? Assume an annual discount rate of $discount_rate%.
"""

# ╔═╡ eb094b1d-67d4-48e8-b667-a3721f537337


# ╔═╡ af137d1f-1141-4e35-be06-3ebf8af63e6c
md"""
###### Answer

The NPV is a method for determining the current value of all future cash flows. Naturally, we would care more about the present, and discount future events to account for opportunity costs. The NPV can be calculated according to:

``NPV = \sum^{n}_{t=0}\frac{R_t}{(1+i)^t}``

Where ``R_t`` is the net cash flows during period ``t``, ``i`` is the discount rate (specified at the top of this workbook), and ``t`` is the number of time periods. Implementing this to the result from 1.a, we get:
"""

# ╔═╡ 68aee96a-12e2-4155-b7fa-950493e82c9c


# ╔═╡ c40c6447-e2ee-43ca-9c4e-a6332cb63cba


# ╔═╡ 03752178-755a-4ba5-a79f-7e3115c41605
md"""
###### 1.c
Two firms produce an identical product and compete in a Cournot duopoly. The market demand curve is given by **``P = 9-Q=9-q_1-q_2``**. Both firms emit $intensity_CO₂ tCO``_2`` per unit of output. They initially both have marginal cost of 0. Firms can abate emissions at cost **``c(a) = 1000a^3``**. What is the effect of a USD $tax_CO₂ carbon tax on the equilibrium price?
"""

# ╔═╡ 41e702c6-44f3-4e2d-b37d-a9865af888fe
md"""
###### Answer

"""

# ╔═╡ Cell order:
# ╠═e4e0036e-eccc-4a02-8be9-a44da57a194a
# ╠═cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
# ╟─9bc05bc5-1648-4ac7-b313-1cb626bde821
# ╟─0a1828b1-cf6c-4bdd-a519-922fe1466615
# ╟─9a0de994-7a32-4a37-9ca8-b013bec86434
# ╟─8bcf859a-bfc9-4670-aec6-33504c88317d
# ╠═288b9f53-7184-4d51-a9b7-1990d7b359ad
# ╠═ec0280b8-2dd5-4e09-9cf4-1614684f2111
# ╟─d8bb56e9-5045-4b80-804d-53b90692f765
# ╟─35388a65-ca44-4e96-840f-fea92f47eab9
# ╟─7a9efb6b-0790-414e-815e-a774043bb904
# ╟─15f3da24-b85c-4a9a-840e-5e8646688d8e
# ╟─d3ff6a61-2ed8-4a3f-b2c2-9d9b4ad1f427
# ╠═e22a64a9-f57d-44f1-b77c-697dbc9116c7
# ╠═3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
# ╟─276bfd3c-6406-49e9-b270-5e6ae286221c
# ╠═11c8bf82-06d1-4d70-b445-3e87ce8ff9f6
# ╟─9555c941-ed7d-4eb6-bdd8-0e62fa95f3c3
# ╟─9e867ead-3a11-4216-9e6b-7f9d077d9503
# ╟─1314ae51-4e3d-4993-9b9e-b948e0cd0600
# ╟─dfef4026-100a-47d3-ab63-55b80b6c6d35
# ╟─2275fa44-5c58-40ad-8be5-aa3a2fb563db
# ╟─586da741-9a05-4192-b491-22bdc84c35cc
# ╟─eb094b1d-67d4-48e8-b667-a3721f537337
# ╟─af137d1f-1141-4e35-be06-3ebf8af63e6c
# ╟─68aee96a-12e2-4155-b7fa-950493e82c9c
# ╟─c40c6447-e2ee-43ca-9c4e-a6332cb63cba
# ╟─03752178-755a-4ba5-a79f-7e3115c41605
# ╠═41e702c6-44f3-4e2d-b37d-a9865af888fe
