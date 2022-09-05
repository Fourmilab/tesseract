
#   Declare the 24-cell octaplex as a custom model

Set model custom begin

Set model custom vertices <1.0, 0.0, 0.0, 0.0> <-1.0, 0.0, 0.0, 0.0>
Set model custom vertices <0.0, 1.0, 0.0, 0.0> <0.0, -1.0, 0.0, 0.0>
Set model custom vertices <0.0, 0.0, 1.0, 0.0> <0.0, 0.0, -1.0, 0.0>
Set model custom vertices <0.0, 0.0, 0.0, 1.0> <0.0, 0.0, 0.0, -1.0>
Set model custom vertices <0.5, 0.5, 0.5, 0.5> <-0.5, 0.5, 0.5, 0.5>
Set model custom vertices <0.5, -0.5, 0.5, 0.5> <-0.5, -0.5, 0.5, 0.5>
Set model custom vertices <0.5, 0.5, -0.5, 0.5> <-0.5, 0.5, -0.5, 0.5>
Set model custom vertices <0.5, -0.5, -0.5, 0.5> <-0.5, -0.5, -0.5, 0.5>
Set model custom vertices <0.5, 0.5, 0.5, -0.5> <-0.5, 0.5, 0.5, -0.5>
Set model custom vertices <0.5, -0.5, 0.5, -0.5> <-0.5, -0.5, 0.5, -0.5>
Set model custom vertices <0.5, 0.5, -0.5, -0.5> <-0.5, 0.5, -0.5, -0.5>
Set model custom vertices <0.5, -0.5, -0.5, -0.5> <-0.5, -0.5, -0.5, -0.5>

Set model custom edges  0 8  0 10  0 12  0 14  0 16  0 18  0 20  0 22  1 9  1 11
Set model custom edges  1 13  1 15  1 17  1 19  1 21  1 23  2 8  2 9  2 12  2 13
Set model custom edges  2 16  2 17  2 20  2 21  3 10  3 11  3 14  3 15  3 18
Set model custom edges  3 19  3 22  3 23  4 8  4 9  4 10  4 11  4 16  4 17  4 18
Set model custom edges  4 19  5 12  5 13  5 14  5 15  5 20  5 21  5 22  5 23  8 9
Set model custom edges  8 10  9 11  10 11  12 13  12 14  13 15  14 15  8 12  9 13
Set model custom edges  10 14  11 15  16 17  16 18  17 19  18 19  20 21  20 22
Set model custom edges  21 23  22 23  16 20  17 21  18 22  19 23  6 8  6 9  6 10
Set model custom edges  6 11  6 12  6 13  6 14  6 15  7 16  7 17  7 18  7 19
Set model custom edges  7 20  7 21  7 22  7 23  8 16  9 17  10 18  11 19  12 20
Set model custom edges  13 21  14 22  15 23

Set model custom end
