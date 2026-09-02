# RSMA-Enabled RIS-Assisted ISAC for 6G Networks

A MATLAB-based simulation framework for studying the joint communication and sensing performance of **Rate-Splitting Multiple Access (RSMA)** and **Reconfigurable Intelligent Surfaces (RIS)** in **Integrated Sensing and Communication (ISAC)** systems for next-generation 6G wireless networks.

## 📌 Project Overview

Integrated Sensing and Communication (ISAC) aims to use the same wireless infrastructure and spectrum for both data communication and environmental sensing.

This project combines:

* **RSMA** for interference management and multi-user communication
* **RIS** for intelligent wireless propagation control
* **ISAC** for simultaneous communication and sensing
* **Rician fading** for the BS-RIS link
* **Rayleigh fading** for RIS-user and direct BS-user links
* **QPSK modulation** for communication analysis
* Target range estimation for sensing evaluation

The simulation evaluates how RIS-assisted propagation and RSMA transmission affect communication reliability, spectral efficiency, sensing capability, and energy efficiency.

---

## 🚀 Key Features

### 1. RSMA Transmission

The transmitter divides the information into:

```text
                    Transmitted Signal
                           |
              ┌────────────┴────────────┐
              │                         │
        Common Stream             Private Streams
                                      /      \
                                   User 1   User 2
```

The common stream is decoded by both users, while each private stream is intended for its corresponding user.

The implemented model calculates:

* Common-stream SINR
* Private-stream SINR
* Common rate
* Private rates
* Overall RSMA spectral efficiency

---

### 2. RIS-Assisted Communication

A RIS consisting of configurable reflecting elements is introduced between the BS and users.

The effective channel is modeled as:

$$
H_{\mathrm{eff}}
=
H_{\mathrm{BU}}
+
H_{\mathrm{RU}}\Phi H_{\mathrm{BR}}
$$

where:

* \(H_{\mathrm{BU}}\) = direct BS-user channel
* \(H_{\mathrm{BR}}\) = BS-RIS channel
* \(H_{\mathrm{RU}}\) = RIS-user channel
* \(\Phi\) = RIS phase-shift matrix

The simulation uses **32 RIS elements** and performs phase alignment to enhance the effective channel.

---

### 3. Wireless Channel Modeling

The BS-RIS link uses a Rician fading model:

$$
H =
\sqrt{\frac{K}{K+1}}H_{\mathrm{LOS}}
+
\sqrt{\frac{1}{K+1}}H_{\mathrm{NLOS}}
$$

while RIS-user and direct BS-user channels are modeled using complex Gaussian fading.

---

### 4. Communication Performance

The project evaluates communication performance over an SNR range of:

```text
0, 5, 10, 15, 20, 25, 30 dB
```

The main communication metric is:

$$
R = R_c + \sum_{k=1}^{K}R_k
$$

where \(R_c\) is the common-stream rate and \(R_k\) represents the private-stream rate of user \(k\).

---

### 5. BER Analysis

QPSK modulation is used to evaluate communication reliability.

The simulation generates random binary data, maps the bits to QPSK symbols, transmits them through the RSMA private-stream channel, adds AWGN, and performs symbol detection.

The resulting BER is evaluated as a function of SNR.

---

### 6. ISAC Sensing

A simplified target sensing model is incorporated to study sensing performance.

The simulation considers:

* Target reflection coefficient
* RIS-assisted sensing gain
* Sensing interference
* Sensing SINR

The sensing metric is represented as:

$$
\mathrm{SINR}_{sense}
=
\frac{P_{target}}
{P_{interference}+P_{noise}}
$$

---

### 7. Range Estimation

The sensing subsystem estimates the target range using the system bandwidth.

The theoretical range resolution is approximated by:

$$
\Delta R = \frac{c}{2B}
$$

where:

* \(c\) = speed of light
* \(B\) = system bandwidth

The simulation evaluates the resulting range estimation error.

---

### 8. Energy Efficiency

Energy efficiency is evaluated using:

$$
EE =
\frac{\text{Spectral Efficiency}}
{\text{Total Power Consumption}}
$$

This allows the communication performance to be studied from both throughput and power-efficiency perspectives.

---

## ⚙️ System Configuration

| Parameter            |    Value |
| -------------------- | -------: |
| BS antennas          |        4 |
| Users                |        2 |
| RIS elements         |       32 |
| Carrier frequency    |   28 GHz |
| Bandwidth            |   20 MHz |
| Monte-Carlo trials   |      150 |
| Common-stream power  |      30% |
| Private-stream power |      70% |
| Modulation           |     QPSK |
| BS-RIS channel       |   Rician |
| User channels        | Rayleigh |
| SNR range            |  0–30 dB |

---

## 📊 Performance Metrics

The simulation generates the following performance plots:

### Communication

* RSMA spectral efficiency vs SNR
* Conventional transmission vs RSMA
* RIS-assisted vs non-RIS communication

### Reliability

* BER vs SNR

### Sensing

* Sensing SINR vs SNR
* Target range estimation error vs SNR

### Efficiency

* Energy efficiency vs SNR

---

## 🛠️ Requirements

* MATLAB R2020a or later
* No specialized communication toolbox is required
* Basic MATLAB numerical and plotting functionality

---

## ▶️ How to Run

1. Clone the repository.

2. Open MATLAB.

3. Navigate to the repository directory.

4. Run:

```matlab
RSMA_RIS_ISAC
```

5. The simulation will perform Monte-Carlo channel realizations and generate the performance plots automatically.

---


## 🔬 Research Extensions

The current framework can be extended toward more advanced research problems:

* WMMSE-based RSMA optimization
* Joint RIS phase and beamforming optimization
* OFDM-based ISAC waveform design
* Range-Doppler estimation
* MIMO radar sensing
* Multi-target sensing
* Imperfect CSI
* Hardware impairments
* RIS phase quantization
* Mobility and Doppler effects
* 6G THz/mmWave channel models
* Weighted sum-rate optimization
* Communication-sensing beamforming trade-offs

---

## 🎯 Applications

The framework is relevant to future 6G applications such as:

* Vehicular networks
* Autonomous driving
* Smart factories
* Indoor positioning
* Robotics
* Intelligent transportation systems
* High-mobility wireless communication
* Joint radar and communication systems

---

