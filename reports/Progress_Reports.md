# Checkpoint 0

## Progress Report
We finished a draft of our Out-of-Order design. Each of us made our own 
design and then combined them together. We are not sure if this design
works, and we are hoping to get feedback on our design from our mentor.

## Roadmap
For checkpoint 1, we hope to make any design changes that our mentor 
provides during our initial meeting and create several modules to lessen the
workload later on. We hope to, at minimum, finish designing and verifying
the instruction queue. In addition, we would like to design and verify the
regfile, ALU, and comparator modules - these will likely be very similar
if not identical to the modules provided in MP2. If there is additional
time, we would like to finish the other queues/buffers (ROB, load/store
queue, etc).

# Checkpoint 1

## Progress Report
For this checkpoint, we imported most of the files from MP2 that did not 
need modifications, such as the register, PC register, the ALU, and CMP 
modules. We implemented and verified the regfile and instruction queue and 
made initial progress on instantiating a reservation station for both the ALU and the CMP. 

## Roadmap
For the next checkpoint, we need to unify the modules we created in Checkpoint 1. We also need to implement and verify the other modules required for checkpoint 1, which are the reservation stations, load/store buffer, reorder buffer, and decoder. We need to make sure all instructions work. Like the previous checkpoint, implementation and debug will mostly be done through pair progrmamming.
