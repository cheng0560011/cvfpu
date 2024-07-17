
# Testbench README

## Overview

This README provides information on how to use the testbench for verifying the CVFPU. The testbench includes a Makefile for managing build and simulation tasks, and supports optional debug messaging and waveform viewing. It is designed to work with VCS 2017 for compilation and Verdi for waveform analysis.


## Directory Structure

- testbench/
    - `Makefile`
    - `flist`
    - `tb.sv`
    - `input.txt`
    - `golden.txt`

- **Makefile**: Contains targets for building, running, verifying, and cleaning the testbench.

- **flist**: Lists the SystemVerilog source files, including the testbench and CVFPU.

- **tb.sv**: Testbench for CVFPU.

- **input.txt**: Input file with operation and operands. The operands are single-precision floating-point numbers in hexadecimal format.
```
Format: <RVF operation> <operand 1> <operand 2>
e.g. fadd.s 4a8f5d0c 0c8c8a7b
```

- **golden.txt**: Expected result according to input.txt. The operands and expected result are single-precision floating-point numbers in hexadecimal format.
```
Format: <RVF operation> <operand 1> <operand 2> <answer>
e.g. fadd.s 4a8f5d0c 0c8c8a7b 4a8f5d0c
```

## Makefile Targets

### all

Compiles the testbench and DUT, runs the simulation, and performs verification.

```
make all
```

### run
Runs the simulation.
```
make run
```
To enable debug messages, specify the DEBUG variable:
```
make run DEBUG=1
```

### verify
Compares the output of the simulation against the expected results.

```
make verify
```

### waveform
Generates and opens the waveform file using Verdi.
```
make waveform
```

### clean
Cleans up generated files and simulation artifacts.
```
make clean
```