## LEAVES MOVING ON THE FLOOR
#### Processing App using Kinect (v1 or v2)

[Project on Github](https://github.com/Hemisphere-Project/Leaves)


Requires the P5 libraries:

- [Open Kinect for Processing](https://github.com/shiffman/OpenKinect-for-Processing)
- [BlobDetection](http://www.v3ga.net/processing/BlobDetection/)
- [punktiert](https://github.com/djrkohler/punktiert)

### Notes
When exporting an app with java embedded, duplicate the 'img' folder inside the 'application.windows64' folder.

## KINECT 1 Windows
Install OpenKinect on windows:
https://github.com/OpenKinect/libfreenect/#windows

## KINECT 2 Windows
Install libfreenect2 on windows:
https://github.com/OpenKinect/libfreenect2/blob/master/README.md#windows--visual-studio
-  **Install libusbK driver** not UsbDk
- Install Visual Studio Community 2017 with option "Desktop development with C++"
- Open Git Shell
  - cd Desktop && git clone https://github.com/OpenKinect/libfreenect2.git
- Open File explorer > Desktop > libfreenect2 > depends
- Start install_libusb_vs2015.cmd and press enter
- Enter newly created libusb_src directory > msvc
- Open libusb_dll_2017.vcxproj
- Righ click on solution > Re-target (Recibler)
- Choose Release x64 > Build (Windows Debugger)


Inspired from https://github.com/Bilue/BilueKinectInteraction
