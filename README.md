# FPGA-Sobel-Edge-Detector
A hardware-oriented Sobel edge detection project designed to convert an image-processing algorithm from a software implementation into an FPGA-based hardware accelerator. The current implementation performs image preprocessing and Sobel edge detection in software, with the next stage of development focused on implementing and verifying the algorithm in Verilog before deployment to an FPGA.

// Project Status: Software implementation is complete. FPGA implementation has not yet been completed.

# Getting Started
The current version of the project can be used to process an input image and generate an edge-detected output image using the Sobel operator. The software implementation will also serve as a reference for verifying the future RTL implementation.

# Prerequisites
The software portion requires:
 - Python
 - Pillow (PIL)

Install Pillow using:

pip install Pillow

Future FPGA development will use:
 - Verilog
 - ModelSim for RTL simulation
 - AMD Vivado for FPGA synthesis and implementation
 - Digilent Basys 3 (Artix-7) FPGA development board

The FPGA tools and hardware are not required to run the current software implementation.

# Installing
Download the repository

Install the required Python dependency:
 - pip install Pillow

Place the desired source image in the appropriate project directory and update the image filename/path in the Python script. Make sure to change the width and height variables to the desired proportions.

Run: py pixelConversion.py

The ImageProcessor_tb.v file will then need to have height and width values adjusted and compiled before simulation.

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
    | 
    v 
Image Resizing / Preprocessing 
    | 
    v 
RGB Pixel Data 
    | 
    v 
Grayscale Conversion 
    | 
    v 
3x3 Pixel Window 
    | 
    v 
Sobel Gx / Gy Calculation 
    | 
    v 
Edge Magnitude 
    | 
    v 
Output Image

# Planned FPGA Implementation

The FPGA portion of this project is currently under development and has not yet been deployed to hardware.

The planned architecture is:
Pixel Input 
    | 
    v 
Line Buffers 
    | 
    v  
3x3 Pixel Window  
    | 
    v  
Sobel Datapath (Gx and Gy)
    | 
    v  
Edge Magnitude 
    | 
    v 
Pixel Output

The goal is to implement the computational portion of the Sobel algorithm as synthesizable Verilog rather than executing the algorithm sequentially in software.

Planned development stages include:

 - Create and verify the software reference implementation.
 - Design the Sobel datapath in Verilog.
 - Develop Verilog testbenches for individual RTL modules.
 - Compare RTL results against the software-generated reference output.
 - Synthesize the design using Vivado.
 - Analyze FPGA resource utilization and timing.
 - Deploy and validate the completed design on a Basys 3 Artix-7 FPGA.

# Running the Tests
The software implementation can be tested using images of different sizes and content.

//Software testing

Testing should verify that:

 - Images are read correctly.
 - RGB values are converted correctly for processing.
 - Image dimensions are handled correctly.
 - Sobel convolution produces valid output.
 - Output image dimensions are correct.
 - Image boundaries are handled appropriately.

Visual inspection of the generated edge-detected image can also be used to confirm expected behavior.

//RTL Testing

RTL testing will be added as the FPGA implementation is developed.

Each Verilog module will have an associated testbench. ModelSim/QuestaSim will be used to inspect signals and verify module behavior before synthesis.

The final RTL verification process is planned to compare FPGA/RTL-generated pixel values against values produced by the software reference implementation.

# Deployment
FPGA deployment has not yet been completed.

The target hardware for the project is a Digilent Basys 3 development board containing a Xilinx Artix-7 FPGA.


# Project Goals
The primary goal of this project is to gain experience translating an algorithm from a software implementation into dedicated digital hardware.


# Future Improvements

 - Streaming pixel processing
 - Pipelined Sobel calculations
 - BRAM-based image buffering
 - Real-time image processing
 - UART-based image transfer
 - VGA or HDMI output
 - Additional configurable image-processing kernels
 - Performance comparison between software and FPGA implementations

# Author 
Stephen Bobbitt 

Electrical Engineering
University of Arkansas
Expected Graduation: December 2028
