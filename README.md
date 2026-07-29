# Asynchronous FIFO in Verilog

A fully parameterized Asynchronous FIFO (First-In-First-Out) memory buffer written in Verilog. This design safely transfers data between two asynchronous clock domains using Gray code pointer synchronization.

## Features
* **Parameterized Design:** Configurable data width and memory depth.
* **Clock Domain Crossing (CDC):** Uses 2-stage flip-flop synchronizers to mitigate metastability.
* **Safe Pointer Logic:** Implements Binary-to-Gray code conversion for reliable pointer synchronization across clock boundaries.
* **Flag Generation:** Accurate full and empty flag generation to prevent overflow and underflow conditions.

## Architecture Block Diagram

The design utilizes a dual-port RAM surrounded by independent read and write control logic, bridged by 2-stage synchronizers.

```mermaid
flowchart LR
    %% Define the domains
    subgraph Write_Domain["Write Domain (wclk)"]
        direction TB
        W_CTRL["write_ptr_handler"]
        SYNC_W["sync_r2w"]
    end

    subgraph Memory["Memory"]
        FIFO_MEM[("fifo_mem\n(Dual-Port RAM)")]
    end

    subgraph Read_Domain["Read Domain (rclk)"]
        direction TB
        R_CTRL["read_ptr_handler"]
        SYNC_R["sync_w2r"]
    end

    %% Data Path
    Data_In ===> FIFO_MEM
    FIFO_MEM ===> Data_Out

    %% Internal Routing
    W_CTRL -- "Binary Write Ptr" --> FIFO_MEM
    R_CTRL -- "Binary Read Ptr" --> FIFO_MEM

    W_CTRL -- "Gray Write Ptr" ---> SYNC_R
    R_CTRL -- "Gray Read Ptr" ---> SYNC_W

    SYNC_W -- "Sync Gray Read Ptr" --> W_CTRL
    SYNC_R -- "Sync Gray Write Ptr" --> R_CTRL

    %% Status Flags
    w_en --> W_CTRL
    r_en --> R_CTRL
    W_CTRL --> FULL(("full flag"))
    R_CTRL --> EMPTY(("empty flag"))
