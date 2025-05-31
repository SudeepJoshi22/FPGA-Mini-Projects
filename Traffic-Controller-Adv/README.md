# Advanced Traffic Light Controller

This design is based on the this [specification](https://github.com/SudeepJoshi22/FPGA-Mini-Projects/blob/main/Traffic-Controller-Adv/%F0%9F%94%A7%20Mini%20Project%20Challenge.PDF) given here.

---

## 🔧 Top Module: `top.v`

### Description

The `top.v` file serves as the main module of the design. It integrates all supporting modules — `FSM`, `counter`, and `priority`.


### Ports

#### **Inputs:**

- `clk`: Clock input
- `rst`: Synchronous active-high reset
- `ped_NS`: Pedestrian request signal from North-South direction
- `ped_EW`: Pedestrian request signal from East-West direction

#### **Outputs:**

- `NS_red`, `NS_yellow`, `NS_green`: North-South traffic light signals
- `EW_red`, `EW_yellow`, `EW_green`: East-West traffic light signals
- `ped_wait_NS`: Blinking signal indicating pedestrian is waiting in North-South
- `ped_wait_EW`: Blinking signal indicating pedestrian is waiting in East-West

---

## 🧠 Instantiated Modules

- **`FSM.v`**  
  Implements a finite state machine that controls transitions between different traffic light states based on timing and pedestrian requests.

- **`counter.v`**  
  A parameterized counter used to generate time pulses. It has two outputs `pulse_10s` and `pulse_1s` which provide stimulus to FSM to change states.

- **`priority.v`**  
  Also a counter, but used to generate times pulses to shift priority between NS and EW directions.

---

## Working of the Design

- Priority module shifts pulse for every given priority time parameterized by `PRIORITY_TIME`.
- If there are no pedestrian request signals then the traffic lights will keep changing as usual. (RED and GREEN light will stay for 10s and in between transition YELLOW light will stay for 1s)
- If there is a pedestrian request from the direction with active priority, then the traffic light will shift to RED light for 10s and then proceeds with the usual operation.
- If there is a predestrian request from the direction which doesn't have active priority then the `ped/_wait/_XX` signal will blink.
- Design can we parameterized for the given clock frequency using the parameter `CLK_FREQ`

---

---

## 🛠️ Tools & Platform

- Language: Verilog HDL
- Target: FPGA 
- Design Approach: Modular, FSM-based

---

## 📌 Author

**Sudeep Joshi**  
[GitHub Profile](https://github.com/SudeepJoshi22)
[LinkdIn Profile](https://www.linkedin.com/in/sudeep-joshi-569951207/)

---
