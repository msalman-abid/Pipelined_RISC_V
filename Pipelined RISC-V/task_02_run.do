vlog *.v
vsim -novopt work.tb_RISC_V_2
view wave

add wave sim:/tb_RISC_V_2/risc_v/Data_Memory/memory
add wave sim:/tb_RISC_V_2/risc_v/reg_file/Registers
add wave sim:/tb_RISC_V_2/*
add wave sim:/tb_RISC_V_2/risc_v/*
run 100ns