### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ e4e0036e-eccc-4a02-8be9-a44da57a194a
using Pkg; 	Pkg.activate("Project.toml")

# ╔═╡ cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
begin
	using Optim, Plots, ForwardDiff
	plotly()
	nothing
end

# ╔═╡ 7a6770b3-0fff-4f51-9257-9c57b2bbd7dc


# ╔═╡ 931c46b7-296b-451d-86f9-9486ea1d4e15


# ╔═╡ 9bc05bc5-1648-4ac7-b313-1cb626bde821
md"""
# Solving Optimisation Problems For Economics I

## Introduction

This notebook is the first in a series of notebooks laying out the basics of how to solve an economic optimsation problem in Julia. In particular, this notebook covers a single optimisation problem relating to the firm's choice, and is similar to something which you may find in undegraduate or postgraduate problem sets.

One key difference is that some of the problems may be time-consuming to solve by hand.
"""

# ╔═╡ 18320bda-9c06-4788-85e8-08f97fd620db


# ╔═╡ 0a1828b1-cf6c-4bdd-a519-922fe1466615


# ╔═╡ 9a0de994-7a32-4a37-9ca8-b013bec86434
md"""
## Firm's Choices - Optimal CO``_2`` Abatement
"""

# ╔═╡ 288b9f53-7184-4d51-a9b7-1990d7b359ad
md"""###### Problemset parameters"""

# ╔═╡ ec0280b8-2dd5-4e09-9cf4-1614684f2111
begin
	Q = 20
	intensity_CO₂ = 0.1
	tax_CO₂_2025 = 120
	tax_CO₂_2035 = 240
	discount_rate = 0.02
end;

# ╔═╡ d8bb56e9-5045-4b80-804d-53b90692f765


# ╔═╡ 35388a65-ca44-4e96-840f-fea92f47eab9


# ╔═╡ 7a9efb6b-0790-414e-815e-a774043bb904
md"""
###### 1.a -- Firm's CO``_2`` Abatement Choice
Assume that a firm can produce ``Q`` units of output at a cost of ``0.2Q+Q^{\frac{1}{2}}``, where each unit of output generates $intensity_CO₂ tCO``_2``. In 2025, the government will impose a carbon tax of € $tax_CO₂_2025 per tCO``_2``. However, the firm can also choose to abate a fraction ``a`` of their emissions at a cost of ``730\times a^{\frac{1}{a}}`` where ``a \in [0,1]``.

Once the tax comes in to effect, how much CO``_2`` will the firm emit and what will be the the total annual cost of the carbon tax policy to the firm?
"""

# ╔═╡ 15f3da24-b85c-4a9a-840e-5e8646688d8e


# ╔═╡ d3ff6a61-2ed8-4a3f-b2c2-9d9b4ad1f427
md"""
###### Answer

Solving this with Julia is straight forward. All we need to do is specify what our objective function is, and determine what we want to minimise. Once the objective functions has been formulated, we just need to pass in the starting point, and **Optim.jl** finds the closest minima.
"""

# ╔═╡ c6129e50-56cd-4e7d-942d-98239c1b3603
begin
	#Abatement cost function
	f_abatement(a) = 730*a^(1/a)

	#Production cost function
	f_prodcost(Q) = 0.2Q+Q^(1/2)

	#Objective function
	function f_objective(a; tax=tax_CO₂_2025, Q=Q, intensity=intensity_CO₂)
		return f_prodcost(Q) + tax*(Q*intensity)*(1-a) + f_abatement(a)
	end
end;

# ╔═╡ 3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
result = optimize(x->f_objective(x[1]), [0.0]);

