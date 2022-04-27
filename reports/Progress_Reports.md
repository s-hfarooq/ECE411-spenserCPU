# Checkpoint 0

## Progress Report
We finished a draft of our Out-of-Order design. Each of us made our own  design and then combined them together. We are not sure if this design works, and we are hoping to get feedback on our design from our mentor.

## Roadmap
For checkpoint 1, we hope to make any design changes that our mentor  provides during our initial meeting and create several modules to lessen the workload later on. We hope to, at minimum, finish designing and verifying the instruction queue. In addition, we would like to design and verify the regfile, ALU, and comparator modules - these will likely be very similar if not identical to the modules provided in MP2. If there is additional time, we would like to finish the other queues/buffers (ROB, load/store queue, etc).


# Checkpoint 1

## Progress Report
For this checkpoint, we imported most of the files from MP2 that did not  need modifications, such as the register, PC register, the ALU, and CMP modules. We implemented and verified the regfile and instruction queue and made initial progress on instantiating a reservation station for both the ALU and the CMP. 

## Roadmap
For the next checkpoint, we need to unify the modules we created in Checkpoint 1. We also need to implement and verify the other modules required for checkpoint 1, which are the reservation stations, load/store buffer, reorder buffer, and decoder. We need to make sure all instructions work. Like the previous checkpoint, implementation and debug will mostly be done through pair programming.


# Checkpoint 2

## Progress Report
For checkpoint 2, we implemented the ROB, reservation stations, load store buffer, decoder, and instruction fetch as well as linking all these modules together. We wrote a few more testbenches for some of our modules like the RS and ran our code through modelsim in order to aid in debugging. 

## Roadmap
For checkpoint 3, we will need to add L1 caches and implement the arbiter and branch predictor we designed for checkpoint 2. We will likely also be editing the given cache code for better performance. Additionally, we'll decide if we want to implement any additional advanced features. Again, like the previous checkpoint, implementation and debug will mostly be done through pair programming.


# Checkpoint 3

## Progress Report
For checkpoint 3, we continued to debug our previous weeks code in order to be able to properly run the CP1 testcode. We also added in caches and our arbiter and had to fix additional bugs in order to make these work properly. CP1 testcode now works as intended, but we are still having issues with CP2 testcode. We have yet to try CP3 or competition testcode.

## Roadmap
For checkpoint 4, we will be fixing the bugs to ensure CP2, CP3, and all competition testcode run as expected. If we have time we will work on creating a better branch predictor (likely 2-bit) and implement a better cache than the working one we were provided with. 
