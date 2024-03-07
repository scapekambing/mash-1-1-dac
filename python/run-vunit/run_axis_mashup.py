from pathlib import Path
from vunit.verilog import VUnit
import numpy as np
from tb_path import TB_PATH

vu = VUnit.from_argv()
vu.add_verilog_builtins()

dsm = vu.add_library("dsm")
dsm.add_source_files(TB_PATH / "*mashup.sv")

tb = dsm.test_bench("tb_mashup")

vu.main()