## Changelog

### v0.4.0

New "Save To Project" feature

- "Save To Project" feature allows for the currently open notepad file to be quickly saved as part of project files

### v0.3.2

Bug fix release to handle scenarios where there is no active pane item for notepad path handling

### v0.3.1

Minor fix for better handling for status bar notepad paths based on current active pane item.

### v0.3.0

Package now has configurable settings for a couple of features, as well as some performance tuning.

- Allow configuring auto-save for notepads

- Allow configuring automatic removal of empty notepads

- Hook to `content-modified` event of the notepad editor if auto-save is enabled rather than the `changed` event of the underlying buffer

### v0.2.0

An update release with some internal modifications & notepad handling:

- Better handling of `Open Notepads` & `New Notepad` commands to make sure it doesn't open too many empty notepads unnecessarily

- Empty notepads are cleaned up automatically now on `Open Notepads` or `Close Notepads` being called. A notepad is deemed to be empty if it has 0 length or if it has no non-whitespace characters in it.

### v0.1.1

Bug fix release to handle package activation when no active project is opened. It now catches this and returns back an error object, so that atom silently fails activating the package.

### v0.1.0

First release as a separate package after split from [Protons](https://atom.io/packages/protons) which will be deprecated soon in favor of individual packages.