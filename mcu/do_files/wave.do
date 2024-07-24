onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL INPUTS}

add wave -noupdate -format Logic  /cpu_test/clk
add wave -noupdate -format Logic  /cpu_test/reset
add wave -noupdate -format Logic  /cpu_test/cl/w_q




#add wave -noupdate -format Literal -radix unsigned  /test_FileName/test_Signal
# -radix後接型態 十進位 decimal, 1bit logic, 十六進位 hex, 二進位 binary, 正整數 unsigned

