# Pipelined MIPS CPU Verliog implementation
Collaboration with [Alex](https://github.com/spacemonkeydelivers).

## Description
This is an early release of the project - some parts of it still require some sanitization.

Pipelined processor, was designed to fit Xilinx Spartan-6.
Includes:
* All the default blocks (regfile/control/alu/memop/etc.)
* Additionally, implements RW cache

Does not include:
* Exception handling
* TLB

## Future work
Sanitize and release branch prediction experiments - we implemented various types of branch predictors, including saturating counters, 2-level predictors with PHT, g-share. Additionally, we experimented with neural-network-based branch predictor and actually achieved better results with the latter. We **did not** implement and compare TAGE though.

CPU lacks features that will make it able to boot MIPS-Linux, such as TLB and exception handling, which we'll need to implement.

Additionally, we would like to incorporate Wishbone Bus interface.

## License
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode)
