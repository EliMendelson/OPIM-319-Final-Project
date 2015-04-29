This is the project for OPIM 319 - Spring 2015, taught by Professor Steven O. Kimbrough. It is written in NetLogo.

Trading Clusters

- board with variety of agents
	- 2 resources
	- each agent has knowledge of 2 resources
		- accuracy of knowledge is dependent on distance from the resources
	- grouping agents within certain boundaries
- we want to study if agents of any given group will develop trade relationships with other particular groups (for example, would the group with 60% knowledge of one resource and 40% of the other trade with the 40%/60% group)

There is a phenomenon in Major League Baseball that certain teams trade with each other more than anyone else, and our question is whether we can create a model in NetLogo that can simulate such an environment. We are still nailing down some of the details, but our basic idea is to create a grid with two resources dispersed across it. Agents will be randomly placed throughout the grid and a valuation of each of the two resources based on their initial positioning (say 85% of the true Resource 1 and 130% of Resource 2 if they are near a lot of Resource 1 but not much of Resource 2). Agents will also be given an initial allotment of each resource. Then they will start moving and trading with the agents around them with a rule something like this: “talk” to the five agents closer to you, attempt to make the best deal possible with each of them, and then choose the best one. Then we could say that each agent then moves to a random spot elsewhere on the board and continues that process. We could group the agents into say six groups (high on Resource 1 & low on R2, medium on R1 & high on R2, etc.) and record the number of transactions that took place between Group 1 and Group 1, Group 2 and Group 3, etc. Will similar agents trade a lot together or will agents with opposite tendencies trade together? There are a lot of questions arising in my head as I write this and we will probably have to simplify much of what I have said here, but we think that we can create a model that will provide insight into our question.