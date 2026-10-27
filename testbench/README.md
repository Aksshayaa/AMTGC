
# AMTGC | Adaptive Multi-Junction Traffic Controller

**RTL Design · ML-Based Adaptive Timing · Green-Wave Coordination · Pedestrian Arbitration**

AMTGC is a Verilog-based traffic signal control project designed to explore adaptive signal timing and coordinated operation across two connected intersections. It combines an ML-based timing predictor with FSM-based junction controllers, green-wave coordination, pedestrian request arbitration, and emergency override logic.

The project was developed using **Verilog HDL and ModelSim Intel FPGA Edition 2020.1**, with the design evaluated through simulation and testbenches.

---

## Overview

Traditional traffic signals often rely on predefined timing schedules. AMTGC explores a more adaptive approach by using traffic-density inputs to select green-light durations while coordinating signal phases between two junctions.

The system models two four-way intersections, Junction A and Junction B. Each junction has a controller responsible for sequencing north-south and east-west traffic signals. Additional modules support timing prediction, green-wave coordination, pedestrian requests, and timed operations.

The main focus is on RTL design, modular architecture, integration, and simulation-based verification.

## Key Features

| Feature                       | Description                                                    |
| ----------------------------- | -------------------------------------------------------------- |
| ML-based adaptive timing      | Selects a green-duration class based on traffic-density inputs |
| FSM-based signal control      | Manages traffic light sequencing and phase transitions         |
| Green-wave coordination       | Coordinates north-south green activation between junctions     |
| Pedestrian arbitration        | Manages competing pedestrian crossing requests                 |
| Emergency override            | Includes logic intended to force an all-red condition          |
| Generic timer                 | Provides reusable timing functionality                         |
| Modular RTL design            | Separates the system into individual Verilog modules           |
| Simulation-based verification | Uses testbenches and ModelSim waveforms                        |

---

## System Architecture

The diagram below illustrates the main functional modules and their intended relationships within AMTGC.

<p align="center">
  <img src="screenshots/system_architecture.png" alt="AMTGC System Architecture showing the ML timing predictor, two junction controllers, green-wave coordinator, pedestrian arbiter, generic timer, and emergency override" width="900">
</p>

<p align="center">
  <em>Figure 1: System architecture of the Adaptive Multi-Junction Traffic Grid Controller.</em>
</p>

The architecture combines adaptive timing and junction-level control with coordination and pedestrian arbitration. The actual signal connections are defined in `rtl/amtgc_top.v`.

## How It Works

### 1. ML-Based Adaptive Timing

The `ml_timing_predictor.v` module evaluates traffic-density inputs and selects a green-duration class.

The current design uses the following illustrative timing classes:

| Timing Class |        Duration |
| ------------ | --------------: |
| SHORT        |  5 clock cycles |
| MEDIUM       |  8 clock cycles |
| LONG         | 12 clock cycles |

The predictor uses decision-tree-style logic. These timing values are simulation parameters, and the model has not been validated against real-world traffic data.

### 2. Junction Controllers

The `junction_controller.v` module uses a finite-state machine (FSM) to manage traffic signal sequencing.

The controller handles transitions between north-south and east-west phases, including green, yellow, and all-red states. Phase counters determine when the controller advances to its next state.

### 3. Green-Wave Coordination

The `green_wave_coordinator.v` module coordinates north-south green activation between Junction A and Junction B.

It uses Junction A's green-start event and Junction B's readiness signal to manage the timing relationship between the two junctions.

In a reported timing test, the interval between Junction A's green-start event and Junction B's green activation was measured as **5 clock cycles** for the tested scenario.

### 4. Pedestrian Arbitration

The `ped_arbiter.v` module manages pedestrian crossing requests from both junctions.

The arbiter uses request, grant, and completion signals to coordinate crossing service. Its intended fairness mechanism alternates priority after completed service, helping prevent one junction from continually taking priority.

### 5. Emergency Override

The design includes emergency-override logic intended to force both junctions into an all-red state and suppress pedestrian grants during an emergency.

The implementation should be evaluated using the relevant testbenches. Simulation alone does not establish that the design is suitable for real-world traffic control.

### 6. Generic Timer

The `generic_timer.v` module provides reusable timing functionality for operations that require cycle counting.

Keeping timing logic in a separate module supports modularity and makes it easier to test timing behaviour independently.

