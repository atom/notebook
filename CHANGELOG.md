## Changelog

### v0.2.0

An update release with some internal modifications & notepad handling:

- Better handling of `Open Notepads` & `New Notepad` commands to make sure it doesn't open too many empty notepads unnecessarily

- Empty notepads are cleaned up automatically now on `Open Notepads` or `Close Notepads` being called. A notepad is deemed to be empty if it has 0 length or if it has no non-whitespace characters in it.

### v0.1.1

Bug fix release to handle package activation when no active project is opened. It now catches this and returns back an error object, so that atom silently fails activating the package.

### v0.1.0

First release as a separate package after split from [Protons](https://atom.io/packages/protons) which will be deprecated soon in favor of individual packages.