
ind = open("test.bin", "rb")
d = ind.read()
print ([d])

fh = open("high.bin", "wb")
fl = open("low.bin", "wb")

for i in range(0, len(d), 2):
#    print(i)
    l = d[i]
    h = d[i+1]
#    print([h, l])
    fh.write(h.to_bytes(1, "little"))
    fl.write(l.to_bytes(1, "little"))

fl.close()
fh.close()
ind.close()
