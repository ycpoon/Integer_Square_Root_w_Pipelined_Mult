# Integer Square Root & Multiplication IP

This repo implements the integer square root (ISR) IP that uses the pipelined multpication IP implemented. This IP provides an efficient method and algorithm in computing the integer square root of a 64-bit number.

The multiplication IP is a pipelined IP that utilizes pipelining to reduce critical path in 64-bit multiplication.

## Testing
- "isr_test.sv" - Comprehensive testing of ISR module
- "mult_test.sv" - Comprehensive testing of the pipelined multiplication IP

## Next Steps
- Make the isr module parameterizable