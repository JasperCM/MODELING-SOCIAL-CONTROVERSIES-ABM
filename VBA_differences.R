library(ggplot2)
library(data.table)
library(reshape2)

# For memory issues
##rm(list = ls())
# note it is recomended to remove specific dataframes at intermediate steps to save RAM, otherwise R will freeze up
.rs.restartR()

# import datafile
Smallset = read.csv("social_conflict_in_ccs_v6_VBA_differences_table.csv", header = TRUE, sep = ",", skip = 6, check.names = FALSE)
# shorthand to know which columns to remove
Smallset[1:3, 9, 13:14,23] <- NULL

# replacing interfering symbols
names(Smallset) <- gsub(pattern = "\\]", replacement = "", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\[", replacement = "", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\(", replacement = "", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\)", replacement = "", x = names(Smallset))
names(Smallset) <- gsub(pattern = "<", replacement = "_smaller_than_", x = names(Smallset))
names(Smallset) <- gsub(pattern = ">=", replacement = "_larger_or_equal_to_", x = names(Smallset))
names(Smallset) <- gsub(pattern = " ", replacement = "_", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\-", replacement = "_", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\*", replacement = "times", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\/", replacement = "divided_by", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\?", replacement = "", x = names(Smallset))
names(Smallset) <- gsub(pattern = "\\_+", replacement = "_", x = names(Smallset))
names(Smallset)[names(Smallset)=="100_times_number_of_dissatisfied_citizens_divided_by_number_of_citizens"] <- "percentage_dissatisfied_citizens"
names(Smallset)[names(Smallset)=="step"] <- "tick"
Smallset<- Smallset[!(Smallset$tick == 0),]
names(Smallset)[names(Smallset)=="Accept_vba_difference_attitude0"] <- "Start_accept"   
names(Smallset)[names(Smallset)=="Reject_vba_difference_attitude0"] <- "Start_reject"  
names(Smallset)[names(Smallset)=="Added_accepted_vba_diff_per_attitude"] <- "Xaccept"
names(Smallset)[names(Smallset)=="Added_rejected_vba_diff_per_attitude"] <- "Xreject"

names(Smallset)[names(Smallset)=="count_citizens_with_attitude_smaller_than_20"] <- "0to20"
names(Smallset)[names(Smallset)=="count_citizens_with_attitude_larger_or_equal_to_20_and_attitude_smaller_than_40"] <- "20to40"
names(Smallset)[names(Smallset)=="count_citizens_with_attitude_larger_or_equal_to_40_and_attitude_smaller_than_60"] <- "40to60"
names(Smallset)[names(Smallset)=="count_citizens_with_attitude_larger_or_equal_to_60_and_attitude_smaller_than_80"] <- "60to80"
names(Smallset)[names(Smallset)=="count_citizens_with_attitude_larger_or_equal_to_80"] <- "80to100"


names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_1_smaller_than_20"] <- "1vb0to20"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_1_larger_or_equal_to_20_and_citizen_vba_component_1_smaller_than_40"] <- "1vb20to40"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_1_larger_or_equal_to_40_and_citizen_vba_component_1_smaller_than_60"] <- "1vb40to60"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_1_larger_or_equal_to_60_and_citizen_vba_component_1_smaller_than_80"] <- "1vb60to80"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_1_larger_or_equal_to_80"] <- "1vb80to100"

names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_2_smaller_than_20"] <- "2vb0to20"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_2_larger_or_equal_to_20_and_citizen_vba_component_2_smaller_than_40"] <- "2vb20to40"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_2_larger_or_equal_to_40_and_citizen_vba_component_2_smaller_than_60"] <- "2vb40to60"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_2_larger_or_equal_to_60_and_citizen_vba_component_2_smaller_than_80"] <- "2vb60to80"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_2_larger_or_equal_to_80"] <- "2vb80to100"

names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_3_smaller_than_20"] <- "3vb0to20"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_3_larger_or_equal_to_20_and_citizen_vba_component_3_smaller_than_40"] <- "3vb20to40"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_3_larger_or_equal_to_40_and_citizen_vba_component_3_smaller_than_60"] <- "3vb40to60"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_3_larger_or_equal_to_60_and_citizen_vba_component_3_smaller_than_80"] <- "3vb60to80"
names(Smallset)[names(Smallset)=="count_citizens_with_citizen_vba_component_3_larger_or_equal_to_80"] <- "3vb80to100"

#Getting a subset for the bar charts
Endpoint <- Smallset [which(Smallset$tick == 100), ]
Midpoint <- Smallset [which(Smallset$tick == 50), ]

Endpointmelt <- melt(Endpoint, measure.vars=c("0to20",
                                             "20to40",
                                             "40to60",
                                             "60to80",
                                             "80to100"), value.name = "Number_of_citizens_attitude", variable.name = "Attitude_scales")

MeltComponents <- melt(Endpoint, measure.vars=c("1vb0to20",
                                                "1vb20to40",
                                                "1vb40to60",
                                                "1vb60to80",
                                                "1vb80to100"), value.name = "Number_of_citizens_Component_1", variable.name = "Component_1_value")

MeltComponents <- melt(MeltComponents, measure.vars=c("2vb0to20",
                                                      "2vb20to40",
                                                      "2vb40to60",
                                                      "2vb60to80",
                                                      "2vb80to100"), value.name = "Number_of_citizens_Component_2", variable.name = "Component_2_value")

MeltComponents <- melt(MeltComponents, measure.vars=c("3vb0to20",
                                                      "3vb20to40",
                                                      "3vb40to60",
                                                      "3vb60to80",
                                                      "3vb80to100"), value.name = "Number_of_citizens_Component_3", variable.name = "Component_3_value")