# ╔═╡ 276bfd3c-6406-49e9-b270-5e6ae286221c
md"""
To access the value which minimzes the our function we simply access the minimizer from our results.

*N.B. Sometimes results can be dependent on the starting value, therefore, in cases without a global minima, multiple starting points may want to be explored.*
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
		objectivef = [(x, f_objective(x)) for x in 0:0.001:1]
	
		#Annotation location
		annotation_yloc = f_objective(min_x) + 0.07*(maximum(objectivef)[2] - minimum(objectivef)[2])
		annot_string = "($(round(min_x, digits=2)) , $(round(f_objective(min_x), digits=2)))"
	
		#Plotting
		plot(objectivef, label="Obj.Func.", xticks=0:0.1:1, legend=false, lw=4)
		plot!([(min_x, f_objective(min_x))], seriestype=:scatter, color=:red, ms=4)
		annotate!(min_x, annotation_yloc, text(annot_string, :black, :middle, 8))
		plot!(title="Objective Function Minimum", ylab="f(x)", xlab="x")
	end

	#Plotting results
    plot_results(result)
end

# ╔═╡ dfef4026-100a-47d3-ab63-55b80b6c6d35
begin
	firm_co₂ = Q * intensity_CO₂ * (1-a_optim)
	abate_cost = f_abatement(a_optim)
	tax_cost = (Q * intensity_CO₂ * (1-a_optim)) * tax_CO₂_2025
	production_cost = f_prodcost(Q)
	total_cost = production_cost + tax_cost + abate_cost
end;

# ╔═╡ e22ca996-8c8c-4e69-a28d-c4aa1ff33ef2
md"""
For future reference to total cost calculations, the we will use the following function for calculating total costs.
"""

# ╔═╡ ef880d51-3456-4dbc-b0d2-bcc4a0a5a14d
function calculate_tc(a_init; tax=tax_CO₂_2025, Q=Q, intensity=intensity_CO₂)
	#Get Optimal Abatement
	a_optim = optimize(x->f_objective(x[1],
		                              tax=tax,
		                              Q=Q,
		                              intensity=intensity),
		               [a_init]).minimizer[1]

	#Calculate Costs
	abate_cost = f_abatement(a_optim)
	tax_cost = (Q * intensity * (1-a_optim)) * tax
	production_cost = f_prodcost(Q)

	#Return total cost and optimal abatement
	return (tc=production_cost + tax_cost + abate_cost, a=a_optim)
end;

# ╔═╡ 777a2a0d-0f99-4fd0-a62b-590995718052


# ╔═╡ 6a312d0c-fbea-4e9e-a5a3-c0bc85170c3f


# ╔═╡ eb094b1d-67d4-48e8-b667-a3721f537337


# ╔═╡ e76ad736-a1a6-4a2b-9309-ba36d6a0a9bf
NPV_2025 = total_cost/((1+discount_rate)^(2025-2022));

# ╔═╡ 3e3838e9-555a-4c6c-a60e-cde9fc72b87e
md"""
However, since the firm faces production costs, these costs need to be factored in to the discounting. Consequently, when we calculate the total cost, ``TC``, faced by the firm we get the following summation.

$\sum_{t=2023}^{2035} \frac{TC_t}{(1+i)^{t-2022}}$

