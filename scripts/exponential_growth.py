import sys, math

for i in range(0,101):
    val1 = math.pow(2,i)
    val2 = round(math.pow(2,i)**(1.0/2.0))
    val3 = round(math.pow(2,i)**(1.0/3.0))
    # val3 = math.floor(math.pow(math.sqrt(2),i))
    print i, val1, val2, val3
