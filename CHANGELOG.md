## Changelog

### v0.1.1

Bug fix release to handle package activation when no active project is opened. It now catches this and returns back an error object, so that atom silently fails activating the package.

### v0.1.0

First release as a separate package after split from [Protons](https://atom.io/packages/protons) which will be deprecated soon in favor of individual packages.