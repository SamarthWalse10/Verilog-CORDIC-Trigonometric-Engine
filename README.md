# CORDIC Trigonometric Wave Generator

## Overview
This repository contains a Register Transfer Level (RTL) implementation of the CORDIC (Coordinate Rotation Digital Computer) algorithm written in Verilog<!--[cite: 4] -->. The hardware engine calculates sine and cosine values by executing a 16-iteration shift-and-add pipeline<!--[cite: 4, 6] -->. It is highly optimized for digital signal processing applications, utilizing fixed-point arithmetic to eliminate the need for expensive hardware multipliers.

## Key Features
* **Fixed-Point Architecture:** All internal data paths and mathematical operations utilize a Q2.14 fixed-point number format (2 integer bits, 14 fractional bits) to maximize logic efficiency<!--[cite: 6] -->.
* **Hardware-Optimized LUT:** Incorporates a pre-calculated 16-depth inverse tangent Look-Up Table (LUT) to drive angular rotations<!--[cite: 6] -->.
* **FSM-Based Control Pipeline:** Implements a finite state machine (IDLE and ITERATE states) to cleanly control the 16-clock-cycle calculation pipeline and assert a `done` synchronization signal upon completion<!--[cite: 6] -->.
* **Continuous 360° Waveform Synthesis:** Features a robust testbench (`cordic_tb.v`) that dynamically maps input phase angles outside the principal domain, allowing for the continuous simulation of full 360-degree analog waveforms<!--[cite: 7] -->.

## Mathematical Foundation
The CORDIC algorithm operates in rotation mode, calculating the sine and cosine of an input angle $z_0$ by iteratively rotating a vector. To avoid hardware multipliers, the rotation angles are restricted such that $\tan(\theta_i) = 2^{-i}$. 

The iterative hardware equations implemented in this design are:
$$x_{i+1} = x_i \mp (y_i \cdot 2^{-i})$$
$$y_{i+1} = y_i \pm (x_i \cdot 2^{-i})$$
$$z_{i+1} = z_i \mp \tan^{-1}(2^{-i})$$

To account for the processing gain of the CORDIC algorithm, the initial $x$ value is pre-scaled by the constant $K \approx 0.60725$, which is represented in the design as the Q2.14 hex value `16'h26DF`<!--[cite: 6] -->.

## Repository Structure
* `cordic.v`: The core RTL implementation of the CORDIC engine<!--[cite: 6] -->.
* `cordic_tb.v`: The simulation testbench that drives the engine through continuous angular sweeps<!--[cite: 7] -->.
* `angle_table.mem`: A memory file containing the pre-calculated hex values for the angular reference mapping used during simulation<!--[cite: 5, 7] -->.

## Simulation Instructions
1. Clone the repository to your local machine.
2. Import `cordic.v`, `cordic_tb.v`, and `angle_table.mem` into your preferred HDL simulator (e.g., Xilinx Vivado, ModelSim, or Icarus Verilog).
3. Ensure the `angle_table.mem` file is located in the root simulation directory so the testbench can read it via the `$readmemh` system task<!--[cite: 7] -->.
4. Run the simulation and observe the `sint` and `cost_inv` signals in the analog waveform viewer to see the generated trigonometric waves<!--[cite: 7] -->.
