### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ e4e0036e-eccc-4a02-8be9-a44da57a194a
using Pkg; 	Pkg.activate("Project.toml")

# ╔═╡ cc4a8f90-a0c6-11ec-1a1a-8bac26689c58
begin
	using Optim, Plots
	plotly()
	nothing
end

# ╔═╡ 7a6770b3-0fff-4f51-9257-9c57b2bbd7dc


# ╔═╡ 931c46b7-296b-451d-86f9-9486ea1d4e15


# ╔═╡ 9bc05bc5-1648-4ac7-b313-1cb626bde821
md"""
# Solving Optimisation Problems For Economics I

## Introduction

This notebook lays out the basics of how to solve an economic optimsation problem in Julia. This notebook is aimed at laying out a framework for solving these problems in in the context of a reactive notebook. This notebook covers a single optimisation problem relating to the firm's choice, and is similar to something which you may find in undegraduate or postgraduate problem sets.

*Disclaimer: This question was part of a case-study interview question, and was not written by me.*
"""

# ╔═╡ 18320bda-9c06-4788-85e8-08f97fd620db


# ╔═╡ 0a1828b1-cf6c-4bdd-a519-922fe1466615


# ╔═╡ 9a0de994-7a32-4a37-9ca8-b013bec86434
md"""
## Firm's Choices - Optimal CO``_2`` Abatement & Cournot Competition
"""

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

Solving this with Julia is straight forward. All we need to do is specify what our objective function is, and determine what we want to minimise. Once the objective functions has been formulated, we just need to pass in the starting point, and **Optim.jl** finds the closest minima.
"""

# ╔═╡ c6129e50-56cd-4e7d-942d-98239c1b3603
f_abatement(a) = 1000*a^3;

# ╔═╡ e22a64a9-f57d-44f1-b77c-697dbc9116c7
f_objective(a) = Q*(Q*intensity_CO₂)*(1-a) + f_abatement(a);

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
		plot!(title="Objective Function Minimum", ylab="f(x)", xlab="x")
	end

	#Plotting results
    plot_results(result)
end

# ╔═╡ dfef4026-100a-47d3-ab63-55b80b6c6d35
begin
	firm_co₂ = Q*intensity_CO₂*(1-a_optim)
	abate_cost = f_abatement(a_optim)
	tax_cost = (Q*intensity_CO₂*(1-a_optim)) * tax_CO₂
	total_cost = (Q*intensity_CO₂*(1-a_optim)) * tax_CO₂ + f_abatement(a_optim)
	nothing
end

# ╔═╡ 777a2a0d-0f99-4fd0-a62b-590995718052


# ╔═╡ 6a312d0c-fbea-4e9e-a5a3-c0bc85170c3f


# ╔═╡ 586da741-9a05-4192-b491-22bdc84c35cc
md"""
###### 1.b Net Present Value (NPV)
Now suppose the government announces that the above policy will come into effect in 2025 and will stay in place forever. What is today's net present value of the cost to the firm? Assume an annual discount rate of $discount_rate%.
"""

# ╔═╡ eb094b1d-67d4-48e8-b667-a3721f537337


# ╔═╡ e76ad736-a1a6-4a2b-9309-ba36d6a0a9bf
NPV_2025 = total_cost/((1+discount_rate)^(2025-2022));

# ╔═╡ 4dbe1681-6c3c-499f-8dcd-426720b43f86
md"""
The question states that the policy will remain in place forever, consequently, we also need to calculate the NPV over an infinite horizon. Since we know that the costs to the firm will stay constant for perpituity from 2025 onward, we can simply divide our 2025 NPV cost by the discount rate of $discount_rate. In other words:

``NPV = \frac{NPV_{2025}}{i}``
"""

# ╔═╡ 67bfa521-192b-48ab-982e-e8e3dcbe951c
NPV = NPV_2025/discount_rate;

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

First, we set up the profit function of each of the firms.

``\pi_1 = q_1*(9-q_1-q_2) - (t(q_1*e) + c(a))``

``\pi_2 = q_2*(9-q_1-q_2) - (t(q_2*e) + c(a))``

Where ``t`` us the tax per ton of CO``_2``, ``e`` is the CO``_2`` intensity per unit of output, ``c(a)`` is the firm's abatement cost curve, and ``q_1`` and ``q_2`` represents firm 1 and firm 2's output choices respectively.
"""

