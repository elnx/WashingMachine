# WashingMachine

A FPGA implement of a washing machine written in Verilog HDL for my EE lab.

This project is correctly run in my lab. 

## Notes
- This is the whole project folder created by Quartus II 13.0 (64-bit) Web Edition.
- The code architecture is not very appropriate: the top module should be a new module to control the FSM, timer, etc.
- You can find this EE lab requirements [here](http://jpkc.fudan.edu.cn/picture/article/239/3b/4f/366c2032433cb26d64a588021279/f372c64a-7a69-47a2-967a-5ab340428ce6.pdf). 
- There are several xtra functions: decimal point twinkle in `ALERT` state, speed up 10 times. 

## Details
- `washingmachine_top.v` is the top-level module, including the `FSM` function.
- `timer.v` outputs the decimal time from the start.
- `get_time.v` converts the decimal time to a `minute:second:extra_second` style time.
- `display_time.v` show the time on FPGA board.

## TODO
- Redesign the code architecture to create a new top-level module and a individual FSM module.