---

## Technology Stack

- **Hardware Description Language:** Verilog
- **Simulation Tool:** ModelSim Intel FPGA Edition 2020.1
- **Code Editor:** Visual Studio Code
- **Design Concepts:** FSMs, adaptive timing, digital control, arbitration, and synchronous logic
- **Machine Learning Approach:** Decision-tree-style timing prediction

---

## Project Structure

```text
AMTGC/
├── docs/
├── ml/
├── rtl/
│   ├── amtgc_top.v
│   ├── generic_timer.v
│   ├── green_wave_coordinator.v
│   ├── junction_controller.v
│   ├── ml_timing_predictor.v
│   └── ped_arbiter.v
├── screenshots/
│   └── system_architecture.png
├── testbench/
│   ├── amtgc_top_tb.v
│   ├── generic_timer_tb.v
│   ├── green_wave_coordinator_tb.v
│   ├── green_wave_timing_tb.v
│   ├── junction_controller_tb.v
│   ├── ml_timing_predictor_tb.v
│   ├── ped_arbiter_fairness_tb.v
│   ├── ped_arbiter_tb.v
│   └── pedestrian_integration_tb.v
└── README.md
```

---

## Simulation and Verification

The project contains separate testbenches for the main RTL modules and their integration.

| Module or Function              | Testbench                       |
| ------------------------------- | ------------------------------- |
| Top-level integration           | `amtgc_top_tb.v`              |
| Generic timer                   | `generic_timer_tb.v`          |
| Green-wave coordinator          | `green_wave_coordinator_tb.v` |
| Green-wave timing               | `green_wave_timing_tb.v`      |
| Junction controller             | `junction_controller_tb.v`    |
| ML timing predictor             | `ml_timing_predictor_tb.v`    |
| Pedestrian arbiter              | `ped_arbiter_tb.v`            |
| Pedestrian arbitration fairness | `ped_arbiter_fairness_tb.v`   |
| Pedestrian integration          | `pedestrian_integration_tb.v` |

During development, the individual testbenches were reported to pass, including a green-wave timing test with a measured interval of five clock cycles.

Before final submission, rerun the testbenches against the final saved RTL and retain the relevant ModelSim transcripts and waveform screenshots.

### Example ModelSim Commands

Run these commands from the project root in the ModelSim Transcript window:

```tcl
vlib work
vlog rtl/generic_timer.v
vlog rtl/ml_timing_predictor.v
vlog rtl/junction_controller.v
vlog rtl/green_wave_coordinator.v
vlog rtl/ped_arbiter.v
vlog rtl/amtgc_top.v
```

To compile and run an individual testbench, for example the green-wave timing test:

```tcl
vlog testbench/green_wave_timing_tb.v
vsim work.green_wave_timing_tb
add wave -r *
run -all
```

**Note:** These commands assume that the testbench module is named `green_wave_timing_tb`. If the module declaration inside your file uses a different name, use that name in the `vsim work.<module_name>` command. Compile any additional dependencies required by your selected testbench.

## Screenshots

 Items include:

- System architecture diagram
- ML timing predictor simulation
- Junction controller waveform
- Green-wave timing waveform
- Pedestrian arbitration test results
- Top-level integration simulation

## Limitations

- The timing predictor uses illustrative rules and timing classes rather than a validated real-world traffic dataset.
- The project has been evaluated through RTL simulation, not deployment on a physical traffic-control system.
- Passing selected testbenches does not prove exhaustive correctness or real-world safety.
- Real-world use would require reliable sensors, realistic timing calibration, fault handling, hardware testing, and extensive safety validation.

## Future Improvements

- Train and evaluate the timing predictor using realistic traffic-density data.
- Compare adaptive timing with fixed-time control in a traffic simulator.
- Extend coordination to more than two intersections.
- Expand verification for simultaneous pedestrian requests and emergency activation.
- Explore FPGA synthesis and hardware implementation.
- Measure system performance using defined traffic-flow metrics.Project Status

**RTL development and simulation-based verification.**

AMTGC explores how adaptive timing, FSM-based signal control, junction coordination, and pedestrian arbitration can be combined in a modular Verilog design.

For detailed design decisions, verification procedures, simulation results, and limitations, refer to the technical report in the `docs/` directory.

# AMTGC | Adaptive Multi-Junction Traffic Controller

