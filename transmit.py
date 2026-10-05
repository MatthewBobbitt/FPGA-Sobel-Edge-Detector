from PIL import Image
import serial
import time

PORT = "COM4"                                      #USE YOUR COM PORT FOR FPGA
BAUD = 2000000                                     #2 Mbaud rate

WIDTH = 1920
HEIGHT = 1080                                      # Fix resolution to your liking

INPUT_IMAGE = "PUT YOUR JPG OR PNG HERE.png"
OUTPUT_IMAGE = "edge_output.png"


img = Image.open(INPUT_IMAGE).convert("RGB")

img = img.resize((WIDTH, HEIGHT))

print("Image resized to:", img.size)

pixels = list(img.get_flattened_data())


output_width = WIDTH - 2
output_height = HEIGHT - 2

expected_edges = output_width * output_height

print("Expected edge pixels:", expected_edges) #Theoretical amount of edges

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Image Settings and Opening



ser = serial.Serial(
    port=PORT,
    baudrate=BAUD,
    bytesize=8,
    parity="N",
    stopbits=1,
    timeout=5
)

time.sleep(1)

ser.reset_input_buffer()
ser.reset_output_buffer()



print("Sending image dimensions...")

ser.write(WIDTH.to_bytes(2, byteorder="big"))
ser.write(HEIGHT.to_bytes(2, byteorder="big"))


#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Serial Setup

print("Sending image to FPGA...") 

edge_pixels = []

for R, G, B in pixels:

    # Send RGB pixel
    ser.write(bytes([R, G, B]))

    # Check whether FPGA has sent anything back
    waiting = ser.in_waiting

    if waiting > 0:

        data = ser.read(waiting)

        edge_pixels.extend(data)


print("Image sent.")

print(
    "Edges received while sending:",
    len(edge_pixels)
)


print(
    "Waiting for",
    expected_edges,
    "total edge pixels..."
)


while len(edge_pixels) < expected_edges:

    remaining = expected_edges - len(edge_pixels)

    data = ser.read(remaining)

    if data:

        edge_pixels.extend(data)

    else:

        print("UART timeout.")
        break


ser.close()


# RESULTS

print("Received:", len(edge_pixels))
print("Expected:", expected_edges)


if len(edge_pixels) == expected_edges:

    edge_img = Image.new(
        "L",
        (output_width, output_height)
    )

    edge_img.putdata(edge_pixels)

    edge_img.save(OUTPUT_IMAGE)

    print("Saved:", OUTPUT_IMAGE)

else:

    print("Did not receive enough pixels.")
