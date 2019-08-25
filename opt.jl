using JuMP, Gurobi
using ExcelReaders

interventionCapacities = readxl("/Users/amulya/Documents/opt_data.xlsx", "Sheet1!T2:AB2")

baseProb = readxl("/Users/amulya/Documents/opt_data.xlsx", "Sheet1!A2:A421")
counterFactualProb = readxl("/Users/amulya/Documents/opt_data.xlsx", "Sheet1!B2:J421")
y = readxl("/Users/amulya/Documents/opt_data.xlsx", "Sheet1!K2:S421")

numPeople = size(counterFactualProb,1)
numInterventions = size(counterFactualProb,2)

# pass params as keyword arguments to GurobiSolver
model = Model(with_optimizer(Gurobi.Optimizer, Presolve=0))

@defVar(model, x[1:numPeople,1:numInterventions], Bin)
@defVar(model, c[1:numPeople], Bin)

@addConstraint(model, constr1[i=1:numPeople], sum{x[i][j], j=1:numInterventions} <= 1)
#equality constraints
@addConstraint(model, constr2[i=1:numPeople], sum{x[i][j], j=1:numInterventions} = c[i])
#capacity constraints
@addConstraint(model, constr3[j=1:numInterventions], sum{x[i][j], i=1:numPeople} <= interventionCapacities[j])

@setObjective(model, Min, sum(((y[i][j]*x[i][j]*counterFactualProb[i][j]) + (1-c[i])*baseProb[i]) for i in 1:numPeople, j in 1:numInterventions))

optimize!(model)
println("Optimal objective: ", objective_value(model),". x = ", value(x), " y = ", value(y))