**RTL Design · ML-Based Adaptive Timing · Green-Wave Coordination · Pedestrian Arbitration**

AMTGC is a Verilog-based traffic signal control project designed to explore adaptive signal timing and coordinated operation across two connected intersections. It combines an ML-based timing predictor with FSM-based junction controllers, green-wave coordination, pedestrian request arbitration, and emergency override logic.

The project was developed using **Verilog HDL and ModelSim Intel FPGA Edition 2020.1**, with the design evaluated through simulation and testbenches.

## Overview

Traditional traffic signals often rely on predefined timing schedules. AMTGC explores a more adaptive approach by using traffic-density inputs to select green-light durations while coordinating signal phases between two junctions.

The system models two four-way intersections, Junction A and Junction B. Each junction has a controller responsible for sequencing north-south and east-west traffic signals. Additional modules support timing prediction, green-wave coordination, pedestrian requests, and timed operations.

The main focus is on RTL design, modular architecture, integration, and simulation-based verification.

## Key Features

| Feature                       | Description                                                    |
| ----------------------------- | -------------------------------------------------------------- |
| ML-based adaptive timing      | Selects a green-duration class based on traffic-density inputs |
| FSM-based signal control      | Manages traffic light sequencing and phase transitions         |
| Green-wave coordination       | Coordinates north-south green activation between junctions     |
| Pedestrian arbitration        | Manages competing pedestrian crossing requests                 |
| Emergency override            | Includes logic intended to force an all-red condition          |
| Generic timer                 | Provides reusable timing functionality                         |
| Modular RTL design            | Separates the system into individual Verilog modules           |
| Simulation-based verification | Uses testbenches and ModelSim waveforms                        |

---

## System Architecture

The diagram below illustrates the main functional modules and their intended relationships within AMTGC.

<p align="center">
  <img src="screenshots/system_architecture.png" alt="AMTGC System Architecture showing the ML timing predictor, two junction controllers, green-wave coordinator, pedestrian arbiter, generic timer, and emergency override" width="900">
</p>

<p align="center">
  <em>Figure 1: System architecture of the Adaptive Multi-Junction Traffic Grid Controller.</em>
</p>

The architecture combines adaptive timing and junction-level control with coordination and pedestrian arbitration. The actual signal connections are defined in `rtl/amtgc_top.v`.

## How It Works

### 1. ML-Based Adaptive Timing

The `ml_timing_predictor.v` module evaluates traffic-density inputs and selects a green-duration class.

The current design uses the following illustrative timing classes:

| Timing Class |        Duration |
| ------------ | --------------: |
| SHORT        |  5 clock cycles |
| MEDIUM       |  8 clock cycles |
| LONG         | 12 clock cycles |

The predictor uses decision-tree-style logic. These timing values are simulation parameters, and the model has not been validated against real-world traffic data.

### 2. Junction Controllers

The `junction_controller.v` module uses a finite-state machine (FSM) to manage traffic signal sequencing.

The controller handles transitions between north-south and east-west phases, including green, yellow, and all-red states. Phase counters determine when the controller advances to its next state.

### 3. Green-Wave Coordination

The `green_wave_coordinator.v` module coordinates north-south green activation between Junction A and Junction B.

It uses Junction A's green-start event and Junction B's readiness signal to manage the timing relationship between the two junctions.

In a reported timing test, the interval between Junction A's green-start event and Junction B's green activation was measured as **5 clock cycles** for the tested scenario.

### 4. Pedestrian Arbitration

The `ped_arbiter.v` module manages pedestrian crossing requests from both junctions.

The arbiter uses request, grant, and completion signals to coordinate crossing service. Its intended fairness mechanism alternates priority after completed service, helping prevent one junction from continually taking priority.

### 5. Emergency Override

The design includes emergency-override logic intended to force both junctions into an all-red state and suppress pedestrian grants during an emergency.

The implementation should be evaluated using the relevant testbenches. Simulation alone does not establish that the design is suitable for real-world traffic control.

### 6. Generic Timer

The `generic_timer.v` module provides reusable timing functionality for operations that require cycle counting.

Keeping timing logic in a separate module supports modularity and makes it easier to test timing behaviour independently.

---

## Technology Stack

- **Hardware Description Language:** Verilog
- **Simulation Tool:** ModelSim Intel FPGA Edition 2020.1
- **Code Editor:** Visual Studio Code
- **Design Concepts:** FSMs, adaptive timing, digital control, arbitration, and synchronous logic
- **Machine Learning Approach:** Decision-tree-style timing prediction