We can code this out programmatically, where the new tax policies are suddenly introduced in 2025 and 2035.
"""

# ╔═╡ eecd8362-1be0-481b-9c9d-b6e097bb233f
function npv_sudden(;final_year=2035)
	#Total costs in 2025 and 2035
	tc_2022 = calculate_tc(0.01, tax=0)[:tc]
	tc_2025 = calculate_tc(0.01, tax=tax_CO₂_2025)[:tc]
	tc_2035 = calculate_tc(0.01, tax=tax_CO₂_2035)[:tc]

	final_npv = 0
	for year in range(2023,final_year)
		t = year-2022

		#Before first tax policy implemented (only production cost)
		if year < 2025
			final_npv += tc_2022/(1+discount_rate)^t

		#After first tax policy (production cost plus tax)
		elseif year >= 2025 && year < 2035
			final_npv += tc_2025/(1+discount_rate)^t

		#After second tax policy (production cost plus new tax rate)
		elseif year >= 2035
			final_npv += tc_2035/(1+discount_rate)^t
		end
	end
	return final_npv
end;

# ╔═╡ b115e011-8047-4eb6-9573-fc8de90639d3
sudden_NPV_2035 = npv_sudden(final_year=2034)

# ╔═╡ ae238dab-a5bf-42c7-ba80-9cca9e007064
sudden_NPV_perpituity = npv_sudden(final_year=10_000)

# ╔═╡ 6e8730ef-f27d-451d-ba18-3b8e72dbc944
function npv_gradual(;final_year=2035)
	#Total costs in 2025 and 2035
	tc_2022 = calculate_tc(0.01, tax=0)[:tc]
	tc_2025 = calculate_tc(0.01, tax=tax_CO₂_2025)[:tc]
	tc_2035 = calculate_tc(0.01, tax=tax_CO₂_2035)[:tc]

	#Calculate annual growth rate to achieve 2035 target rate
	tax_growth = 1 + (tax_CO₂_2035/tax_CO₂_2025) ^ (1/(2035-2025)) - 1
	
	final_npv = 0
	for year in range(2023,final_year)
		t = year-2022

		#Before first tax policy implemented (only production cost)
		if year < 2025
			final_npv += tc_2022/(1+discount_rate)^t

		#After first tax policy (production cost plus tax)
		elseif year == 2025
			final_npv += tc_2025/(1+discount_rate)^t

		#Growing tax by constant rate to reach 2035 target
		elseif year > 2025 && year < 2035
			tc_year = calculate_tc(0.01, tax=tax_CO₂_2025*tax_growth^(year-2025))[:tc]
			final_npv += tc_year/(1+discount_rate)^t

		#After second tax policy (production cost plus new tax rate)
		elseif year >= 2035
			final_npv += tc_2035/(1+discount_rate)^t
		end
	end
	return final_npv
end;

# ╔═╡ 33d1f514-2da0-462b-b2d3-155e40b0c4bb
gradual_NPV_2035 = npv_gradual(final_year=2035)

# ╔═╡ d2d99ca5-9045-4a99-b68d-24ea0e34a7d7
gradual_NPV_perpituity = npv_gradual(final_year=10_000)

# ╔═╡ 72160409-650c-42f5-8fa2-eac2d7df6a2c


# ╔═╡ 0b30a4d0-6d01-4d6f-8f61-d81fec56a0f8


# ╔═╡ 5062ea43-0509-4385-abdb-6b83e7535c06


# ╔═╡ 3e380002-2987-44f7-a318-b54adaf9ad69
md"""
###### 1.c -- Permit markets
Instead of implementing a carbon tax, the government is thinking that launching a permit scheme may be a more effective way to reduce emissions. They calculated that in order to reach the net-zero target, emissions cannot be higher than 2.8 from 2025 onward.

The permit market will apply to two firms, both producing ``Q=``$Q units of output, where each unit of output emits $intensity_CO₂ tCO``_2``. Firm ``A`` faces a production cost of ``0.2Q+Q^{\frac{1}{2}}`` and an abatement cost of ``730 \times a^{\frac{1}{a}}`` and firm ``B`` faces the same production cost, but an abatement cost of ``500 \times a^{\frac{1}{3a}}``.

Assuming that the permits are divided equally between the two firms, how much will each firm emit? If each permit counts for 0.1 tCO``_2``, what will be the equilibrium price of the permits?
"""

# ╔═╡ a3563b82-3e2b-4688-971c-f2d70a8b0df1
md"""
###### Answer

