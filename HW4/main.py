from PIL import Image

img = Image.open('image.jpg')
img = img.resize((31, 32))
img = img.convert('L')

file = open('img.dat', 'w')

gray = []
for i in range(0, 31, 2):
    row = []
    for j in range(32):
        row.append(img.getpixel((i, j)))
        s = '%0.2X' % img.getpixel((i, j))
        #print(s)
        file.write(s + '\n')
    gray.append(row)

golden = []
for i in range(31):
    row = []
    for j in range(32):
        if (i % 2) == 0:
            row.append(gray[int(i/2)][j])
        else:
            if j == 0 or j == 31:
                row.append(int((gray[int(i/2)][j] + gray[int(i/2)+1][j]) / 2))
            else:
                d1 = abs(gray[int(i/2)][j-1] - gray[int(i/2)+1][j+1])
                d2 = abs(gray[int(i/2)][j] - gray[int(i/2)+1][j])
                d3 = abs(gray[int(i/2)][j+1] - gray[int(i/2)+1][j-1])
                if d3 < d1 and d3 < d2:
                    row.append(int((gray[int(i/2)][j+1] + gray[int(i/2)+1][j-1]) / 2))
                elif d1 < d2:
                    row.append(int((gray[int(i/2)][j-1] + gray[int(i/2)+1][j+1]) / 2))
                else:
                    row.append(int((gray[int(i/2)][j] + gray[int(i/2)+1][j]) / 2))
    golden.append(row)

file = open('golden.dat', 'w')
for i in range(31):
    for j in range(32):
        s = '%0.2X' % golden[i][j]
        file.write(s + '\n')
        
