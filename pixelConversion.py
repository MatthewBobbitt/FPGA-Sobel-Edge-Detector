
from PIL import Image
width = 3456
height = 4608
#Open image
img = Image.open("").convert("RGB") # - convert(RGB) will make sure each pixel will return a value for all R,G,B


#Resize to 16x16
img = img.resize((width,height)) # - Resample makes sure Pillow doesn't blend neighboring pixels

with open("pixels.txt", "w") as file:    # - "w" sets to write mode;     "file" is a variable that represents the .txt file
    for y in range(height):
        for x in range(width): # - these two loops rotate through x and y values
            r, g, b = img.getpixel((x,y)) # grabs RGB values for each pixel
            file.write(f"{r} {g} {b}\n") # in the file, this writes out: R(value), G(value), B(value), new line