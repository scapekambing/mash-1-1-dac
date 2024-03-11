import os

def generate_filelist(directory, extension, output_file):
    with open(output_file, 'w') as filelist:
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith(extension):
                    file_path = os.path.join(r"rtl", file)
                    filelist.write(file_path + '\n')

file_extension = ".sv"    
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RTL_DIR = os.path.join(SCRIPT_DIR, r"..\..\hdl\rtl")
HDL_DIR = os.path.join(SCRIPT_DIR, r"..\..\hdl")
output_file_path = os.path.join(HDL_DIR, "hdl.fl")

generate_filelist(RTL_DIR, file_extension, output_file_path)
print("hdl.fl generated to:", os.path.dirname(os.path.abspath(output_file_path)))