Endpointmelt <- melt(Midpoint, measure.vars=c("0to20",
                                               "20to40",
                                               "40to60",
                                               "60to80",
                                               "80to100"), value.name = "Number_of_citizens_attitude", variable.name = "Attitude_scales")

MeltComponents <- melt(Midpoint, measure.vars=c("1vb0to20",
                                                "1vb20to40",
                                                "1vb40to60",
                                                "1vb60to80",
                                                "1vb80to100"), value.name = "Number_of_citizens_Component_1", variable.name = "Component_1_value")

MeltComponents <- melt(MeltComponents, measure.vars=c("2vb0to20",
                                                      "2vb20to40",
                                                      "2vb40to60",
                                                      "2vb60to80",
                                                      "2vb80to100"), value.name = "Number_of_citizens_Component_2", variable.name = "Component_2_value")

MeltComponents <- melt(MeltComponents, measure.vars=c("3vb0to20",
                                                      "3vb20to40",
                                                      "3vb40to60",
                                                      "3vb60to80",
                                                      "3vb80to100"), value.name = "Number_of_citizens_Component_3", variable.name = "Component_3_value")

## plots

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=mean_attitude_of_citizens)) + 
  facet_grid(Difference_in_vba_value1 ~ 
               Difference_in_vba_value2 + Difference_in_vba_value3,labeller=label_both)

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=mean_attitude_of_citizens  )) + 
  facet_grid(Start_accept + Xaccept ~Start_reject + Xreject + Relative_power_counter_vba,labeller=label_both)

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=median_attitude_of_citizens  )) + 
  facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=average_euclidean_distance_average_citizens_vs_project_leaders  )) + 
  facet_grid(Start_accept + Xaccept ~Start_reject + Xreject,labeller=label_both)

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=average_euclidean_distance_average_citizens_vs_project_leaders  )) + 
  facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=average_euclidean_distance_average_citizens_vs_project_leaders  )) + 
  facet_grid(Difference_in_vba_value1 ~ 
               Difference_in_vba_value2 + Difference_in_vba_value3,labeller=label_both)

ggplot(Smallset) + 
  stat_smooth(aes(x=tick,y=mean_attitude_of_citizens  )) + 
  facet_grid(Start_accept + Xaccept ~Start_reject + Xreject + Relative_power_counter_vba,labeller=label_both)

ggplot(Smallset) + aes(tick) +
  stat_smooth(aes(y=average_citizen_vba_component_1,colour="Comp1")) + 
  stat_smooth(aes(y=average_citizen_vba_component_2,colour="Comp2")) + 
  stat_smooth(aes(y=average_citizen_vba_component_3,colour="Comp3")) + 
  facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)         

ggplot(Smallset) + aes(tick) +
  stat_smooth(aes(y=average_project_leader_vba_component_1,colour="Comp1")) + 
  stat_smooth(aes(y=average_project_leader_vba_component_2,colour="Comp2")) + 
  stat_smooth(aes(y=average_project_leader_vba_component_3,colour="Comp3")) +   
  facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)         

# HYSTOGRAMS
#This part of code is concerned with making hystograms

# status at end
# attitudes
ggplot(aes(x = Attitude_scales, y = Number_of_citizens_attitude), data = Endpointmelt) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Difference_in_vba_value1 + 
                                                                                Difference_in_vba_value2~Difference_in_vba_value3,labeller=label_both)

ggplot(aes(x = Attitude_scales, y = Number_of_citizens_attitude), data = Endpointmelt) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)

ggplot(aes(x = Attitude_scales, y = Number_of_citizens_attitude), data = Endpointmelt) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Start_accept + Xaccept + Difference_in_vba_value1 ~Start_reject + Xreject + Difference_in_vba_value2+Difference_in_vba_value3,labeller=(label_both))

#component 1
ggplot(aes(x = Component_1_value, y = Number_of_citizens_Component_1), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Difference_in_vba_value1 + 
                                                                                Difference_in_vba_value2~Difference_in_vba_value3,labeller=label_both)

ggplot(aes(x = Component_1_value, y = Number_of_citizens_Component_1), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)

ggplot(aes(x = Component_1_value, y = Number_of_citizens_Component_1), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Start_accept + Xaccept ~Start_reject + Xreject,labeller=(label_both))

#component 2

ggplot(aes(x = Component_2_value, y = Number_of_citizens_Component_2), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Difference_in_vba_value1 + 
  Difference_in_vba_value2~Difference_in_vba_value3,labeller=label_both)

ggplot(aes(x = Component_2_value, y = Number_of_citizens_Component_2), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)

ggplot(aes(x = Component_2_value, y = Number_of_citizens_Component_2), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Start_accept + 
  Xaccept ~Start_reject + Xreject,labeller=(label_both))

#component 3

ggplot(aes(x = Component_3_value, y = Number_of_citizens_Component_3), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Difference_in_vba_value1 + 
  Difference_in_vba_value2~Difference_in_vba_value3,labeller=label_both)

ggplot(aes(x = Component_3_value, y = Number_of_citizens_Component_3), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Normal_distribution_projectleaders~Normal_distribution_citizens,labeller=label_both)

ggplot(aes(x = Component_3_value, y = Number_of_citizens_Component_3), data = MeltComponents) + 
  stat_summary(fun.y = "mean", geom = "bar", position = "dodge") + facet_grid(Start_accept + 
  Xaccept ~Start_reject + Xreject,labeller=(label_both))

