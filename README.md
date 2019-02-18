# VRRTest
A very small utility I wrote to test variable refresh rate on Linux. Should work on all major OSes.

## Usage
Just run the executable. Builds are provided for Windows and Linux (64-bit). You can download the LÖVE [https://love2d.org] runtime to run the .love file on any supported OS on any supported architecture.  
Assuming the runtime is installed and in PATH, you can run it with `love <dir>`, where `<dir>` is the directory where this repo is cloned/extracted.  
* Up and down arrows will change the target FPS of the tool.  
* Left and right arrows will change the amount of columns the screen is divided into.  
* The f key toggles fullscreen.  
* The b key toggles busy waiting. Having it on makes the framerate more precise, at the cost of a ton of battery and CPU utilization. Off by default.  

## Screenshots
I don't know why'd you want any. Still, here's one.  
![Main and only screen of the tool](https://static.nixo.la/i/1550422559.png)
