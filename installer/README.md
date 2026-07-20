# SlideShow Installer

This folder contains the Inno Setup based installer for the SlideShow app.

## Build

Run `Build-Installer.cmd` or `Build-Installer.ps1`.

## Output

- The installer publishes a self-contained `win-x64` build.
- The setup file is generated under `output\`.
- The app is installed under `%LOCALAPPDATA%\Programs\SlideShow`.
- A Start Menu shortcut is created for the current user.