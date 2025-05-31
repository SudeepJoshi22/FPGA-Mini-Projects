# Advanced Traffic Light Controller (FPGA Implementation)

This project implements an advanced traffic light controller using Verilog HDL, designed for FPGA platforms. The controller uses a modular architecture to handle traffic signal sequencing and timing based on real-time sensor inputs.

---

## 📁 Verilog Design Files

The following Verilog design files are part of the project (excluding testbenches):

- `traffic_controller_adv.v` – **Top-level module** that integrates all submodules.
- `fsm.v` – Implements the finite state machine (FSM) for traffic signal control.
- `timer.v` – Generates timing intervals for each traffic phase.
- `sensor_interface.v` – Interfaces with vehicle sensors to detect traffic presence.
- `display_control.v` – Controls the outputs to traffic lights based on FSM state.

---

## 🧠 Top Module

### `traffic_controller_adv.v`
This is the main module that orchestrates the overall traffic light system. It instantiates and connects all necessary submodules to manage the logic and hardware interface for an intelligent traffic signal.

---

## 🔧 Instantiated Modules

- **`fsm.v`**  
  Contains the finite state machine logic to control the sequence of traffic light states.

- **`timer.v`**  
  Provides timing signals that control how long each light remains active.

- **`sensor_interface.v`**  
  Processes input from sensors (e.g., vehicle presence) and passes relevant signals to the FSM.

- **`display_control.v`**  
  Generates the appropriate control signals (Red, Yellow, Green) for traffic lights based on FSM outputs.

---

## 🔗 Repository

GitHub Repository: [Traffic-Controller-Adv](https://github.com/SudeepJoshi22/FPGA-Mini-Projects/tree/main/Traffic-Controller-Adv)

---

## 🛠️ Tools & Platform

- Language: Verilog HDL
- Target: FPGA 
- Design Approach: Modular, FSM-based

---

## 📌 Author

**Sudeep Joshi**  
[GitHub Profile](https://github.com/SudeepJoshi22)
[LinkdIn Profile][https://www.linkedin.com/in/sudeep-joshi-569951207/]

---