# ╔═╡ 603f1acf-7594-43bf-8db6-57ab66da1032
md"""
Taking the derivative and maximising the profit function, we are left with the following symbolic representation of the firm's optimal choice.

``
\frac{\partial\pi_1}{\partial q_1} = 9-2q_1-q_2-te = 0
\;\;\;\;\; \rightarrow \;\;\;\;\;
q_1 = \frac{9-q_2-te}{2}
``

``
\frac{\partial\pi_2}{\partial q_2} = 9-q_1-2q_2-te = 0
\;\;\;\;\; \rightarrow \;\;\;\;\;
q_2 = \frac{9-q_1-te}{2}
``
"""

# ╔═╡ 16a72325-4eec-4ec8-81e5-b8225133deab
md"""
Plugging in ``q_2`` to the first equation, we get:

``q_1 = \frac{9-(\frac{9-q_1-te}{2})}{2}``

``q_1 = \frac{9-q_1-te}{4}``

``q_1 = \frac{9 - te}{5}``

and by symmetry:

``q_2 = \frac{9 - te}{5}``
"""

# ╔═╡ af9c1d06-539f-49b9-9d7f-8dab11ee2596
f_profit_max_q(;t=tax_CO₂, e=intensity_CO₂) = (9-t*e)/5;

# ╔═╡ 76cd98ce-fb3f-49db-b27f-1cb1ac5378f7
begin
	# Before tax (BT)
	q₁_bt = q₂_bt = f_profit_max_q(t=0)
	Q_bt = q₁_bt+q₂_bt
	p_bt = 9-Q_bt
	
	# After tax (AT)
	q₁_at = q₂_at = f_profit_max_q(t=tax_CO₂)
	Q_at = q₁_at+q₂_at
	p_at = 9-Q_at

	nothing
end

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
	#Part 1.c
	marginal_cost = tax_CO₂*intensity_CO₂
	price_increase = p_at - p_bt
	quantity_decrease = Q_bt - Q_at
	nothing
end

# ╔═╡ 2275fa44-5c58-40ad-8be5-aa3a2fb563db
begin
	rounded_a_optim = round(a_optim,digits=3)
	rounded_firm_co₂ = round(firm_co₂,digits=3)
	rounded_abate_cost = round(abate_cost, digits=2)
	rounded_tax_cost = round(tax_cost, digits=2)
	rounded_total_cost = round(total_cost, digits=2)
	rounded_NPV_2025 = round(NPV_2025,digits=2)
	rounded_NPV = round(NPV, digits=2)
	rounded_marginal_cost = round(marginal_cost, digits=2)
	rounded_q₁_bt = round(q₁_bt, digits=2)
	rounded_q₁_at = round(q₁_at, digits=2)
	rounded_p_bt = round(p_bt, digits=2)
	rounded_p_at = round(p_at, digits=2)
	rounded_quantity_decrease = round(quantity_decrease, digits=3)
	rounded_price_increase = round(price_increase, digits=2)
	nothing
end

# ╔═╡ 1314ae51-4e3d-4993-9b9e-b948e0cd0600
md"""
From the above analysis, we can see that the optimal abatement rate for the firm would be $rounded_a_optim, costing the firm USD $rounded_abate_cost in abatement costs. This would mean that after abating their emissions, the firm would emit $rounded_firm_co₂ tCO``_2`` and pay USD $rounded_tax_cost in taxes; resulting in a total cost of USD $rounded_total_cost.
"""

# ╔═╡ af137d1f-1141-4e35-be06-3ebf8af63e6c
md"""
###### Answer

The NPV is a method for determining the current value of all future cash flows. Naturally, we would care more about the present, and discount future events to account for opportunity costs. The NPV of a future cost at time ``t`` can be calculated according to:

``NPV = \frac{R_t}{(1+i)^t}``

Where ``R_t`` is the net cash flows during period ``t``, ``i`` is the discount rate (specified at the top of this workbook), and ``t`` is the number of time periods. Implementing this to the result from 1.a up to 2025, we get a NPV of the 2025 costs of USD $rounded_NPV_2025:
"""

