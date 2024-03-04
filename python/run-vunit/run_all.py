import os

threads = 6

if __name__ == "__main__":
  for file in os.listdir():
    if file.endswith(".py"):
      if file != "run_all.py":
        inp = input(f"Press Enter to run {file}...")
        if inp == "":
          os.system(f"python {file} -p {threads}")