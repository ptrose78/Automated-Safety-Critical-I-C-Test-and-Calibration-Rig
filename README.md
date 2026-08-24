<a name="top"></a>

<div align="center">
  <!-- <img src="Documentation/logo.png" alt="Calibration Rig Logo" width="150"/> -->
  <h1>Automated Safety-Critical I&C Test and Calibration Rig</h1>
</div>

An automated, database-driven test and calibration system built in **LabVIEW**, utilizing an integrated **SQLite relational database engine** for dynamic configuration, test execution, and persistent logging.

Designed for high-precision sensor calibration, steady-state limit verification, simulated noise injection, and rigorous safety-critical instrumentation and control (I&C) testing.

---

## 📑 Table of Contents
* [📸 System Overview & Architecture](#-system-overview--architecture)
* [🔑 Key Features](#-key-features)
* [🚀 Getting Started & Execution](#-getting-started--execution)
* [⚙️ Configuration & Operational Modes](#%EF%B8%8F-configuration--operational-modes)
* [🛠 Tech Stack & Dependencies](#-tech-stack--dependencies)
* [🛡️ Error Handling & Fault Management](#️-error-handling--fault-management)
* [📂 Directory Structure](#-directory-structure)
* [🗄️ Data Persistence & Database Schema](#%EF%B8%8F-data-persistence--database-schema)
  * [💾 Data Persistence & File Outputs](#-data-persistence--file-outputs)
  * [🗄️ SQLite Database Schema](#%EF%B8%8F-sqlite-database-schema)

---

## 📸 System Overview & Architecture

The system coordinates simulated or physical data acquisition, pass/fail evaluation logic based on customizable dwell timers, and a resilient database logging architecture to ensure calibration records are written accurately without interrupting testing flow.

```text
                               ┌──────────────────────────────────────────────┐
                               │        NI DAQmx / Hardware Acquisition       │
                               │          (or Waveform Simulation)            │
                               └──────────────────────┬───────────────────────┘
                                                      │ (Multi-Channel Data)
                                                      ▼
                               ┌──────────────────────────────────────────────┐
                               │           Test Execution & V&V Loop          │
                               │  (Moving Average, Timers, Limit Evaluation)  │
                               └────┬─────────────────┬──────────────────┬────┘
                                    │                 │                  │
         (Test Configuration Sync)  │                 │                  │ (Calibration Results)
                                    ▼                 │                  ▼
           ┌──────────────────────────┐               │                ┌──────────────────────────┐
           │     Database Engine      │               │                │     Database Engine      │
           │  (TestConfigurations)    │               ▼                │   (CalibrationPoints)    │
           └──────────────────────────┘      ┌────────────────────┐    └──────────────────────────┘
                                             │   Graph / UI Loop  │
                                             │ (Real-Time Display)│
                                             └────────────────────┘
```
---

## 🔑 Key Features

* **Configurable Test Models:** Dynamic sensor testing configurations stored in a database, allowing independent `SteadyStateDurationSec` and `MaxSettlingTimeoutSec` parameterization per sensor model.
* **Steady-State V&V Evaluation:** Implements independent dwell timers and rolling sample windows to verify measurements stabilize within strict error tolerances (e.g., `< 0.02`) before logging pass/fail results.
* **Database-Driven Execution:** Automated SQLite schema handling utilizing LabVIEW DB Tools, ensuring safe insertion of foreign keys (`ChannelRecordID`) and automatic generation of primary keys and timestamps.
* **High-Fidelity Sensor Simulation:** Integrated waveform simulation with synchronized sample counts and precise white noise attenuation to mimic real-world industrial 4–20 mA loops or thermocouple jitter.

[⬆ Back to Top](#top)

---

## 🚀 Getting Started & Execution

### 1. Prerequisites & Dependencies

Before running the Calibration Rig, ensure all software dependencies are installed.

#### Software Requirements

| Component | Requirement |
| :--- | :--- |
| **LabVIEW** | National Instruments LabVIEW |
| **Database Tools** | LabVIEW Database Connectivity Toolkit (or NI Database API) |
| **Database Viewer**| DB Browser for SQLite (recommended for offline schema editing) |
| **ODBC Drivers** | SQLite3 ODBC Driver (32-bit or 64-bit to match LabVIEW architecture) |

---

### 🔌 Hardware & DAQmx Configuration 

When running in **Simulation Mode**, the application utilizes synchronized auto-indexing For Loops and Random Number generators to construct multi-channel Y-arrays mimicking physical sensor data. Noise standard deviation and amplitude are tightly controlled to remain below tolerance thresholds, preventing false test failures.

When deploying to physical hardware, standard NI-DAQmx tasks manage the analog inputs for real-world instrument calibration.

[⬆ Back to Top](#top)

---

## ⚙️ Configuration & Operational Modes

System test steps, settling delays, and sensor limits are controlled dynamically via the local SQLite database. This allows operational modes and sequence timing to be altered without recompiling LabVIEW VIs.

### 📄 Database Configurations Reference

| Table | Parameter | Description |
| :--- | :--- | :--- |
| `TestConfigurations` | `ModelNumber` | The specific sensor or instrument profile being tested. |
| `TestConfigurations` | `SteadyStateDurationSec` | Mandatory dwell time (e.g., **5s, 8s, 10s**) required for successful evaluation. |
| `TestConfigurations` | `MaxSettlingTimeoutSec` | Delay period (e.g., **3s, 5s, 7s**) to allow signal transients to stabilize before evaluation begins. |

[⬆ Back to Top](#top)

---

## 🛠 Tech Stack & Dependencies

| Component | Technology / Library | Purpose |
| :--- | :--- | :--- |
| **Core Application** | LabVIEW | System logic, UI, and test sequencer |
| **Data Acquisition** | NI DAQmx / Simulation Engine | Physical I/O and synchronized waveform arrays |
| **Database Engine** | SQLite / LabVIEW DB Tools | Relational test configuration and result persistence |

[⬆ Back to Top](#top)

---

## 🛡️ Error Handling & Fault Management

* **Relational Integrity:** Enforces SQLite foreign key constraints to ensure calibration data cannot be logged against a non-existent `TestRunChannels` parent record.
* **ADO Parameter Matching:** Catch mechanisms for Argument errors (`0x00000001`) to ensure dynamic insert statements perfectly align with array values.
* **Noise Mitigation:** Uses digital smoothing filters and amplitude limits to prevent high-frequency white noise from causing false-positive out-of-tolerance failures.

[⬆ Back to Top](#top)

---

## 📂 Directory Structure

*(Details will be added in a later update once the module hierarchy is finalized.)*

[⬆ Back to Top](#top)

---

## 🗄️ Data Persistence & Database Schema

### 💾 Data Persistence & File Outputs

The rig generates and manages its configurations and results in a single, local SQLite database file, preserving relationships between active test runs, specific hardware channels, and individual calibration points.

### 🗄️ SQLite Database Schema

The core operations rely on tightly linked relational tables:

```sql
-- Sensor Test Configuration Profiles
CREATE TABLE IF NOT EXISTS TestConfigurations (
    ConfigID INTEGER PRIMARY KEY AUTOINCREMENT,
    ModelNumber TEXT NOT NULL,
    TargetSampleRateHz REAL,
    SteadyStateDurationSec REAL NOT NULL,
    AllowedTolerancePercent REAL,
    MaxSettlingTimeoutSec REAL NOT NULL
);

-- Active Test Run Channels Mapping
CREATE TABLE IF NOT EXISTS TestRunChannels (
    ChannelRecordID INTEGER PRIMARY KEY AUTOINCREMENT,
    TestRunID INTEGER NOT NULL,
    SensorID INTEGER,
    HardwareRow INTEGER,
    PhysicalChannel TEXT,
    FinalStatus TEXT,
    Duration REAL,
    SettlingTime REAL
);

-- Recorded Calibration Data Logging
CREATE TABLE IF NOT EXISTS CalibrationPoints (
    PointID INTEGER PRIMARY KEY AUTOINCREMENT,
    TestRunID INTEGER NOT NULL,
    ChannelRecordID INTEGER NOT NULL,
    Setpoint REAL,
    ReferenceValue REAL,
    MeasuredValue REAL,
    ErrorPercent REAL,
    TestResult TEXT DEFAULT 'PENDING',
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(ChannelRecordID) REFERENCES TestRunChannels(ChannelRecordID)
);