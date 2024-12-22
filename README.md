<a id="readmeTop"></a>
<br />

<div align="center">
    <img src ="images/StartScreen.png" width="320" height = "240">
    <h3 align="center"> Pianissimo for the FPGA </h3>

  <p align="center">
        Play and Record Piano and Drums on an FPGA board!
        <br />
        <a href="#DEMO">View Demo</a>
    </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About Pianissimo
NOTE THAT THE MAJORITY OF FILES HAVE BEEN REMOVED UPON UNIVERSITY REQUEST
<p> If you wish to view the removed files, see <a href="#CONTACT> contact </a> </p>


Pianissimo is a piano and drum kit simulator designed for the DE1_SOC FPGA board. 
With an acompanying PS2 keyboard and external AUX connected speakers. Pianissimo allows its users to record a series of beats on the drum and have them automatically played back
while the the user plays the piano.

### Demo Video
<div id="DEMO"> </div>

[![Pianissimo Video](https://img.youtube.com/vi/Ba7wiB6z1n4/0.jpg)](https://youtu.be/Ba7wiB6z1n4)


<p align="right">(<a href="#readmeTop">back to top</a>)</p>

### Built With
<a href="https://www.chipverify.com/tutorials/verilog">
    <img src = "readmeFiles/verilog_logo.png" align="center" width="192" height="70">
</a>

<p align="right">(<a href="#readmeTop">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* Quartus Prime - You can download Quartus Prime lite from [This link!][Quartus-url]
* ModelSim - You can download modelSim for compiling and simulation from [This link!][ModelSim-url]

### Installation

_Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services._

1. Clone the repository to your local machine
   ```sh
   git clone https://github.com/RoZ4/Pianissimo241Final.git
   ```
2. Open the project in Quartus Prime
    1. Launch Quartus Prime
    2. Navigate to the top left of the screen
    3. Click File
    4. Click Open Project
    5. Select Pianissimo.qpf from your clones directory

3. Connect Speakers to the AUX port and a PS2 Keyboard to the PS2 port of the FPGA

4. Connect your FPGA board to your machine

5. Select Tools from the top center of the window and go to Programmer

6. If your FPGA is not connected beside "Hardware Setup" click "Hardware Setup" and select your device from the dropdown menu

7. Press "Start" from the main programmer window to program the FPGA board 


<p align="right">(<a href="#readmeTop">back to top</a>)</p>


<!-- USAGE -->
## Usage

* Press spacebar to start Pianissimo

* The keys "Tab" to "\" control the white keys of the piano
* The keys " ` " to "Backspace" control the black keys of the piano

* The keys "F" to "G" control the drum kit

<br />

### Recording

To record the drum kit, play the drums in the sequence you wish to record and press "Enter"

In the playback state, press the spacebar to return to the record state

<p align="right">(<a href="#readmeTop">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readmeTop">back to top</a>)</p>

<!-- CONTACT -->
<div id="CONTACT> </div>
## Contact

Robert Zupancic - [@LinkedIn](https://ca.linkedin.com/in/robert-zupancic)

Project Link: [https://github.com/RoZ4/Pianissimo241Final.git](https://github.com/RoZ4/Pianissimo241Final.git)

<p align="right">(<a href="#readmeTop">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

This project was created for the ECE241 course at the University of Toronto in Toronto, Canada. It was created in conjuction with [SophiaAlexanian](https://github.com/sophia-alexanian).

<p align="right">(<a href="#readmeTop">back to top</a>)</p>

[Quartus-url]: https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html
[ModelSim-url]: https://www.intel.com/content/www/us/en/software-kit/750368/modelsim-intel-fpgas-standard-edition-software-version-18-1.html