First, lets have a look at how much each firm would pollute without trading permits. In this situation, each firm will use up their allocated share of permits, and be forced to abate the remaining emissions.
"""

# ╔═╡ 5eb7d942-e523-4c09-b011-6b75f2ac1185
begin
	#Firm abatement costs function
	f_abate_A(a) = 730*a^(1/a)
	f_abate_B(a) = 500*a^(1/(3a))

	#First derivative of abatement cost function
	df_abate_A(a) = ForwardDiff.derivative(f_abate_A, a)
	df_abate_B(a) = ForwardDiff.derivative(f_abate_B, a)
	
	#Total abatement cost of both firms
	f_tac(a1,a2) = f_abate_A(a1) + f_abate_B(a2)
end;

# ╔═╡ d64113ae-8391-4054-8436-cb3cb63e85e5
md"""
Without trading permits, each firm will use up their allocated share of permits, and be forced to abate the remaining emissions.
"""

# ╔═╡ 08e4ce39-31d2-417e-8482-f6523fa10b26
begin
	plot([(a, f_abate_A(a)) for a in 0:0.001:1], label="Firm A")
	plot!([(a, f_abate_B(a)) for a in 0:0.001:1], label="Firm B")
end

# ╔═╡ 4be67689-ee9e-4fd1-a767-315229580237
begin
	xs = 0:0.001:1
	plot([(a, df_abate_A(a)) for a in xs], label="Firm A")
	plot!([(a, df_abate_B(a)) for a in xs], label="Firm B")
end

# ╔═╡ 6942ce82-9513-4234-9775-d0b7a253055f
begin
	#Calculate cost from combinations
	window = range(0,1, length=101)
	grid = [[a₁,a₂,f_tac(a₁,a₂)] for a₁ in window, a₂ in window]

	#Extract cost element from grid
	grid_costs = map(
		g -> ifelse(g[1]+g[2] >= 0.6, g[3], Inf),
		grid
	)
end;

# ╔═╡ 81cafaf3-5f92-489d-9341-1160425288c1
a1,a2,c = grid[findmin(grid_costs)[2]];

# ╔═╡ ec704946-35ca-4b6b-91fc-05223fa64756
plot(window, window, f_tac, st=:surface)

# ╔═╡ 509ced6b-ee4b-4003-b19d-bc4330c287bd
f_abate_A(a1) + f_abate_B(a2)

# ╔═╡ f0b3a489-1c76-44a8-bfc9-816b3d664e90


# ╔═╡ aa7bb6c4-3108-4397-b668-0f810789dd3e
md"""
1. Calculate the emissions of each firm prior to any intervention.
2. Each firm is willing to buy/sell the permits below/above their marginal abatement cost
3. Each firm will trade until the marginal abatement cost of the two firms equalise
"""

# ╔═╡ ca8244fa-5d7e-4cf9-8a26-b4722991b5a4


# ╔═╡ c40c6447-e2ee-43ca-9c4e-a6332cb63cba


# ╔═╡ 240daf8c-cebb-479c-bdec-44013b03c821


# ╔═╡ 03fd59b8-e5d2-4a7f-8856-0bda4327bafb


# ╔═╡ 49cbc9c3-43a5-49b9-8331-0b7e6134a164
md"""
## Appendix

##### Variable rounding
"""

# ╔═╡ 6d2c21a1-ba81-4972-bf5c-623d01db8c25
md"""##### Miscellaneous parameters"""

# ╔═╡ dcc719f6-e791-4908-99f0-319e08712ed2
begin
	#Part 1.b
	percent_discount_rate = discount_rate*100
	change_NPV_2035 = gradual_NPV_2035 - sudden_NPV_2035
	change_NPV_perpituity = gradual_NPV_perpituity - sudden_NPV_perpituity

	#Part 1.c
	permit_limit = round(0.70*2Q*intensity_CO₂, digits=1)
end;

# ╔═╡ 586da741-9a05-4192-b491-22bdc84c35cc
md"""
###### 1.b -- Net Present Value (NPV)
Assuming that we are currently in 2022, the first carbon tax of € $tax_CO₂_2025 will come in place in three years. The government has also announced that in 2035, it will increase the tax to € $tax_CO₂_2035 at which point this increased rate will stay in place for perpituity.

What would be today's net present value of the firm's costs assuming an annual discount rate of $percent_discount_rate%? How would your answer change if the government decided to instead apply a constant growth rate between 2025 and 2035?
"""

