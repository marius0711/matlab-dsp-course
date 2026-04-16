# Setup Guide

## Install GNU Octave

### macOS (Homebrew)
```bash
brew install octave
```
Then inside Octave:
```octave
pkg install -forge signal
pkg install -forge control
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install octave octave-signal octave-control
```

### Windows
Download from https://octave.org/download. Then in Octave:
```octave
pkg install -forge signal
pkg install -forge control
```

## Verify Installation
```octave
pkg load signal
pkg load control
disp('All packages loaded. Ready.')
```

## Running the Course Scripts
```bash
cd project
octave generate_signal.m   # always run this first

cd ../01_basics
octave demo_basics.m
```

## MATLAB Users
All scripts are compatible with MATLAB.
Replace `pkg load signal` with nothing — toolboxes load automatically.
