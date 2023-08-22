# Signal-Generator-on-8051
Upon start or reset of the microcontroller, you will enter a three-digit number N in
the range [001,100] (i.e., N={001,002,003, …, 100}). Then the frequency of a square
waveform (Waveform#1) must be set as f = N Hz. The LCD will display "f = f Hz" on the first
line. Next, you will enter a two-digit number from the set D = {20, 30, 40, 50, 60, 70, 80}. D
will be the duty cycle of the square wave. The LCD will display "D = D %" at the next line.
Also, you will use another free pin to generate another square* waveform (Waveform#2).
This second waveform’s frequency should be triple the entered frequency f (saturate it at
255 Hz if 3f > 255), and its duty cycle D should be half of the entered duty cycle. Generate
these waveforms at available port pins. You will use Digital Virtual Oscilloscope in Proteus1
to monitor your waveforms.In addition, display the state of the wave using a blinking LED2 (simultaneously
with the waveforms on the virtual oscilloscope). The frequency and duty cycle of the
blinking should resemble Waveform#1. The duty cycles of the LED and the waveform must
be equal. Use 1/20 of the frequency of the generated square wave Waveform#1(i.e., f/20)
as the frequency of the blinking.
