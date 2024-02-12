import math

TABLE_SIZE = 2**8
SCALE = 32767*0.75
LINE_VALUES = 1

data = [0] * TABLE_SIZE

for i in range(TABLE_SIZE):
    angle = (i * 2 + 1.0) / (TABLE_SIZE * 2)
    s = math.sin(angle * math.pi * 2.0)
    data[i] = round(SCALE * (s+1))

for i in range(TABLE_SIZE):
    if i % LINE_VALUES == 0:
        print("       ", end="")

    print(f"sin_lut[{i}]   =   {data[i]:6};", end="")

    if i == TABLE_SIZE - 1:
        print()
    elif i % LINE_VALUES == LINE_VALUES - 1:
        print()
    else:
        print(" ", end="")