# GDB Initialization for XuanTie/T-Head
set architecture riscv:rv32

# Connect to the Docker container
target remote localhost:1234

# Reset and Halt the target via DebugServer
monitor reset
monitor halt

# Load the current binary
load

# Optional: Stop at main
# break main
