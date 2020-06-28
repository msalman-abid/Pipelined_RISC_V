vlog *.v
vsim -novopt work.tb_RISC_V_1
view wave

add wave sim:/tb_RISC_V_1/risc_v/Data_Memory/memory
add wave sim:/tb_RISC_V_1/risc_v/reg_file/Registers
add wave sim:/tb_RISC_V_1/*
add wave sim:/tb_RISC_V_1/risc_v/*
run 1200ns