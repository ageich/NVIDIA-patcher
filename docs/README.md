# **Does not work anymore due to [certificate blocking](https://msrc.microsoft.com/update-guide/vulnerability/ADV230001)**

# NVIDIA patcher

Adds 3D acceleration support for P106-090 / P106-100 / P104-100 / P104-101 / P102-100 / CMP 30X / CMP 40X / CMP 50X mining cards.

## Usage
1. Unpack driver distributive (xxx.xx-desktop-win10-win11-64bit-international-dch-whql.exe). Only 417.35+ driver needs to be patched! If you are using version 417.23 or older, go straight to step 5.
2. Place [all patcher files](https://github.com/dartraiden/NVIDIA-patcher/archive/refs/heads/old_patcher.zip) next to setup.exe.
3. Ensure your system partition has at least 8GB of free space and PC is connected to the Internet.
4. Make sure that port 80 is free on your system and no program is occupying it.
5. Run Patch.bat as admin.

**Attention, do not apply the NVENC patch if you are not sure of success. If your card does not have hardware NVENC support, the patch will cause problems (crashes) in applications using NVENC**

The result of the patch will be a signed `/Display.Driver/nv_disp.cat` file. Check the signature in its properties, it should be valid:

![Valid signature](/docs/signature.jpg)

6. Download [Display Driver Uninstaller](https://www.wagnardsoft.com/display-driver-uninstaller-ddu-) (DDU).
7. Unplug the network cable / disable Wi-Fi on your PC and clean the installed NVIDIA driver with DDU. Reboot PC.
8. Install the driver manually. Go to Windows Device Manager → Right-click on device → Properties → Driver → Update Driver → Browse my computer for drivers → Let me pick from a list of available drivers on my computer → Show All Devices → Have Disk... → Browse... → Choose `nvdispig.inf` (inside Display.Driver folder)  → Untick "Show compatible hardware" → Choose appropriate 3D video card model. Do not choose mining card models, choose 3D cards!
* P102-100 → GTX 1080 Ti
* P104-100 → GTX 1070
* P104-101 → GTX 1080
* P106-090 → GTX 1060 3GB
* P106-100 → GTX 1060 6GB
* CMP 30X → GTX 1660 Ti
* CMP 40X → RTX 2070 Super
* CMP 50X → RTX 2070 Super

Result:

![Screenshot of GPU-Z window](/docs/gpu-z.png)

Now you can plug the network cable / enable Wi-Fi back.

## SLI hack
If the patcher detects driver version 446.14, it will enable the [ability to pair together different GPUs](https://www.techpowerup.com/forums/threads/sli-with-different-cards.158907/) of similar generation/architecture to work together in SLI (Note: Mixing different VRAM sizes may cause some instability or stop SLI from functioning properly). It can also enable SLI on some non SLI/Crossfire compatible motherboards, making it a replacement for the now discontinued HyperSLI program (Note: The SLI support on non multi-GPU motherboards is not guaranteed).

Mandatory requirements:
* Driver version 446.14 (exactly this version)
* The first three symbols of Device ID for both cards must match. Go to Windows Device Manager → Right-click on device → Properties → Switch to the "Details" tab →  Select "Hardware IDs" from the combo box.

As an example:  
NVIDIA_DEV.**118**5.098A.10DE = "NVIDIA GeForce GTX 660"  
NVIDIA_DEV.**118**5.106F.10DE = "NVIDIA GeForce GTX 760"

Thus, for example, GTX 1070 and GTX 1080 can work together, but GTX 960 and GTX 1060 cannot.
