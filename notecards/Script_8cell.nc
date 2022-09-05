
#   Declare the 8-cell tesseract as a custom model

Set model custom begin

Set model custom vertices <-1, -1, -1, -1> <-1, -1, -1, 1>
Set model custom vertices <-1, -1, 1, -1> <-1, -1, 1, 1>
Set model custom vertices <-1, 1, -1, -1> <-1, 1, -1, 1>
Set model custom vertices <-1, 1, 1, -1> <-1, 1, 1, 1>
Set model custom vertices <1, -1, -1, -1> <1, -1, -1, 1>
Set model custom vertices <1, -1, 1, -1> <1, -1, 1, 1>
Set model custom vertices <1, 1, -1, -1> <1, 1, -1, 1>
Set model custom vertices <1, 1, 1, -1> <1, 1, 1, 1>

Set model custom edges 0 1  1 3  3 2  2 6  6 14  14 10  10 8  8 9
Set model custom edges 9 11  11 3  3 7  7 15  15 14  14 12  12 13  13 9
Set model custom edges 9 1  1 5  5 7  7 6  6 4  4 12  12 8  8 0
Set model custom edges 0 4  4 5  5 13  13 15  15 11  11 10  10 2  2 0

Set model custom colours 3 2 3 1 0 1 2 3 2 0 1 0 3 2 3 1
Set model custom colours 0 1 2 3 2 0 1 0 1 3 0 2 1 3 0 2

Set model custom end
