# Contail ScreenSaver

Contail is a ScreenSaver for OS X that follows a text/log file of your choice. If you're interested in what's going on with your machine, even while a ScreenSaver is running, this is for you (and the reason that opendirectoryd.log is the default log file).

I've written and tested this on 10.7, and it's unlikely to work on anything earlier (due to the use of CoreText and my default choice of opendirectoryd.log).

Not into compiling source on your own? Download the compiled binary in a DMG here: https://github.com/downloads/marczak/contail/


Licensed under the Apache 2.0 license. Please see the LICENSE file for details.

# ToDo
- Error checking.
- Allow choice of "System Log".
- Font picker.

# Known Issues
- None.

# Acknowledgements
I'm using the "Apple2Forever" font from http://www.thugdome.com/software_a2f.html

# Change History
v 1.2 - 2012-05-30
- Stop arbitrarily removing the oldest line.
- Add more debug info.

v 1.1 - 2012-04-02
- Initial non-crashy version for release.

v 1.0 - Unreleased proof of concept.