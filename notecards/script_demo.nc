set scale 2
set diam 0.02
set tick 0.1
@echo Touch to continue
script pause touch
ro zw 2 an
ro xy 2 ani
ro yw 2 ani
run 15
spin 0.5
run 15
ro reset
script pause 10
spin 0
