extensions [matrix nw array]

globals [
  ;;;;;;;;;;                  Input variables, in comments because they are input variables (TO BE UPDATED!)
;Number-of-projectleaders, 		         A description of this variable can be found in the Info tab (HOW TO USE IT)
;Number-of-citizens, 			             "
;Citizen-influence-others-attitude?    "
;Reporter?                             "
;Number-of-values                      "
;Difference-in-vba-value'X'            "
;Normal-distribution-citizens?		     "
;Normal-distribution-projectleaders?   "
;Normal-sd-citizen                     "
;Normal-sd-project-leader              "
;Accept-vba-difference-attitude0       "
;Added-accepted-vba-diff-per-attitude  "
;Reject-vba-difference-attitude0       "
;Added-rejected-vba-diff-per-attitude  "
;Attitude-shift-positive               "
;Attitude-shift-negative               "
;Threshold-counter-vba  		           "
;Relative-power-counter-vba            "

  ;;Normal globals
transmission-vba		                  ;Value for storing transmission VBA
current-counter-vba? 		              ;value signifying if there is a counter VBA
counter-vba		                        ;value for storing a counter VBA for the next round
number-of-dissatisfied-citizens
average-citizen-vba-component-1
average-citizen-vba-component-2
average-citizen-vba-component-3
average-project-leader-vba-component-1
average-project-leader-vba-component-2
average-project-leader-vba-component-3
average-euclidean-distance-citizens-mean
average-euclidean-distance-citizens-vs-project-leaders
average-euclidean-distance-average-citizens-vs-project-leaders
]

breed [project-leaders project-leader]
breed [citizens citizen]

project-leaders-own[
vba-project-leader
]


citizens-own[
  vba-citizen ; the vector of values
  attitude ; 0 - 100
  friendcount ; number of links
  temp-citizen-vba ; computational variable
  store-citizen-vba; variable to allow for changing of citizen vba after all changed positions have been calculated
  store-citizen-attitude; variable for storing attitudes
  citizen-vba-component-1
  citizen-vba-component-2
  citizen-vba-component-3
]


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
    if Reporter? [
  Print ""
  print "-SETUP-"]
  clear-all
  reset-ticks
  setup-globals
  setup-network ;; dynamic network
  setup-project-leaders
  setup-citizens
end


to setup-globals
  set transmission-vba matrix:make-constant 1 number-of-values 0
  set counter-vba matrix:make-constant 1 number-of-values 0
  set current-counter-vba? 0
end

to setup-network
  ;; creates preferential attachment network using network extensions
  nw:generate-preferential-attachment citizens links Number-of-citizens [set color red]
  repeat 50 [ layout-spring turtles links 0.8 1 1 ]

  ;;create the required number of project leaders
  create-project-leaders Number-of-projectleaders
  layout-circle project-leaders (world-width / 3 - 1)

  ;; Now make all possible links
  ask project-leaders [
    create-links-with other project-leaders
    set color blue
  ]
end

to setup-project-leaders
  ; Assign vba project-leaders
if Reporter? [
  Print ""
  print "VBA of project leaders"]
  ask project-leaders  [
    ;;first create the matrix or vector
    ;;creates a matrix of one row with as many columns as set number-of-values with value 0
    set vba-project-leader matrix:make-constant 1 number-of-values 0

    ;;set individual values using a counter to select each element of vba
    let value-number 0
    while [value-number < number-of-values]
    [
      ifelse Normal-distribution-projectleaders?        ;; if distribution type should be normal
        [ let assigned-value 0
          if value-number = 0 [ set assigned-value random-normal (50 + 0.5 * Difference-in-vba-value1) normal-sd-project-leader ]
          if value-number = 1 [ set assigned-value random-normal (50 + 0.5 * Difference-in-vba-value2) normal-sd-project-leader ]
          if value-number = 2 [ set assigned-value random-normal (50 + 0.5 * Difference-in-vba-value3) normal-sd-project-leader ]
          if value-number = 3 [ set assigned-value random-normal (50 + 0.5 * Difference-in-vba-value4) normal-sd-project-leader ]
          if value-number = 4 [ set assigned-value random-normal (50 + 0.5 * Difference-in-vba-value5) normal-sd-project-leader ]
          if assigned-value >= 100 [set assigned-value 100]     ;;catch values outside range
          if assigned-value <= 0 [set assigned-value 0]
          matrix:set vba-project-leader 0 value-number assigned-value
          set value-number value-number + 1 ]
        [ let assigned-value 0                           ;; if distribution should be uniform
          if value-number = 0 [ set assigned-value random-float (100 - Difference-in-vba-value1) + Difference-in-vba-value1]
          if value-number = 1 [ set assigned-value random-float (100 - Difference-in-vba-value2) + Difference-in-vba-value2]
          if value-number = 2 [ set assigned-value random-float (100 - Difference-in-vba-value3) + Difference-in-vba-value3]
          if value-number = 3 [ set assigned-value random-float (100 - Difference-in-vba-value4) + Difference-in-vba-value4]
          if value-number = 4 [ set assigned-value random-float (100 - Difference-in-vba-value5) + Difference-in-vba-value5]
          matrix:set vba-project-leader 0 value-number assigned-value
          set value-number value-number + 1 ]
    ]
    if Reporter? [ print vba-project-leader]
  ]
