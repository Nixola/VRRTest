# VRRTest
A very small utility I wrote to test variable refresh rate on Linux. Should work on all major OSes.

## Usage
Just run the executable. Builds are provided for Windows and Linux (64-bit). You can download the LÖVE [https://love2d.org] runtime to run the .love file on any supported OS on any supported architecture.  
Assuming the runtime is installed and in PATH, you can run it with `love <dir>`, where `<dir>` is the directory where this repo is cloned/extracted.  
* Up and down arrows will change the target FPS of the tool.  
* Left and right arrows will change the speed of the columns moving across the screen.  
* `+` and `-` will change the amount of columns.  
* `Ctrl+f`  toggles fullscreen.  
* `b` toggles busy waiting. Having it on makes the framerate more precise, at the cost of a ton of battery and CPU utilization. Off by default.  
* `s` toggles VSync.  
* `f` toggles fluctuating framerate; `Ctrl+↑/↓` changes the maximum framerate, `Ctrl+←/→` changes the fluctuation speed.  
* `r` toggles random stutter; `Alt+↑/↓` changes the amount of stuttering. Hold Shift as well to change faster.

## Screenshots
I don't know why'd you want any. Still, here's one.  
![Main and only screen of the tool](https://i.imgur.com/fiXD6ns.png)
