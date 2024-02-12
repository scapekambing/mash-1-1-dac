from pathlib import Path
from vunit.verilog import VUnit
import numpy as np

TB_PATH = Path(__file__).parent / "../tb"

vu = VUnit.from_argv()
vu.add_verilog_builtins()

dsm = vu.add_library("dsm")
dsm.add_source_files(TB_PATH / "*mash11.sv")

tb = dsm.test_bench("tb_mash11")

vu.main()