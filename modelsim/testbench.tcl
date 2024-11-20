# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../PianissimoFinalProjectModelsim.v
vlog ../*.v +incdir+"DefineMacros.vh" +define+SIMULATION
vlog ../PS2_controller/*.v +incdir+"../DefineMacros.vh"
vlog ../FSMs/*.v +incdir+"DefineMacros.vh"

# compile the Verilog code of the testbench
vlog *.v

# start the Simulator, including some libraries that may be needed
vsim work.testbench -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 600 us
