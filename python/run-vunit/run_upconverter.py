from vunit.verilog import VUnit
from tb_path import TB_PATH

vu = VUnit.from_argv()
vu.add_verilog_builtins()

dsm = vu.add_library("dsm")
dsm.add_source_files(TB_PATH / "tb_upconverter.sv")

tb = dsm.test_bench("tb_upconverter")

vu.main()