end

to setup-citizens
  if Reporter? [
    print ""
    print "VBA of citizens"]
  ; Assign vba citizens
  ask citizens  [
    ;;first create the matrix or vector
    ;;creates a matrix of one row with as many columns as set number-of-values with value 0
    set vba-citizen matrix:make-constant 1 number-of-values 0

    ;;set individual values using a counter to select each element of vba
    let value-number 0
    while [value-number < number-of-values]
    [ ifelse Normal-distribution-citizens?       ;; if distribution should be normal
      [ let assigned-value 0
        if value-number = 0 [ set assigned-value random-normal (50 - 0.5 * Difference-in-vba-value1) normal-sd-citizen ]
        if value-number = 1 [ set assigned-value random-normal (50 - 0.5 * Difference-in-vba-value2) normal-sd-citizen ]
        if value-number = 2 [ set assigned-value random-normal (50 - 0.5 * Difference-in-vba-value3) normal-sd-citizen ]
        if value-number = 3 [ set assigned-value random-normal (50 - 0.5 * Difference-in-vba-value4) normal-sd-citizen ]
        if value-number = 4 [ set assigned-value random-normal (50 - 0.5 * Difference-in-vba-value5) normal-sd-citizen ]
        if assigned-value >= 100 [set assigned-value 100]           ;;catch values outside range
        if assigned-value <= 0 [set assigned-value 0]
        matrix:set vba-citizen 0 value-number assigned-value
        set value-number value-number + 1]
      [ let assigned-value 0                           ;; if distribution should be uniform
        if value-number = 0 [ set assigned-value random-float (100 - Difference-in-vba-value1)]
        if value-number = 1 [ set assigned-value random-float (100 - Difference-in-vba-value2)]
        if value-number = 2 [ set assigned-value random-float (100 - Difference-in-vba-value3)]
        if value-number = 3 [ set assigned-value random-float (100 - Difference-in-vba-value4)]
        if value-number = 4 [ set assigned-value random-float (100 - Difference-in-vba-value5)]
        matrix:set vba-citizen 0 value-number assigned-value
        set value-number value-number + 1]
    ]

    ; Assign attitude
    set attitude random 101
    ; assign number of friends
    set friendcount count (link-neighbors)
    if Reporter? [
      print "vba"
      print vba-citizen
      print "attitude"
      print attitude
      print "friendcount"
      print friendcount
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;


to go
    if Reporter? [
  Print ""
  print "-GO-"]
  transmit-vba
  determine-attitude
  discuss-vba
  create-counter-vba
  make-experiment-values
  tick
end

to transmit-vba
  if Reporter? [ print "" print "Creation transmission frame" ]
  ;; set initial transmission value enabling or disabling counter-vba if applicable, counter is weighted based on its relative power and the fraction of citizens involved in making the counter
  let transmission-temp matrix:times counter-vba  (current-counter-vba? * ((Relative-power-counter-vba / 100 ) * Number-of-projectleaders) * ( number-of-dissatisfied-citizens / Number-of-citizens))
  if Reporter? [ print "counterframe if any" print transmission-temp ]
  ;; create list of vba's of project leaders
  let list-vba-project-leaders [vba-project-leader] of project-leaders
  ;;create array to open up list of matrices for calculations via a loop
  let vba-array-project-leaders array:from-list list-vba-project-leaders
  if Reporter? [ print "list of VBA's project leaders" print vba-array-project-leaders ]

  ;;create ticker for while loop enabling individual selection of matrices
  let number-projectleader 0
  if Reporter? [ print "sequential addition of project leader VBA's"]
  while [number-projectleader < Number-of-projectleaders]
  [
    ;; adds array values sequentially to the temporary transmission value
    set transmission-temp matrix:plus transmission-temp array:item vba-array-project-leaders number-projectleader
    if Reporter? [ print  transmission-temp ]
    set number-projectleader number-projectleader + 1
  ]
  ;; makes a weighted average by deviding the temporary transmission vallue with the number of project leaders + the weights of the counter if applicable
  set transmission-vba matrix:times (1 / (Number-of-projectleaders + (current-counter-vba? * ((Relative-power-counter-vba / 100 ) * Number-of-projectleaders) * (number-of-dissatisfied-citizens / Number-of-citizens) ))) transmission-temp
  if Reporter? [
   print "transmission VBA"
    print transmission-vba ]
end

to determine-attitude
  if Reporter? [ print "" print "reactions of citizens to a transmission"]
  ask citizens [
    let vba-difference matrix:minus vba-citizen transmission-vba ;; creates a temporary variable which is the citizen vba minus the transmission vba
    if Reporter? [ print "vba difference" print vba-difference print "sequential addition of absolute component values to get to absolute difference"]
    let normalized-absolute-VBA-difference 0 ;; creates temporary variable used to calculate the absolute differences between the vba's
    let value-number-vba 0
    while [value-number-vba < number-of-values] [
      ;;sets absolute difference to a sequential sum of absolute elements of the absolute-vba-difference to calculate absolute difference
      set normalized-absolute-VBA-difference normalized-absolute-VBA-difference + abs matrix:get vba-difference 0 value-number-vba
      if Reporter? [
        print normalized-absolute-VBA-difference
]
      set value-number-vba value-number-vba + 1
    ]
    set normalized-absolute-VBA-difference normalized-absolute-VBA-difference / number-of-values

    ;;determine reaction based on hysteresis. The thresholds are determined by a function of attitude with inputs;;
 if Reporter? [print "starting attitude"
        print attitude ]
    if (normalized-absolute-VBA-difference < (attitude * Added-accepted-vba-diff-per-attitude + Accept-vba-difference-attitude0)) and
       (normalized-absolute-VBA-difference < (attitude * Added-rejected-vba-diff-per-attitude + Reject-vba-difference-attitude0))
    [ set attitude attitude + Attitude-shift-positive
      if Reporter? [
        print "new attitude (positive), values larger than 100 will be set to 100" ;; the larger than 100 part happens outside of the while
        print attitude ] ]
    if (normalized-absolute-VBA-difference > (attitude * Added-rejected-vba-diff-per-attitude + Reject-vba-difference-attitude0))
    [ set attitude attitude + Attitude-shift-negative
      if Reporter? [
        print "new attitude (negative), values smaller than 0 will be set to 0" ;; the smaler than 0 part happens outside of the while
        print attitude ] ]
    if (normalized-absolute-VBA-difference >= (attitude * Added-accepted-vba-diff-per-attitude + Accept-vba-difference-attitude0)) and
       (normalized-absolute-VBA-difference <= (attitude * Added-rejected-vba-diff-per-attitude + Reject-vba-difference-attitude0))
    [ set attitude attitude + 0 ;; the + 0 is leftover code from potential cooldown mechanism with two if functions one could make a cooldown to 50 for example, client didn't want this in the end

      if Reporter? [
        print "new attitude (neutral)"
        print attitude] ]

    if attitude > 100 [ set attitude 100 ]
    if attitude < 0 [ set attitude 0 ]
  ]
end

to discuss-vba
  if Reporter? [ print "" print "influencing individual citizens"]
  ask citizens [
    set temp-citizen-vba matrix:times vba-citizen friendcount ;; pre-calculates weighted vba's of citizens to make the programming easier to follow, state because it needs to be accessable for other citizens
    set store-citizen-vba temp-citizen-vba ;; sets another variable for calculation at their starting point, ensures a citizens own vba is included
    ]
  ask citizens [
    let friend-list-vba [temp-citizen-vba] of in-link-neighbors ;; creates a list of the vba's of neigbouring citizens
    let friend-array-vba array:from-list friend-list-vba ;; changes the list into an array
    if Reporter? [
      print "list of weighted (I.E. times number of friends) vba's friends"
      print friend-array-vba ]
    if Reporter? [ print "sequential additions of weighted vba's of friends with own"]
    let friend-number 0 ;; friend-number variable to allow for sequential addition of vba's
    while [friend-number < friendcount] [ ;; ensures loop stops if all items (friends) in the array have been handled
      set store-citizen-vba matrix:plus store-citizen-vba array:item friend-array-vba friend-number ;; adds weighted vba's of friends together with own vba
      if Reporter? [ print store-citizen-vba ]
      set friend-number friend-number + 1
    ]
    if Reporter? [ print "total sum of own friendcount and friend's friendcount. Used as a divider for the weighted average"
      print sum [friendcount] of in-link-neighbors + friendcount ]
    set store-citizen-vba matrix:times (1 / (sum [friendcount] of in-link-neighbors + friendcount)) (store-citizen-vba)
  ]
  ;; sets actual vba to new value
  ;; seperate ask te ensure that all citizens have determined their new value
  ask citizens [
    set vba-citizen store-citizen-vba
    if Reporter? [
      print "new VBA"
      print vba-citizen
      ]
  ]
  if Citizen-influence-others-attitude? [attitude-influence]
end

to attitude-influence      ;the new attitude is a weighted average of initial attitude plus the attitude of neighbours
  if Reporter? [ print "attitude influencing"]
  ask citizens [
    set store-citizen-attitude (sum [attitude * friendcount] of in-link-neighbors + attitude * friendcount) / (sum [friendcount] of in-link-neighbors + friendcount)
    if Reporter? [
      print "old attitude" print attitude
      print "new attitude" print store-citizen-attitude
       ] ]
  ask citizens [set attitude store-citizen-attitude]
end

to create-counter-vba
  if Reporter? [ print "" print "counter vba details"]
  let dissatisfied-citizen-list citizens with [attitude < Threshold-counter-vba] ;; make a list of all citizens lower than the threshold
  ;; make a counter for weighing the counter according to the fraction of dissatisfied citizen with relation to the transmission in the next round
  set number-of-dissatisfied-citizens count dissatisfied-citizen-list
  if Reporter? [ print "number-of-dissatisfied-citizens" print number-of-dissatisfied-citizens ]

  ifelse any? dissatisfied-citizen-list
  [ set current-counter-vba? 1 ;; activates the counter vba for integration in the transmission for the next round
    let weighted-citizen-vba-array array:from-list [matrix:times vba-citizen friendcount] of dissatisfied-citizen-list ;; makes an array of weighted vba's
    if Reporter? [ print "list of weighted vba's dissatisfied citizens" print weighted-citizen-vba-array ]
    let number-dissatisfied-citizen 0 ;; counter enabling sequential addition of vba's of dissatisfied citizens
    set counter-vba matrix:make-constant 1 number-of-values 0 ;; resets the counter-vba
    if Reporter? [ print "total friendcount for division weighted average" print sum [friendcount] of dissatisfied-citizen-list ]
    if Reporter? [ print "addition of weighted vba's"]
    while [number-dissatisfied-citizen < count dissatisfied-citizen-list]
    [ set counter-vba matrix:plus counter-vba array:item weighted-citizen-vba-array number-dissatisfied-citizen ;; adds each vba from the array
      if Reporter? [ print counter-vba ]
      set number-dissatisfied-citizen number-dissatisfied-citizen + 1
    ]
    ;; makes a vba based on a weighted average based on total friendcount
    set counter-vba matrix:times counter-vba ((1 / (sum [friendcount] of dissatisfied-citizen-list)))
    if Reporter? [
      print "New counter vba"
      print counter-vba ]
  ]
  [ set current-counter-vba? 0
    if Reporter? [ print "no counter" ]
  ]
end

to make-experiment-values       ;the average values of each component in a VBA, of both projectleaders and citizens seperately, is used to calculate VBA-distances between them.
  ask citizens [
    set citizen-vba-component-1 matrix:get vba-citizen 0 0
    set citizen-vba-component-2 matrix:get vba-citizen 0 1
    set citizen-vba-component-3 matrix:get vba-citizen 0 2
  ]

  set average-project-leader-vba-component-1 mean [matrix:get vba-project-leader 0 0] of project-leaders
  set average-project-leader-vba-component-2 mean [matrix:get vba-project-leader 0 1] of project-leaders
  set average-project-leader-vba-component-3 mean [matrix:get vba-project-leader 0 2] of project-leaders
  set average-citizen-vba-component-1 mean [citizen-vba-component-1] of citizens
  set average-citizen-vba-component-2 mean [citizen-vba-component-2] of citizens
  set average-citizen-vba-component-3 mean [citizen-vba-component-3] of citizens
  set average-euclidean-distance-citizens-mean mean [sqrt (((average-citizen-vba-component-1 - citizen-vba-component-1) ^ 2) + ((average-citizen-vba-component-2 - citizen-vba-component-2) ^ 2) + ((average-citizen-vba-component-3 - citizen-vba-component-3) ^ 2))] of citizens
  set average-euclidean-distance-average-citizens-vs-project-leaders sqrt (((average-project-leader-vba-component-1 - average-citizen-vba-component-1) ^ 2) + ((average-project-leader-vba-component-2 - average-citizen-vba-component-2) ^ 2) + ((average-project-leader-vba-component-3 - average-citizen-vba-component-3) ^ 2))
  ;
end
@#$#@#$#@
GRAPHICS-WINDOW
387
10
797
421
-1
-1
12.2
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
9
11
75
44
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
81
10
144
43
go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
6
128
199
161
Number-of-projectleaders
Number-of-projectleaders
1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
5
162
177
195
Number-of-citizens
Number-of-citizens
2
505
100.0
5
1
NIL
HORIZONTAL

SLIDER
4
326
176
359
Number-of-values
Number-of-values
1
5
3.0
1
1
NIL
HORIZONTAL

SWITCH
187
217
369
250
Normal-distribution-citizens?
Normal-distribution-citizens?
0
1
-1000

SWITCH
186
252
387
285
Normal-distribution-projectleaders?
Normal-distribution-projectleaders?
0
1
-1000

SLIDER
814
277
986
310
Attitude-shift-positive
Attitude-shift-positive
-1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
990
277
1163
310
Attitude-shift-negative
Attitude-shift-negative
-10
-1
-5.0
1
1
NIL
HORIZONTAL

SLIDER
815
374
992
407
Threshold-counter-vba
Threshold-counter-vba
05
50
20.0
5
1
NIL
HORIZONTAL

BUTTON
146
10
221
43
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
235
10
346
43
Reporter?
Reporter?
1
1
-1000

TEXTBOX
3
200
182
322
If the switches are 'on' the setup VBA values are assigned according to a normal distribution. If they are 'off' this will be a uniform distribution. The 'Difference-in-vba-valueX' (and possibly normal-sd too) inputs determine the parameters of the chosen distribution. 
11
0.0
1

SWITCH
11
46
220
79
Citizen-influence-others-attitude?
Citizen-influence-others-attitude?
1
1
-1000

INPUTBOX
219
455
334
515
normal-sd-citizen
10.0
1
0
Number

INPUTBOX
218
518
336
578
normal-sd-project-leader
10.0
1
0
Number

PLOT
387
446
587
596
Avg attitude
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [attitude] of citizens"

SLIDER
5
441
193
474
Difference-in-vba-value1
Difference-in-vba-value1
0
60
60.0
10
1
NIL
HORIZONTAL

SLIDER
5
476
193
509
Difference-in-vba-value2
Difference-in-vba-value2
0
60
60.0
10
1
NIL
HORIZONTAL

SLIDER
4
511
192
544
Difference-in-vba-value3
Difference-in-vba-value3
0
60
60.0
10
1
NIL
HORIZONTAL

SLIDER
4
545
192
578
Difference-in-vba-value4
Difference-in-vba-value4
0
60
0.0
10
1
NIL
HORIZONTAL

SLIDER
4
581
192
614
Difference-in-vba-value5
Difference-in-vba-value5
0
60
0.0
10
1
NIL
HORIZONTAL

SLIDER
819
190
1075
223
Added-rejected-vba-diff-per-attitude
Added-rejected-vba-diff-per-attitude
0
0.9
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
819
150
1080
183
Added-accepted-vba-diff-per-attitude
Added-accepted-vba-diff-per-attitude
0
0.9
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
820
57
1027
90
Accept-vba-difference-attitude0
Accept-vba-difference-attitude0
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
821
92
1031
125
Reject-vba-difference-attitude0
Reject-vba-difference-attitude0
10
30
20.0
1
1
NIL
HORIZONTAL

TEXTBOX
821
25
1263
67
A (see excel for visualisation) \nsignifies the height of threshold for accepting or rejecting a transmission at an attitude of 0
11
0.0
1

TEXTBOX
822
125
1373
152
B (see excel)\nsignifies the increase of the thresholds  for an attitude increase of 1
11
0.0
1

PLOT
592
445
792
595
%-of-dissatisfied-citizens
NIL
%
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot 100 * number-of-dissatisfied-citizens / number-of-citizens"

PLOT
797
445
997
595
Attitude
Attitude
#citizens
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range -0.001 101\nset-plot-y-range -0.001 count citizens\nset-histogram-num-bars 5" ""
PENS
"default" 20.0 1 -16777216 true "" "histogram [attitude] of citizens"

SLIDER
814
409
1139
442
Relative-power-counter-vba
Relative-power-counter-vba
0
200
20.0
10
1
% of power projectleaders
HORIZONTAL

TEXTBOX
5
377
373
433
These differences represent the 'Avg VBA-value of projectleaders' minus 'avg VBA-value of citizens' (so the average of both is assumed to be 50, so a difference of 20 means the VBA-value's are resp. 60 and 40 on average at the setup)
11
0.0
1

TEXTBOX
817
225
1218
267
The thresholds caused by the values of A en B (above) lead to a positive, neutral or negative reaction. These sliders determine how the attitude of citizens changes for each reaction.
11
0.0
1

TEXTBOX
818
316
1001
371
Based on this threshold of attitude the amount of 'angry' citizens is determined. The average VBA of these citizens is used as counter-VBA
11
0.0
1

TEXTBOX
15
97
190
137
SETUP PARAMETERS
16
0.0
1

TEXTBOX
823
7
973
27
GO PARAMETERS
16
0.0
1

@#$#@#$#@
## WHAT IS IT?

This explorative model shows how social conflicts emerge and evolve, based on the carbon capture and storage-project in Barendrecht, where increasing local opposition led to an intensified debate and ultimately resulted in cancelling the project because of a lack of support.

Following the conceptual model of Pesch et al (2017), that stresses the importance of values in the trajectory of such a project, this model looks at the impact of an emphasis on certain values by the projectleaders, and neglecting others, which possibly results in polarization. 

Central in this model is the notion of a 'value-based assessment' (VBA). Both agent-types (projectleaders and citizens) have a VBA. When there are substantial differences between the joint VBA of the projectleaders and the VBA of a citizen, this might lead to a reaction: their attitude to the project will be more negative. Because citizens mutually affect their VBAs, polarization is likely to occur when there are repeated differences between VBAs of projectleaders and citizens.

## HOW IT WORKS

Each type of agents (citizens and projectleaders) forms its own seperate network. In the case of the citizens this is a network based on preferential attachment, meaning that citizens with a lot of friends (network links) have a higher chance of forming new links. In the case of the project leaders the network is fully conected, meaning that each project leader is linked to all other project leaders.

After VBAs are assigned to both citizens and projectleaders, citizens also have an initial attitude to the project, and the networks has been set up, the model can run. This starts each round of interactions (tick) with determining and transmissing a joint VBA by the projectleaders. 

Based on their initial attitude and the difference between this transmitted VBA and their own VBA, the attitude of citizens changes: a large VBA-difference leads to a more negative attitute, while a small difference leads to a more positive attitude. It is also possible to react neutrally.

After that, citizens mutually affect each others VBA, based on the position in the network. A citizen with many connections will have a greater impact on other citizens' VBAs: beside being connected to more citizens and thus influencing more others, they also have more power determining the VBAs of these others. 

Lastly, if the attitude of citizens gets under a certain threshold, citizens will take actions and express their dissatisfaction, translated into a counter-VBA. When the projectleaders determine the new joint VBA, this counter-VBA is taken into account. This should make the new transmitted VBA more receptive to citizens.

## HOW TO USE IT

Next to parameters used in the setup- and go-phase, there are a few general parameters in the interface. See the inferface for more guiding remarks.

* _Setup_ - sets up the model, meaning that it creates the networks of citizens and project leaders, assigns their initial values and assigns initial global values 
* _Go once_ - runs the model for a single tick
* _Go_ - runs the model until the button is activated again 
* _Citizen-influence-others-attitude?_ - if switched on citizens will also influence each others attitude in addition to each others VBA
* _Reporter?_ - If switched on the model will note down model values in the command center for verification

The block in the middle shows the networks of both citizens (red triangles) and projectleaders (blue triangles). The plots below it show the average attitude of citizens, the percentage of dissatisfied citizens and a histogram showing the distribution of attitude among citizens.

### SETUP

* _Number-of-projectleaders_ - determines the number of project-leader agents in the model
* _Number-of-citizens_ - determines the number of citizen agents in the model 
* _Normal-distribution-citizens?_ - if turned on the setting of the vba’s of citizens will be done according to a normal distribution. If switched-off this will be done according to a uniform distribution
* _Normal-distribution-projectleaders?_ - if turned on the setting of the vba’s of project leaders will be done according to a normal distribution. If switched-off this will be done according to a uniform distribution
* _Normal-sd-citizen_ - Defines the standard deviation used for setting the vba’s of citizens. This is only applicable if the Normal-distribution-citizens? switch is turned on.
* _Normal-sd-project-leader_ -  Defines the standard deviation used for setting the vba’s of project leaders. This is only applicable if the Normal-distribution-projectleaders switch is turned on.
* _Number-of-values_ - Defines how many values form a vba. This applies to all vba’s
* _Difference-in-vba-value'X'_ - With X varying from 1 to 5 - Defines differences between the vba elements of project leaders and citizens. Heightening this value with one increases the average value of the element with 0.5 for the project leaders, lowering the citizen value with 0.5 per point increase.

### GO

NB: Some references are made to figure 10: this can be found in the report.

* _Accept-vba-difference-attitude0_ - Determines the ‘starting point’ of the function at an attitude of 0. Making this slider larger will increase the numerical differences between the VBAs that will lead to a positive reaction (see the blue circle in figure 10). Setting this parameter to 10, means that a VBA-difference (between the citizen and the transmitted VBA) of 10 and smaller leads to a positive reaction. A bigger difference leads to a neutral or negative reaction, dependent on the parameter determining the rejection threshold (Reject-vba-difference-attitude0).
* _Added-accepted-vba-diff-per-attitude_ - Determines the amount by which attitude is multiplied to get to the threshold for acceptance of a transmission. This can be seen as the slope of the function, thus influencing the angle of the function (blue line). If a citizen’s VBA difference with a transmitted frame is under the blue line taking into account its attitude value the citizen will accept a transmission.  
* _Reject-vba-difference-attitude0_ - Determines the addition of the function at an attitude of 0. Making this slider larger will decrease the numerical differences between the VBAs that will lead to a negative reaction (see the red circle). Setting this parameter to 20, means that a VBA-difference of higher than 20 leads to a negative reaction.
* _Added-rejected-vba-diff-per-attitude_ - Determines the amount by which attitude is multiplied to get to the threshold for rejection of a transmission. This influences the angle of the function (red line). If a citizen’s VBA difference with a transmitted frame is above the red line taking into account its attitude value the citizen will reject a transmission.  
* _Attitude-shift-positive_ - determines the value by which a citizens attitude increases when reacting positively 
* _Attitude-shift-negative_ - determines the value by which a citizens attitude decreases when reacting negatively
* _Threshold-counter-vba_ - Determines under which attitude value citizens will start transmitting counter-VBAs to influence the next transmitted VBA
* _Relative-power-counter-vba_ - Increase or decreases the highest amount of influence a counter frame can exert, compared to all project leaders. A value of 100 states that the counter-VBA is equally important as the VBA’s of all the projectleaders in determining the new transmitted VBA.

## EXTENDING THE MODEL
There are some general restrictions to the developed model, especially with respect to the manner citizens are influenced.
 
* First of all, it is assumed all citizens are evenly involved in the project and thus evenly affected each time a joint VBA is transmitted, while this might differ per citizen and per moment (e.g. citizens might not even know that there was a transmitted VBA in the first place). 

* Secondly, citizen VBAs are only affected by each other, while external influences and influence by project leaders can be relevant too. Now, these interactions are governed by the network structure and the power each citizen has is based on their position, which could lead to an overestimation of the effect citizens have on each other. 

## CREDITS AND REFERENCES

Pesch, U., Correljé, A., Cuppen, E., Taebi, B., & van de Grift, E. (2017). Formal and Informal Assessment of Energy Technologies. In Responsible Innovation 3 (pp. 131-148). Springer, Cham.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment 3 values" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="0"/>
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="0"/>
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment with min and max power counter frames" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="0"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="0"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment small" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment smaller" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="VBA differences" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="0"/>
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="0"/>
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="0"/>
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Counterframe experiments" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="0"/>
      <value value="50"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="0"/>
      <value value="20"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Attitude influence experiment" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="30"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="VBA acceptance_rejection" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count citizens with [attitude &lt; 20]</metric>
    <metric>count citizens with [attitude &gt;= 20 and attitude &lt; 40]</metric>
    <metric>count citizens with [attitude &gt;= 40 and attitude &lt; 60]</metric>
    <metric>count citizens with [attitude &gt;= 60 and attitude &lt; 80]</metric>
    <metric>count citizens with [attitude &gt;= 80]</metric>
    <metric>median [attitude] of citizens</metric>
    <metric>max [attitude] of citizens</metric>
    <metric>min [attitude] of citizens</metric>
    <metric>mean [attitude] of citizens</metric>
    <metric>average-euclidean-distance-citizens-mean</metric>
    <metric>average-euclidean-distance-average-citizens-vs-project-leaders</metric>
    <metric>100 * (number-of-dissatisfied-citizens / number-of-citizens)</metric>
    <metric>count citizens with [citizen-vba-component-1 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 20 and citizen-vba-component-1 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 40 and citizen-vba-component-1 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 60 and citizen-vba-component-1 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-1 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-1] of citizens</metric>
    <metric>average-citizen-vba-component-1</metric>
    <metric>count citizens with [citizen-vba-component-2 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 20 and citizen-vba-component-2 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 40 and citizen-vba-component-2 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 60 and citizen-vba-component-2 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-2 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-2</metric>
    <metric>count citizens with [citizen-vba-component-3 &lt; 20]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 20 and citizen-vba-component-3 &lt; 40]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 40 and citizen-vba-component-3 &lt; 60]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 60 and citizen-vba-component-3 &lt; 80]</metric>
    <metric>count citizens with [citizen-vba-component-3 &gt;= 80]</metric>
    <metric>median [citizen-vba-component-2] of citizens</metric>
    <metric>average-citizen-vba-component-3</metric>
    <metric>average-project-leader-vba-component-1</metric>
    <metric>average-project-leader-vba-component-2</metric>
    <metric>average-project-leader-vba-component-3</metric>
    <enumeratedValueSet variable="Number-of-projectleaders">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Citizen-influence-others-attitude?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-projectleaders?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Normal-distribution-citizens?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-project-leader">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-sd-citizen">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-values">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value1">
      <value value="0"/>
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value2">
      <value value="0"/>
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value3">
      <value value="0"/>
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Difference-in-vba-value5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accept-vba-difference-attitude0">
      <value value="20"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-accepted-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reject-vba-difference-attitude0">
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Added-rejected-vba-diff-per-attitude">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-negative">
      <value value="-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Attitude-shift-positive">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Relative-power-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-counter-vba">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reporter?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
