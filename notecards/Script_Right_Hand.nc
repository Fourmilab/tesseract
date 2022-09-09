
#   Define the right hand model

@Set model custom begin
#   Palm
@Set model custom vertices <0.25, 0.5, 0, 0> <-0.25, 0.5, 0, 0> <-0.4, -0.5, 0, 0> <0.4, -0.5, 0, 0>
#   Index finger
@Set model custom vertices <0.375, -1.4, 0, 0>  <0.375, -0.5, 0, 0>
#   Middle finger
@Set model custom vertices <0.125, -0.5, 0, 0> <0.125, -1.05, 0, 0>
#   RIng finger
@Set model custom vertices <-0.125, -0.5, 0, 0> <-0.125, -0.975, 0, 0>
#   Little finger
@Set model custom vertices <-0.375, -0.5, 0, 0> <-0.375, -0.875, 0, 0>
#   Thumb
@Set model custom vertices <0.28, 0.35, 0, 0> <0.7, -0.5, 0.25, 0>

#   Middle finger foldback
@set model custom vertices <0.125, -1.05, 0.15, 0> <0.125, -0.5, 0.15, 0>
@set model custom vertices <0.125, -1.02, 0, 0> <0.125, -1.02, 0.15, 0>
#   Ring finger foldback
@set model custom vertices <-0.125, -0.975, 0.15, 0> <-0.125, -0.5, 0.15, 0>
@set model custom vertices <-0.125, -0.945, 0, 0> <-0.125, -0.945, 0.15, 0>
#   Little finger foldback
@set model custom vertices <-0.375, -0.875, 0.15, 0> <-0.375, -0.5, 0.15, 0>
@set model custom vertices <-0.375, -0.845, 0, 0> <-0.375, -0.845, 0.15, 0>

#   Palm
@Set model custom edges 0 1  1 2  2 3  3 0
#   Index finger
@Set model custom edges 4 5
#   Middle finger
#@Set model custom edges 6 7
@Set model custom edges 6 7   14 15   16 17
#   Ring finger
#@Set model custom edges 8 9
@Set model custom edges 8 9   18 19   20 21
#   Little finger
@Set model custom edges 10 11   22 23   24 25
#   Thumb
@Set model custom edges 12 13
@Set model custom colours 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1
@Set model custom end
