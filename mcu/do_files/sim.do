vsim -voptargs=+acc work.cpu_test
view structure wave signals

do wave.do

log -r *
run -all

