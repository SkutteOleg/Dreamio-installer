# DREAMIO: AI-Powered Adventures - Installer

### This is the installer for [DREAMIO: AI-Powered Adventures](https://dreamio.xyz)

## About

This repository contains the NSIS (Nullsoft Scriptable Install System) script for building the DREAMIO: AI-Powered Adventures installer. The installer is automatically built and released whenever changes are pushed to the `master` branch.

## Latest Release

You can find the latest release of the DREAMIO installer [here](https://github.com/SkutteOleg/Dreamio-installer/releases/latest).

## SHA256 Verification

Each release includes a SHA256 hash in the release notes. You can use this to verify the integrity of the downloaded installer.

## Manual Build Instructions

To manually build the DREAMIO installer, follow these steps:

1. Install NSIS (Nullsoft Scriptable Install System) on your Windows machine.

2. Install the required NSIS plugins:
    - ZipDLL
    - Inetc
    - NsJSON
    - NSISunzU

   You can download these plugins from the NSIS website or use the URLs provided in the YAML file.

3. Place the plugin files in the appropriate NSIS directories:
    - `.dll` files go in the `Plugins` directory
    - `.nsh` files go in the `Include` directory

4. Open a command prompt and navigate to the directory containing the `script.nsi` file.

5. Run the following command to build the installer:
   ```
   makensis.exe /V4 /X"SetCompressor /FINAL /SOLID lzma" /X"SetCompressorDictSize 64" /X"SetDatablockOptimize ON" script.nsi
   ```

6. After successful compilation, you should find `DreamioInstaller.exe` in the same directory.

7. (Optional) Calculate the SHA256 hash of the installer:
   ```
   certutil -hashfile DreamioInstaller.exe SHA256
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.