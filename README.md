# FPGA-Sobel-Edge-Detector
A hardware-oriented Sobel edge detection system implemented on a Digilent Basys 3 FPGA. The project was developed to translate an image-processing algorithm from a software implementation into synthesizable digital hardware.

The completed system transfers an RGB image from a host computer to the FPGA over UART, processes the image through a hardware image-processing pipeline, and transmits the resulting Sobel edge pixels back to the computer to reconstruct the output image.

The FPGA implementation includes RGB-to-grayscale conversion, line buffering, 3×3 pixel window generation, Sobel gradient calculation, FIFO buffering, and UART communication.

# Project Status
The FPGA implementation is functional and has been deployed to a Digilent Basys 3 development board.

The complete image-processing pipeline has been successfully tested with images up to 1920×2260 pixels. A 1920×2260 input produces 4,330,844 valid Sobel output pixels, all of which have been successfully processed by the FPGA and returned to the host computer.

UART communication currently operates at 2 Mbaud.

# Getting Started
The project requires both a host computer and a Digilent Basys 3 FPGA.

Python is used to:

- Load an input image.
- Resize the image to the desired dimensions.
- Convert the image into RGB pixel data.
- Send the image dimensions and RGB data to the FPGA over UART.
- Receive processed Sobel pixels from the FPGA.
- Reconstruct the edge-detected output image.

The FPGA performs the actual grayscale conversion, 3×3 window generation, and Sobel edge detection.

# Prerequisites
Software:

- Python
- Pillow (PIL)
- PySerial
- AMD Vivado

Hardware:

- Digilent Basys 3
- Xilinx Artix-7 FPGA
- USB connection for programming and UART communication

Install the required Python packages using:

pip install Pillow pyserial

# Installing
download the repository.

Open the Vivado project and generate the FPGA bitstream.

Program the Basys 3 with the generated bitstream.

Place the desired source image in the appropriate project directory and update the image filename/path in the Python script.

Set the desired image width and height in the Python program.

Run the Python program:

py transmit.py

The Python program sends the image dimensions followed by the RGB pixel data to the FPGA.

After processing, the FPGA transmits the Sobel edge pixels back to the computer and Python reconstructs the final edge-detected image.

# How It Works

The Sobel operator detects edges by measuring changes in brightness intensity between neighboring pixels.

Two 3×3 kernels are used to detect horizontal and vertical intensity changes.

Gx = [-1 0 1
      -2 0 2
      -1 0 1]

Gy = [-1 -2 -1 
       0  0  0 
       1  2  1]

For each valid pixel location, the surrounding 3×3 pixel window is multiplied by the two kernels to calculate horizontal and vertical gradients.

The resulting gradient values are then combined to determine the magnitude of the edge at that pixel.

# Current Project Flow

The current implementation follows this processing flow:

Input Image
    >>
    
Python Image Resizing
    >>
    
RGB Pixel Data
    >>
    
UART Transmission to FPGA
    >>
    
RGB Pixel Collection
    >>
    
Grayscale Conversion
    >>
    
Line Buffers
    >>
    
3×3 Pixel Window
    >>
    
Sobel Gx / Gy Calculation
    >>
    
Edge Output
    >>
    
FIFO Buffer
    >>
    
UART Transmission to Computer
    >>
    
Python Output Image Reconstruction

# FPGA Architecture

The primary FPGA processing architecture is:

UART RX
    >>
    
RGB Collection
    >>
    
Grayscale Converter
    >>
    
Line Buffers
    >>
    
3×3 Window Generator
    >>
    
Sobel Datapath
    >>
    
FIFO
    >>
    
UART TX

The design processes the image as a stream rather than storing the entire image on the FPGA.

Two line buffers are used to retain previous rows of grayscale pixel data so that the 3×3 window required by the Sobel operator can be generated.

The maximum supported image width is determined by the configured line-buffer capacity. Image width and height are sent dynamically from Python before the RGB image data.

# UART Communication

The host computer and FPGA communicate using UART.

