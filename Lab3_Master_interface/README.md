# Lab 3: Camera & LCD conceptual design

## Introduction

In the previous labs, you focused on the design of custom slave interfaces which are targeted towards simple
use cases where small amounts of data needs to be moved between a peripheral and a processor. In this lab
we will instead focus on the design of custom master interfaces which are targeted towards complex use
cases where large amounts of data need to be moved:

- From a peripheral to memory (camera)
- From memory to a peripheral (display)

## Goal

The goal of this lab is for you to propose a detailed design for an FPGA-based system which can interface with
one of the following peripherals on the DE0-Nano-SoC:

- TRDB-D5M camera
- LT24 LCD display
