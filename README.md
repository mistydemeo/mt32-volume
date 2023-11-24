# Commandline MT-32 Volume Control

This is a simple commandline utility for macOS which allows setting the volume for a connected MT-32 using CoreMIDI.

I wrote this for myself, so it currently hardcodes the MIDI device to use. If you'd like to use this yourself, you'll probably need to change the hardcoded MIDI device in the source, or submit a pull request to un-hardcode it.

## Usage

## Installation

Ensure Xcode or the Command Line Tools for Xcode are installed. To build, just run:

* `make`

That's it! This will produce a binary named `mt32-volume`, which can be placed anywhere.

## System requirements

macOS; should be compatible with even very old OS revisions.
