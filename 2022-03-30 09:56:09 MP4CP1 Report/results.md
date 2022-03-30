# AG Report Generated 2022-03-30 09:56
This is a report about mp4cp1 generated for spenserCPU at 2022-03-30 09:56. The autograder used commit ``c685bd66bee0`` as a starting point. If you have any questions about this report, please contact the TAs on Piazza.
### Quick Results:
 - Compilation: NO
 - Targeted: 0/1 (0.0%)
### Compilation ![Failure][failure]
You did not succesfully compile. Your report is below.
<details>
<summary>Compilation Report</summary>

```
Info: *******************************************************************
Info: Running Quartus Prime Analysis & Synthesis
    Info: Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition
    Info: Copyright (C) 2018  Intel Corporation. All rights reserved.
    Info: Your use of Intel Corporation's design tools, logic functions 
    Info: and other software and tools, and its AMPP partner logic 
    Info: functions, and any output files from any of the foregoing 
    Info: (including device programming or simulation files), and any 
    Info: associated documentation or information are expressly subject 
    Info: to the terms and conditions of the Intel Program License 
    Info: Subscription Agreement, the Intel Quartus Prime License Agreement,
    Info: the Intel FPGA IP License Agreement, or other applicable license
    Info: agreement, including, without limitation, that your use is for
    Info: the sole purpose of programming logic devices manufactured by
    Info: Intel and sold by Intel or its authorized distributors.  Please
    Info: refer to the applicable agreement for further details.
    Info: Processing started: Wed Mar 30 14:55:57 2022
Info: Command: quartus_map mp4 -c mp4
Warning (18236): Number of processors has not been specified which may cause overloading on shared machines.  Set the global assignment NUM_PARALLEL_PROCESSORS in your QSF to an appropriate value for best performance.
Info (20030): Parallel compilation is enabled and will use 2 of the 2 processors detected
Info (12021): Found 1 design units, including 0 entities, in source file hdl/rv32i_types.sv
    Info (12022): Found design unit 1: rv32i_types (SystemVerilog) File: /job/student/hdl/rv32i_types.sv Line: 3
Warning (12019): Can't analyze file -- file hdl/reservation_station.sv is missing
Info (12021): Found 1 design units, including 0 entities, in source file hdl/structs.sv
    Info (12022): Found design unit 1: structs (SystemVerilog) File: /job/student/hdl/structs.sv Line: 1
Warning (12019): Can't analyze file -- file hdl/rv32i_mux_types.sv is missing
Error (10161): Verilog HDL error at rv32i_types.sv(7): object "pcmux" is not declared. Verify the object name is correct. If the name is correct, declare the object. File: /job/student/hdl/rv32i_types.sv Line: 7
Error (10161): Verilog HDL error at rv32i_types.sv(8): object "marmux" is not declared. Verify the object name is correct. If the name is correct, declare the object. File: /job/student/hdl/rv32i_types.sv Line: 8
Error (10161): Verilog HDL error at rv32i_types.sv(9): object "cmpmux" is not declared. Verify the object name is correct. If the name is correct, declare the object. File: /job/student/hdl/rv32i_types.sv Line: 9
Error (10161): Verilog HDL error at rv32i_types.sv(10): object "alumux" is not declared. Verify the object name is correct. If the name is correct, declare the object. File: /job/student/hdl/rv32i_types.sv Line: 10
Error (10161): Verilog HDL error at rv32i_types.sv(11): object "regfilemux" is not declared. Verify the object name is correct. If the name is correct, declare the object. File: /job/student/hdl/rv32i_types.sv Line: 11
Error: Quartus Prime Analysis & Synthesis was unsuccessful. 5 errors, 3 warnings
    Error: Peak virtual memory: 987 megabytes
    Error: Processing ended: Wed Mar 30 14:56:08 2022
    Error: Elapsed time: 00:00:11
    Error: Total CPU time (on all processors): 00:00:17

```

</details>


### Targeted Tests: 
<ul>
<li> <b>cp1</b> <img src="https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Ambox_warning_yellow.svg/40px-Ambox_warning_yellow.svg.png" alt="error" width="13" height="13" ></img><details>
<summary>Error Occurred</summary>

```
An error occured when running this test.
If your code did not successfully compile, that is likely the reason.
If your code did compile, then please reach out to a TA on Piazza
```

</details>
</li>

---
Staff use: 62446f3ba82c945fb6fb61d4

[success]: https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Green_check.svg/13px-Green_check.svg.png 
[failure]: https://upload.wikimedia.org/wikipedia/en/thumb/b/ba/Red_x.svg/13px-Red_x.svg.png 