Before sending the image, Python transmits a four-byte image header:

- Width high byte
- Width low byte
- Height high byte
- Height low byte

RGB pixels are then transmitted in the following format:

R, G, B, R, G, B, ...

The FPGA reconstructs each RGB pixel and sends it through the image-processing pipeline.

Processed edge pixels are buffered in a FIFO before being transmitted back to the computer.

The current UART communication rate is:

2,000,000 baud

With the Basys 3 100 MHz clock, 2 Mbaud provides exactly 50 FPGA clock cycles per UART bit.

# FIFO Buffering

A FIFO (First-In, First-Out) buffer is used between the Sobel processor and UART transmitter.

The Sobel processor and UART transmitter operate independently, so the UART may still be transmitting a previous byte when another Sobel result becomes available.

The FIFO temporarily stores these edge pixels until the UART transmitter is ready.

Read and write control logic prevents data from being removed from the FIFO before the UART is ready to accept another byte.

# UART Synchronization

The UART RX input originates outside of the FPGA clock domain and is therefore asynchronous to the FPGA's 100 MHz clock.

A two-flip-flop synchronizer is used before the UART receiver state machine.

The first flip-flop captures the incoming UART signal and allows potential metastability to settle. The second flip-flop captures the stabilized value, which is then used by the UART receiver.

This synchronization was important for reliable transfers of large images.

# Verification and Debugging

The design was tested incrementally in both simulation and hardware.

Individual modules were first developed and tested before integrating the complete image-processing pipeline.

Hardware debugging counters were also added to monitor:

- Number of valid Sobel edge outputs generated.
- Number of Sobel outputs dropped before entering the FIFO.

The lower 16 bits of these counters can be displayed using the Basys 3 LEDs and selected using SW0.

This allowed data-loss problems to be isolated to specific portions of the processing pipeline.

One issue was found in the FIFO-to-UART handshake. The FIFO could advance its read pointer before the UART transmitter had fully acknowledged the previous transmission request. The handshake logic was modified to prevent another FIFO read while a byte was already waiting for the UART.

A second issue appeared during large image transfers because the external UART RX signal was asynchronous to the FPGA clock. A two-flip-flop synchronizer was added to provide a stable UART input to the receiver state machine.

After these changes, large image transfers completed without missing pixels.

# Testing

The FPGA implementation has been tested using multiple image sizes.

For an image with width W and height H, the number of valid Sobel outputs is:

(W - 2) × (H - 2)

The two-pixel reduction occurs because a complete 3×3 neighborhood is not available around the outer image boundary.

Example:

Input:

1024 × 768

Expected output pixels:

(1024 - 2) × (768 - 2) = 782,852

The FPGA successfully generated and returned all 782,852 expected edge pixels.

A larger test used:

1920 × 2260

Expected output pixels:

(1920 - 2) × (2260 - 2) = 4,330,844

The FPGA successfully generated and returned all 4,330,844 expected edge pixels.

The system has also been successfully tested at a UART communication rate of 2 Mbaud.

# Deployment

The design has been synthesized, implemented, and deployed on a Digilent Basys 3 development board containing a Xilinx Artix-7 FPGA.

AMD Vivado is used for synthesis, implementation, bitstream generation, and FPGA programming.

# Project Goals

The primary goal of this project is to gain experience translating an algorithm from a software implementation into dedicated digital hardware.

The project provides experience with:

- Verilog RTL design
- FPGA implementation
- Streaming image processing
- UART communication
- Finite state machines
- FIFO buffering
- Clock-domain synchronization
- Hardware/software communication
- RTL simulation
- FPGA debugging
- Timing and synthesis
- Image-processing datapaths

# Future Improvements

Potential future improvements include:

- Further pipelining of the image-processing datapath
- Increased communication bandwidth
- BRAM optimization
- Real-time video processing
- VGA or HDMI output
- Camera input
- SystemVerilog conversion and additional verification

  
# Author 
Stephen Bobbitt 

Electrical Engineering
University of Arkansas
Expected Graduation: December 2028
