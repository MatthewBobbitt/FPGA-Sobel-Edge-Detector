from PIL import Image

width = 3454 #make sure to subtract 2 from both the width and height values only in sobelConversion file
height = 4606

img = Image.new("L", (width, height))

with open("edge_pixels.txt", "r") as file:

    for y in range(height):
        for x in range(width):

            edge = int(file.readline())

            img.putpixel((x, y), edge)

img.save("sobel_image.png")
