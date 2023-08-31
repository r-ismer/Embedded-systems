# Lab 4: Mini-project

## Introduction

In lab 3.0 we proposed a detailed design for an FPGA-based system which can interface with the
following peripherals on the DE0-Nano-SoC:

- TRDB-D5M camera
- LT24 LCD display

## Goal

The goal of lab 4.0 is for you to implement the detailed design we proposed in lab 3.0:

1. Each group of 2 students independently implemented their camera or LCD design. We
needed to test our implementation by performing suitable simulations with ModelSim to ensure that
the design functions as we expected. Before we implemented our design, we must agree on the format
a frame will have once in memory for your designs to work correctly once put together.
2. Once our simulations were conclusive and corresponded to what we expected, we have been then
provided with the actual camera and LCD extension boards so we could test our design on the real hardware.
    1. For the group implementing the camera design, the ultimate test will be to save a frame in
memory then transfer it to our host PC so we could visually inspect it with an image viewer.
    2. For the group implementing the LCD, the ultimate test will be to store a
frame in memory from our host PC, then to output it through our LCD controller so
we could visually inspect the result on the target displays.
3. Once each team’s hardware design functions correctly in isolation, we proceeded to merge
the designs together to obtain a complete frame acquisition and visualization system