# ╔═╡ 4fa41716-6df5-4d7e-8dba-008b29cdb1fd
md"""
This means that the firm will face a net present value cost of USD $rounded_NPV.
"""

# ╔═╡ b84d9d9e-0cea-4ff2-a419-02d628ad6b0d
md"""
We can now solve for ``q_1`` and ``q_2`` by plugging in the carbon tax. Initially prior to the tax being implemented, the firm is facing zero marginal cost because ``t=0``. However, after the tax is introduced, the firm needs to pay $tax_CO₂ per ton of CO``_2``, resulting in a marginal cost of USD $rounded_marginal_cost per unit of output (``t*e``).
"""

# ╔═╡ 07436047-5502-42e8-b7a7-6c3614b34590
md"""
The resultant outcome is that prior to the implementation of the carbon tax, both firms produce $rounded_q₁_bt units of output each at an equilibrium price of USD $rounded_p_bt. After the tax of $tax_CO₂ per ton of CO``_2`` is introduced, the firms change their production to $rounded_q₁_at units of output at a  new equilibrium price of $rounded_p_at. Overall, the carbon tax increased the price by USD $rounded_price_increase and reduced the total output produced by both firms by $rounded_quantity_decrease units  of output.
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
# ╠═e22a64a9-f57d-44f1-b77c-697dbc9116c7
# ╠═3e0ad8ad-8acf-468e-8bb6-85a258cc8b92
# ╟─276bfd3c-6406-49e9-b270-5e6ae286221c
# ╠═11c8bf82-06d1-4d70-b445-3e87ce8ff9f6
# ╟─9555c941-ed7d-4eb6-bdd8-0e62fa95f3c3
# ╟─9e867ead-3a11-4216-9e6b-7f9d077d9503
# ╠═dfef4026-100a-47d3-ab63-55b80b6c6d35
# ╟─1314ae51-4e3d-4993-9b9e-b948e0cd0600
# ╟─777a2a0d-0f99-4fd0-a62b-590995718052
# ╟─6a312d0c-fbea-4e9e-a5a3-c0bc85170c3f
# ╟─586da741-9a05-4192-b491-22bdc84c35cc
# ╟─eb094b1d-67d4-48e8-b667-a3721f537337
# ╟─af137d1f-1141-4e35-be06-3ebf8af63e6c
# ╠═e76ad736-a1a6-4a2b-9309-ba36d6a0a9bf
# ╟─4dbe1681-6c3c-499f-8dcd-426720b43f86
# ╠═67bfa521-192b-48ab-982e-e8e3dcbe951c
# ╟─4fa41716-6df5-4d7e-8dba-008b29cdb1fd
# ╟─68aee96a-12e2-4155-b7fa-950493e82c9c
# ╟─c40c6447-e2ee-43ca-9c4e-a6332cb63cba
# ╟─03752178-755a-4ba5-a79f-7e3115c41605
# ╟─41e702c6-44f3-4e2d-b37d-a9865af888fe
# ╟─603f1acf-7594-43bf-8db6-57ab66da1032
# ╟─16a72325-4eec-4ec8-81e5-b8225133deab
# ╟─b84d9d9e-0cea-4ff2-a419-02d628ad6b0d
# ╠═af9c1d06-539f-49b9-9d7f-8dab11ee2596
# ╟─07436047-5502-42e8-b7a7-6c3614b34590
# ╠═76cd98ce-fb3f-49db-b27f-1cb1ac5378f7
# ╟─240daf8c-cebb-479c-bdec-44013b03c821
# ╟─03fd59b8-e5d2-4a7f-8856-0bda4327bafb
# ╟─49cbc9c3-43a5-49b9-8331-0b7e6134a164
# ╠═2275fa44-5c58-40ad-8be5-aa3a2fb563db
# ╠═6d2c21a1-ba81-4972-bf5c-623d01db8c25
# ╠═dcc719f6-e791-4908-99f0-319e08712ed2
