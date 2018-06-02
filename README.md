# MODELING-SOCIAL-CONTROVERSIES-ABM
EXPLORING THE WAYS CONFLICTING ATTITUDES ARISE FROM CLASHING VALUE-BASED ASSESSMENTS OF A CONTROVERSIAL PROJECT USING AGENT-BASED MODELING.

By Nourian Peters, Jasper Meijering & Maarten van de Kamp.


This repo contains the netlogo file of the study. It also contains 4 R scripts that have been used for experimentation.
Please contact the contributors with ang questions.

# WHAT IS IT?
This explorative model shows how social conflicts emerge and evolve, based on the carbon capture and storage-project in Barendrecht, where increasing local opposition led to an intensified debate and ultimately resulted in cancelling the project because of a lack of support.
Following the conceptual model of Pesch et al (2017), that stresses the importance of values in the trajectory of such a project, this model looks at the impact of an emphasis on certain values by the projectleaders, and neglecting others, which possibly results in polarization.
Central in this model is the notion of a ‘value-based assessment’ (VBA). Both agent-types (projectleaders and citizens) have a VBA. When there are substantial differences between the joint VBA of the projectleaders and the VBA of a citizen, this might lead to a reaction: their attitude to the project will be more negative. Because citizens mutually affect their VBAs, polarization is likely to occur when there are repeated differences between VBAs of projectleaders and citizens.

# HOW IT WORKS
Each type of agents (citizens and projectleaders) forms its own seperate network. In the case of the citizens this is a network based on preferential attachment, meaning that citizens with a lot of friends (network links) have a higher chance of forming new links. In the case of the project leaders the network is fully conected, meaning that each project leader is linked to all other project leaders.
After VBAs are assigned to both citizens and projectleaders, citizens also have an initial attitude to the project, and the networks has been set up, the model can run. This starts each round of interactions (tick) with determining and transmissing a joint VBA by the projectleaders.
Based on their initial attitude and the difference between this transmitted VBA and their own VBA, the attitude of citizens changes: a large VBA-difference leads to a more negative attitute, while a small difference leads to a more positive attitude. It is also possible to react neutrally.
After that, citizens mutually affect each others VBA, based on the position in the network. A citizen with many connections will have a greater impact on other citizens’ VBAs: beside being connected to more citizens and thus influencing more others, they also have more power determining the VBAs of these others.
Lastly, if the attitude of citizens gets under a certain threshold, citizens will take actions and express their dissatisfaction, translated into a counter-VBA. When the projectleaders determine the new joint VBA, this counter-VBA is taken into account. This should make the new transmitted VBA more receptive to citizens.

# HOW TO USE IT
Next to parameters used in the setup- and go-phase, there are a few general parameters in the interface. See the inferface for more guiding remarks.
Setup - sets up the model, meaning that it creates the networks of citizens and project leaders, assigns their initial values and assigns initial global values
Go once - runs the model for a single tick
Go - runs the model until the button is activated again
Citizen-influence-others-attitude? - if switched on citizens will also influence each others attitude in addition to each others VBA
Reporter? - If switched on the model will note down model values in the command center for verification
The block in the middle shows the networks of both citizens (red triangles) and projectleaders (blue triangles). The plots below it show the average attitude of citizens, the percentage of dissatisfied citizens and a histogram showing the distribution of attitude among citizens.

# SETUP
Number-of-projectleaders - determines the number of project-leader agents in the model
Number-of-citizens - determines the number of citizen agents in the model
Normal-distribution-citizens? - if turned on the setting of the vba’s of citizens will be done according to a normal distribution. If switched-off this will be done according to a uniform distribution
Normal-distribution-projectleaders? - if turned on the setting of the vba’s of project leaders will be done according to a normal distribution. If switched-off this will be done according to a uniform distribution
Normal-sd-citizen - Defines the standard deviation used for setting the vba’s of citizens. This is only applicable if the Normal-distribution-citizens? switch is turned on.
Normal-sd-project-leader - Defines the standard deviation used for setting the vba’s of project leaders. This is only applicable if the Normal-distribution-projectleaders switch is turned on.
Number-of-values - Defines how many values form a vba. This applies to all vba’s
Difference-in-vba-value’X’ - With X varying from 1 to 5 - Defines differences between the vba elements of project leaders and citizens. Heightening this value with one increases the average value of the element with 0.5 for the project leaders, lowering the citizen value with 0.5 per point increase.

# GO
NB: Some references are made to figure 10: this can be found in the report.
Accept-vba-difference-attitude0 - Determines the ‘starting point’ of the function at an attitude of 0. Making this slider larger will increase the numerical differences between the VBAs that will lead to a positive reaction (see the blue circle in figure 10). Setting this parameter to 10, means that a VBA-difference (between the citizen and the transmitted VBA) of 10 and smaller leads to a positive reaction. A bigger difference leads to a neutral or negative reaction, dependent on the parameter determining the rejection threshold (Reject-vba-difference-attitude0).
Added-accepted-vba-diff-per-attitude - Determines the amount by which attitude is multiplied to get to the threshold for acceptance of a transmission. This can be seen as the slope of the function, thus influencing the angle of the function (blue line). If a citizen’s VBA difference with a transmitted frame is under the blue line taking into account its attitude value the citizen will accept a transmission.
Reject-vba-difference-attitude0 - Determines the addition of the function at an attitude of 0. Making this slider larger will decrease the numerical differences between the VBAs that will lead to a negative reaction (see the red circle). Setting this parameter to 20, means that a VBA-difference of higher than 20 leads to a negative reaction.
Added-rejected-vba-diff-per-attitude - Determines the amount by which attitude is multiplied to get to the threshold for rejection of a transmission. This influences the angle of the function (red line). If a citizen’s VBA difference with a transmitted frame is above the red line taking into account its attitude value the citizen will reject a transmission.
Attitude-shift-positive - determines the value by which a citizens attitude increases when reacting positively
Attitude-shift-negative - determines the value by which a citizens attitude decreases when reacting negatively
Threshold-counter-vba - Determines under which attitude value citizens will start transmitting counter-VBAs to influence the next transmitted VBA
Relative-power-counter-vba - Increase or decreases the highest amount of influence a counter frame can exert, compared to all project leaders. A value of 100 states that the counter-VBA is equally important as the VBA’s of all the projectleaders in determining the new transmitted VBA.

# EXTENDING THE MODEL
There are some general restrictions to the developed model, especially with respect to the manner citizens are influenced.
First of all, it is assumed all citizens are evenly involved in the project and thus evenly affected each time a joint VBA is transmitted, while this might differ per citizen and per moment (e.g. citizens might not even know that there was a transmitted VBA in the first place).
Secondly, citizen VBAs are only affected by each other, while external influences and influence by project leaders can be relevant too. Now, these interactions are governed by the network structure and the power each citizen has is based on their position, which could lead to an overestimation of the effect citizens have on each other.

# CREDITS AND REFERENCES
Pesch, U., Correljé, A., Cuppen, E., Taebi, B., & van de Grift, E. (2017). Formal and Informal Assessment of Energy Technologies. In Responsible Innovation 3 (pp. 131-148). Springer, Cham.
