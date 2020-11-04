# VRRTest
A very small utility I wrote to test variable refresh rate on Linux. Should work on all major OSes.

## Usage
Just run the executable. Builds are provided for Windows and Linux (64-bit). You can download the LÖVE [https://love2d.org] runtime to run the .love file on any supported OS on any supported architecture.  
Assuming the runtime is installed and in PATH, you can run it with `love <dir>`, where `<dir>` is the directory where this repo is cloned/extracted.  
* Up and down arrows will change the target FPS of the tool.  
* `Ctrl+f`  toggles fullscreen.
* `b` toggles busy waiting. Having it on makes the framerate more precise, at the cost of a ton of battery and CPU utilization. Off by default.  
* `s` toggles VSync.  
* `f` toggles fluctuating framerate; `Ctrl+↑/↓` changes the maximum framerate, `Ctrl+←/→` changes the fluctuation speed.  
* `r` toggles random stutter; `Alt+↑/↓` changes the amount of stuttering. Hold Shift as well to change faster.
* `Alt+←/→` changes the monitor the tool will be displayed on.
* Number keys will select a scene to be displayed. Each scene has additional controls, shown on the right.

## Scenes
As of version 2.0.0, VRRTest supports different scenes, of which there are currently two. (A 100% increase over previous versions!)

### Bars
The first and default scene, Bars, is easy on the eyes (I'm not claiming it looks good; you'll see what I mean in the screenshots section) and easily allows the user to detect screen tearing, by displaying vertical bars moving towards the right. The number and speed of said bars are tunable by the user.
Additional controls are as follows:
* Left and right arrows will change the speed of the columns moving across the screen.  
* `+` and `-` will change the amount of columns.

### Squares
The second scene, Squares, adopts a higher-contrast color scheme (pure white on pure black) due to one of its functions. It displays a grid of squares, lighting up one (or more; see further) square per frame, each frame switching to the next one. The size of the squares can be changed by the user.
Optionally, a trail can be set to light up more than one square per frame (or to have squares stay lit up for more than one frame; the end result is the same) to achieve two different functions:
* Having no trail and a very high contrast allows the user to easily take a video, to later check frame-by-frame, or a long-exposure picture (assuming your phone or camera can do it) to check for duplicate or dropped frames. The maximum exposure length is the tool's period, which is displayed on the top-right. Examples of long-exposure pictures will be provided in the Screenshots section, even though they aren't screenshots. Guess I might just call it "Screenshots and pictures".
* Having a trail might be useful if you need or want to check the latency difference of two mirrored monitors (or any other way to mirror a monitor, such as [Looking Glass](https://looking-glass.io) if, like me, you're one of those VFIO people), taking a picture of this tool running on the mirrored monitors with a trail makes counting the difference in frames easier, by just counting how many squares ahead (or behind) each output is. Not sure why that is, though; it might just be me.

Additional controls are as follows:
* Left and right arrows will decrease or increase the trail length.
* `+` and `-` will increase or decrease, respectively, the size of the squares.

## Screenshots and pictures
Some of these can't be screenshots. I apologize in advance for the quality of the pictures I took, as I don't own a camera or a tripod, both of which would prove useful in taking long-exposure pictures.
### Scene 1 - Bars
![Scene 1 screenshot without tearing](https://nixo.la/img/vrrtest_scene1.png)
*How the Bars scene is supposed to look like, without any screen tearing. Ignore the visible portion of the cursor, please.*  


![Scene 1 screenshot with tearing](https://nixo.la/img/vrrtest_scene1_tearing.png)
*A screenshot of how the scene looks like with screen tearing.*  


### Scene 2 - Squares
![Scene 2 screenshot](https://nixo.la/img/vrrtest_scene2.png)
*How a still frame of the Squares scene looks like. Its usefulness can't easily be conveyed by still screenshots.*  


![Scene 2 low framerate without VRR](https://nixo.la/img/vrrtest_scene2_novrr_low.png)
*Long-exposure picture of a monitor with Freesync disabled with lower framerate than its refresh frequency. Notice how some squares are brighter than others, caused by duplicated frames.*  


![Scene 2 high framerate without VRR](https://nixo.la/img/vrrtest_scene2_novrr_high.png)
*Long-exposure picture of a monitor with Freesync disabled with higher framerate than its refresh frequency. The empty squared are caused by dropped frames. Note that this might happen on a Freesync monitor too, when above its frequency range.*  


![Scene 2 low framerate with VRR](https://nixo.la/img/vrrtest_scene2_vrr_low.png)
*Finally, a long-exposure picture of a Freesync monitor with refresh rate within its range. Everything looks like it should, with every lit square being approximately the same as the others.*  


![Scene 2 high framerate with VRR](https://nixo.la/img/vrrtest_scene2_vrr_high.png)
*Long-exposure picture of a Freesync monitor with higher framerate than its maximum refresh frequency. VRR can't do much in this case; either limit your framerate to below your monitor maximum refresh frequency or enable V-Sync in your software and/or driver.*