# ╔═╡ 2275fa44-5c58-40ad-8be5-aa3a2fb563db
begin
	rounded_a_optim = round(a_optim,digits=3)
	rounded_firm_co₂ = round(firm_co₂,digits=3)
	rounded_abate_cost = round(abate_cost, digits=2)
	rounded_tax_cost = round(tax_cost, digits=2)
	rounded_production_cost = round(production_cost, digits=2)
	rounded_total_cost = round(total_cost, digits=2)
	rounded_NPV_2025 = round(NPV_2025,digits=2)
	rounded_sudden_NPV_2035 = Int(round(sudden_NPV_2035))
	rounded_sudden_NPV_perpituity = Int(round(sudden_NPV_perpituity))
	rounded_gradual_NPV_2035 = Int(round(gradual_NPV_2035))
	rounded_gradual_NPV_perpituity = Int(round(gradual_NPV_perpituity))
	rounded_change_NPV_2035 = Int(round(change_NPV_2035))
	rounded_change_NPV_perpituity = Int(round(change_NPV_perpituity))
end;

# ╔═╡ 1314ae51-4e3d-4993-9b9e-b948e0cd0600
md"""
From the above analysis, we can see that the optimal abatement rate for the firm would be $rounded_a_optim, costing the firm € $rounded_abate_cost in abatement costs. This would mean that after abating their emissions, the firm would emit $rounded_firm_co₂ tCO``_2`` and pay € $rounded_tax_cost in taxes. After including the production cost of € $rounded_production_cost, the firm would be faced with a total cost of € $rounded_total_cost.
"""

# ╔═╡ af137d1f-1141-4e35-be06-3ebf8af63e6c
md"""
###### Answer

The NPV is a method for determining the current value of all future cash flows. Naturally, we would care more about the present, and discount future events to account for opportunity costs. The NPV of a future cost at time ``t`` can be calculated according to:

$NPV = \sum_{t=1}^{n}\frac{R_t}{(1+i)^t}$

Where ``R_t`` is the net cash flows during period ``t``, ``i`` is the discount rate, $discount_rate, and ``t`` is the number of time periods. For example, if a firm did not face any costs up to 2025, the NPV of their costs would be € $rounded_NPV_2025 (as shown below).
"""

# ╔═╡ 1352c82d-688d-4684-93da-58952e32cdc9
md"""
The cumulative costs the firm will face by 2035 in NPV will be € $rounded_sudden_NPV_2035, and € $rounded_sudden_NPV_perpituity over the infinite horizon.

If the tax rate grows at a constant rate between 2025 and 2035, the NPV of the costs will be higher both by 2035 and over the infinite horizon due to higher costs being realised between 2026 and 2034. Using the same approach as before, we can loop through the years in order to calculate the net present value of the total cost to the firm.
"""

# ╔═╡ 8b83e0d6-d595-453d-af72-4f8a3872c985
md"""
In this case, the cumulative costs the firm will face by 2035 in NPV will be € $rounded_gradual_NPV_2035, and € $rounded_gradual_NPV_perpituity over the infinite horizon -- € $rounded_change_NPV_2035 and € $rounded_change_NPV_perpituity higher respectively.
"""

