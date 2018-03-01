# MASM Analog Clock

## How to build

Please use [MASM 6.15](http://www2.hawaii.edu/~pager/312/masm%20615%20downloading.htm) to build.

## Runtime environment

The application is written for Intel 80286 real mode environment and depends on DOS interrupts. Therefore, it cannot be run directly on modern versions of Windows. An emulator, such as [DOSBox](https://www.dosbox.com/), is recommended.

## Description of code

### Program skeleton

- print the text
- skin:
- skin2:
- enovate:
- LOOP 
- enovate:
- LOOP
- back
- skin3:
- back
- CLk:
- back
- minute_lin:
- hour_lin:
- second_lin:
- msecond_lin:
- check keystroke
- display digital clock
- LOOP
- conditional quit

### Summary of procedures

##### b1002

Sets cursor to row 0 column 16

##### linex

Returns y = (y2-y1)\*(x-x1)/(x2-x1)+y1
Inputs: (x1,y1), (x2,y2), x
Calls: xymaxmin, subab, DIan

##### liney

Returns x = (x2-x1)\*(y-y1)/(y2-y1)+x1
Inputs: (x1,y1), (x2,y2), y
Calls: xymaxmin, subab, DIan

##### CLk

Gets time CH:CL:DH in Binary Coded Decimal (BCD) form using INT 1A Service 2

##### bcd2

Operates on BCDs
Input: DL
Output: AL

##### SIn

Computes the trigonometric function Sine
Input: AX
Output: AX

##### cos

Computes the trigonometric function Cosine
Input: AX
Output: AX

##### renovate

Calls: SIn, cos

##### sjx

Calls: xymaxmin, subab, sjxx, sjxy

##### sjxx

Calls: xymaxmin, subab, linex, liney

##### hour_lin

Calls: CLk, vcd2, renovate, sjx, sjxx, sjxy

##### Clear

Clears the screen by writing ' ' 6000 times using INT 10 Service 0AH

##### Subab

Finds |a-b|

##### xymaxmin

Used in linex, liney and many others

##### skin, skin2, skin3

These three functions draw the skeleton of the analog clock. Skin displays the hour numbers. Skin2 and skin3 draw the circle and the markings of the clock.

##### Hour_lin

Draws the hour needle
Calls: CLk, bcd2, sjx, renovate

##### Minute_lin
Draws the minute needle

##### Second_lin

Draws the second needle

##### MSecond_lin

Draws the millisecond needle

### Interrupts

Information about all the interrupts used in this program is available at [Ralf Brown’s Interrupt List](http://www.ctyme.com/intr/int.htm).

## Further information

For more information, please refer to [this blog post](https://nabeelsplace.wordpress.com/2014/02/24/assembly-clock/).
