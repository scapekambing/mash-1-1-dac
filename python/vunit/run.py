import argparse
from vunit.verilog import VUnit
import os

parser = argparse.ArgumentParser(description='generate VUnit run file for a SV module')
parser.add_argument('module', metavar='module', type=str, help='module name for unit testing')
args, vunit_args = parser.parse_known_args()
module = args.module

vu = VUnit.from_argv(vunit_args)
vu.add_verilog_builtins()

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
TB_PATH = os.path.join(CURRENT_DIR, "../../hdl/tb")
RTL_PATH = os.path.join(CURRENT_DIR, "../../hdl/rtl")

dsm = vu.add_library("dsm")
dsm.add_source_files(os.path.join(RTL_PATH, "*.sv"))
dsm.add_source_files(os.path.join(TB_PATH, "tb_" + module + ".sv"))

vu.main()