# ╔═╡ Cell order:
# ╠═e4e0036e-eccc-4a02-8be9-a44da57a194a
# ╠═cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
# ╟─7a6770b3-0fff-4f51-9257-9c57b2bbd7dc
# ╟─931c46b7-296b-451d-86f9-9486ea1d4e15
# ╟─9bc05bc5-1648-4ac7-b313-1cb626bde821
# ╟─18320bda-9c06-4788-85e8-08f97fd620db
# ╟─0a1828b1-cf6c-4bdd-a519-922fe1466615
# ╟─9a0de994-7a32-4a37-9ca8-b013bec86434
# ╟─288b9f53-7184-4d51-a9b7-1990d7b359ad
# ╠═ec0280b8-2dd5-4e09-9cf4-1614684f2111
# ╟─d8bb56e9-5045-4b80-804d-53b90692f765
# ╟─35388a65-ca44-4e96-840f-fea92f47eab9
# ╟─7a9efb6b-0790-414e-815e-a774043bb904
# ╟─15f3da24-b85c-4a9a-840e-5e8646688d8e
# ╟─d3ff6a61-2ed8-4a3f-b2c2-9d9b4ad1f427
# ╠═c6129e50-56cd-4e7d-942d-98239c1b3603
# ╠═3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
# ╟─276bfd3c-6406-49e9-b270-5e6ae286221c
# ╠═11c8bf82-06d1-4d70-b445-3e87ce8ff9f6
# ╟─9555c941-ed7d-4eb6-bdd8-0e62fa95f3c3
# ╟─9e867ead-3a11-4216-9e6b-7f9d077d9503
# ╠═dfef4026-100a-47d3-ab63-55b80b6c6d35
# ╟─1314ae51-4e3d-4993-9b9e-b948e0cd0600
# ╟─e22ca996-8c8c-4e69-a28d-c4aa1ff33ef2
# ╠═ef880d51-3456-4dbc-b0d2-bcc4a0a5a14d
# ╟─777a2a0d-0f99-4fd0-a62b-590995718052
# ╟─6a312d0c-fbea-4e9e-a5a3-c0bc85170c3f
# ╟─586da741-9a05-4192-b491-22bdc84c35cc
# ╟─eb094b1d-67d4-48e8-b667-a3721f537337
# ╟─af137d1f-1141-4e35-be06-3ebf8af63e6c
# ╠═e76ad736-a1a6-4a2b-9309-ba36d6a0a9bf
# ╟─3e3838e9-555a-4c6c-a60e-cde9fc72b87e
# ╠═eecd8362-1be0-481b-9c9d-b6e097bb233f
# ╠═b115e011-8047-4eb6-9573-fc8de90639d3
# ╠═ae238dab-a5bf-42c7-ba80-9cca9e007064
# ╟─1352c82d-688d-4684-93da-58952e32cdc9
# ╠═6e8730ef-f27d-451d-ba18-3b8e72dbc944
# ╠═33d1f514-2da0-462b-b2d3-155e40b0c4bb
# ╠═d2d99ca5-9045-4a99-b68d-24ea0e34a7d7
# ╟─8b83e0d6-d595-453d-af72-4f8a3872c985
# ╟─72160409-650c-42f5-8fa2-eac2d7df6a2c
# ╟─0b30a4d0-6d01-4d6f-8f61-d81fec56a0f8
# ╟─5062ea43-0509-4385-abdb-6b83e7535c06
# ╟─3e380002-2987-44f7-a318-b54adaf9ad69
# ╟─a3563b82-3e2b-4688-971c-f2d70a8b0df1
# ╠═5eb7d942-e523-4c09-b011-6b75f2ac1185
# ╟─d64113ae-8391-4054-8436-cb3cb63e85e5
# ╟─08e4ce39-31d2-417e-8482-f6523fa10b26
# ╟─4be67689-ee9e-4fd1-a767-315229580237
# ╠═6942ce82-9513-4234-9775-d0b7a253055f
# ╠═81cafaf3-5f92-489d-9341-1160425288c1
# ╠═ec704946-35ca-4b6b-91fc-05223fa64756
# ╠═509ced6b-ee4b-4003-b19d-bc4330c287bd
# ╠═f0b3a489-1c76-44a8-bfc9-816b3d664e90
# ╠═aa7bb6c4-3108-4397-b668-0f810789dd3e
# ╠═ca8244fa-5d7e-4cf9-8a26-b4722991b5a4
# ╟─c40c6447-e2ee-43ca-9c4e-a6332cb63cba
# ╟─240daf8c-cebb-479c-bdec-44013b03c821
# ╟─03fd59b8-e5d2-4a7f-8856-0bda4327bafb
# ╟─49cbc9c3-43a5-49b9-8331-0b7e6134a164
# ╠═2275fa44-5c58-40ad-8be5-aa3a2fb563db
# ╟─6d2c21a1-ba81-4972-bf5c-623d01db8c25
# ╠═dcc719f6-e791-4908-99f0-319e08712ed2
