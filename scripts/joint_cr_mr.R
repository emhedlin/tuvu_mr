
# Joint analysis of capture-recapture and mark-recovery

# An important difference between capture–recapture and mark-recovery data 
# is that they are often informative about two different kinds of survival probability. 
# As we have seen in Chapter 7, capture–recapture data pro- vide an estimate of apparent 
# survival, which is the probability of surviving and remaining in the study area. By contrast, 
# true survival can be estimated from mark-recovery data. The difference between the two 
# estimates of survival arises because sampling of marked individuals in capture–recapture 
# studies is restricted to the study area (an exception might be studies using color marks), 
# whereas dead recoveries can be obtained from anywhere. Apparent survival (φ) and true survival (s) 
# are linked through site fidelity (F) via the relationship φ = s*F. A joint analysis allows one 
# to estimate all three parameters.

# The multistate model for the joint analysis of capture–recapture and mark-recovery data has 
# four states: “alive in the study area”, “alive outside the study area”, “recently dead”, and “dead”.
# It may seem strange to have two dead states; however, this is necessary because only individuals 
# recently dead can be recovered. An individual in the state “recently dead” at occasion t has died
# between occasions t − 1 and t. From occasion t + 1 onwards, the individual can no longer be recovered. 
# This assumption applies to the ana- lysis of mark-recovery data as well. Therefore, “recently dead” 
# individuals move to the state “dead” at the next occasion. One says that “dead” is an absorbing state; 
# once individuals are in it, they cannot get out anymore. 

# The transition matrix of the joint model looks like the following:

#                     alive,      alive     recently       
#                    inside     outside      dead        dead     

#   alive, inside      sF        s(1-F)      1-s          0       
#   alive, outside     0           s         1-s          0       
#   recently  dead     0           0          0           1       
#         dead         0           0          0           1       

# s = true survival probability
# F = fidelity probability - probability to remain in study area given individual is alive
# 1-F = inverse fidelity - probability to emigrate permanently from study area


# possible observations are: "seen alive", "recovered dead", "not seen or recovered"
# observation matrix

#                    seen      recovered     not seen       
#                    alive     dead          or recovered     

#   alive, inside      p           0           1-p                
#   alive, outside     0           0            1                
#   recently  dead     0           r           1-r                 
#         dead         0           0            1             

# p = recapture probability - probability to encounter an individual alive and in the study area
# r = recovery probability - recovery probability is the probability to find and report an individual in the state “recently dead”