---

## Project Structure

```text
AMTGC/
├── docs/
├── ml/
├── rtl/
│   ├── amtgc_top.v
│   ├── generic_timer.v
│   ├── green_wave_coordinator.v
│   ├── junction_controller.v
│   ├── ml_timing_predictor.v
│   └── ped_arbiter.v
├── screenshots/
│   └── system_architecture.png
├── testbench/
│   ├── amtgc_top_tb.v
│   ├── generic_timer_tb.v
│   ├── green_wave_coordinator_tb.v
│   ├── green_wave_timing_tb.v
│   ├── junction_controller_tb.v
│   ├── ml_timing_predictor_tb.v
│   ├── ped_arbiter_fairness_tb.v
│   ├── ped_arbiter_tb.v
│   └── pedestrian_integration_tb.v
└── README.md
```

*This structure reflects the files shown in the development workspace. Update it if you rename or reorganise any files.*

---

## Simulation and Verification

The project contains separate testbenches for the main RTL modules and their integration.

| Module or Function              | Testbench                       |
| ------------------------------- | ------------------------------- |
| Top-level integration           | `amtgc_top_tb.v`              |
| Generic timer                   | `generic_timer_tb.v`          |
| Green-wave coordinator          | `green_wave_coordinator_tb.v` |
| Green-wave timing               | `green_wave_timing_tb.v`      |
| Junction controller             | `junction_controller_tb.v`    |
| ML timing predictor             | `ml_timing_predictor_tb.v`    |
| Pedestrian arbiter              | `ped_arbiter_tb.v`            |
| Pedestrian arbitration fairness | `ped_arbiter_fairness_tb.v`   |
| Pedestrian integration          | `pedestrian_integration_tb.v` |

During development, the individual testbenches were reported to pass, including a green-wave timing test with a measured interval of five clock cycles.

Before final submission, rerun the testbenches against the final saved RTL and retain the relevant ModelSim transcripts and waveform screenshots.

### Example ModelSim Commands

Run these commands from the project root in the ModelSim Transcript window:

```tcl
vlib work
vlog rtl/generic_timer.v
vlog rtl/ml_timing_predictor.v
vlog rtl/junction_controller.v
vlog rtl/green_wave_coordinator.v
vlog rtl/ped_arbiter.v
vlog rtl/amtgc_top.v
```

To compile and run an individual testbench, for example the green-wave timing test:

```tcl
vlog testbench/green_wave_timing_tb.v
vsim work.green_wave_timing_tb
add wave -r *
run -all
```

**Note:** These commands assume that the testbench module is named `green_wave_timing_tb`. If the module declaration inside your file uses a different name, use that name in the `vsim work.<module_name>` command. Compile any additional dependencies required by your selected testbench.

---

## Screenshots

The `screenshots/` folder can contain the visual evidence used to document the project.

Recommended items include:

- System architecture diagram
- ML timing predictor simulation
- Junction controller waveform
- Green-wave timing waveform
- Pedestrian arbitration test results
- Top-level integration simulation

Only include screenshots that correspond to actual runs of your project. Use clear filenames and refer to them in the technical report where relevant.

---

## Limitations

- The timing predictor uses illustrative rules and timing classes rather than a validated real-world traffic dataset.
- The project has been evaluated through RTL simulation, not deployment on a physical traffic-control system.
- Passing selected testbenches does not prove exhaustive correctness or real-world safety.
- Real-world use would require reliable sensors, realistic timing calibration, fault handling, hardware testing, and extensive safety validation.

## Future Improvements

- Train and evaluate the timing predictor using realistic traffic-density data.
- Compare adaptive timing with fixed-time control in a traffic simulator.
- Extend coordination to more than two intersections.
- Expand verification for simultaneous pedestrian requests and emergency activation.
- Explore FPGA synthesis and hardware implementation.
- Measure system performance using defined traffic-flow metrics.

---

## Project Status

**RTL development and simulation-based verification.**

AMTGC explores how adaptive timing, FSM-based signal control, junction coordination, and pedestrian arbitration can be combined in a modular Verilog design.

For detailed design decisions, verification procedures, simulation results, and limitations, refer to the technical report in the `docs/` directory.
