if exist ..\images\*.mif (
    copy /Y ..\images\*.mif
)
if exist ..\object_mem_bb.v (
    del ..\object_mem_bb.v
)
if exist work rmdir /S /Q work

vlib work

::set comp_files "../*.v ../PS2_controller/*.v ../FSMs/*.v" +incdir+ "../DefineMacros.vh"
vlog ../tb/*.v
vlog ../*.v +incdir+"DefineMacros.vh"
vlog ../PS2_controller/*.v +incdir+"../DefineMacros.vh"
vlog ../FSMs/*.v +incdir+"DefineMacros.vh"
