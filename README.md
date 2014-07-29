# Notebook

Notebook offers you a hassle free way to open up editor windows for note taking/rough usage or saving content for later usage/reference as notepads.

It stores your content separately from your workspace/project so there is no need to worry about extra files cluttering up your workspace/project folders.

![Notepad](https://github.com/skulled/notebook/raw/master/docs/assets/images/notepad.png)

![Notepad - Save To Project](https://github.com/skulled/notebook/raw/master/docs/assets/images/notepad-save-to-project.png)

> _Although every effort is made to keep things as stable as possible, please do note that the package is under constant development so there might be occasional bugs. If you run across any issues, please [add an issue](https://github.com/skulled/notebook/issues/new) with the details._

## Installation

### Command Line

```bash
apm install notebook
```

### Atom

```
Command Palette ➔ Settings View: Install Packages ➔ Notebook
```

## Features

Notepads are stored separately away from your project/workspace files, so there is no issue of having to worry about extra files being around where they are not required.

You can create as many notepads as you want, the sky is the limit. Knock yourself out!

A notepad gets persisted only after there has been a content change for the first time, with subsequent updates saving it.

### Current Features

- [x] Create as many notepads as you want easily [if you have a large number, the `Open Notepads` command will open all of them!]
- [x] Notepads are all directly associated with a single project/workspace, and all actions from a particular project window will only affect its own notepads
- [x] Notepads are stored separately away from the project/workspace files, so that they don't interfere
- [x] Configurable settings for auto-save & automatic removal of empty notepads
- [x] Notepads are auto-saved (if enabled) on content change, so there is no need for manual saves or fear of losing content
- [x] Get confirmation before `Delete Notepad` & `Purge Notepads` to avoid accidental loss of notepads
- [x] Empty notepads<sup>[1]</sup> are now handled efficiently and removed silently (if enabled) to keep the notepads storage uncluttered, and number of files minimal as possible. On issuing, either `Open Notepads` or `Close Notepads`, if a notepad is found to be empty, it is deleted and no longer kept around (No worries, you can always get a new notepad with `New Notepad`)
- [x] Allows for a convenient way to save currently open notepad to the project as part of the project files via the `Save Notepad to Project` command

_[1] - A notepad is considered empty if it has zero content length, or if it has no non-whitespace characters in it_

## Commands

**_New Notepad_**

```
ctrl-cmd-n
```

> Opens a new notepad editor

**_Open Notepads_**

```
ctrl-cmd-o
```

> Opens all saved notepads for the current workspace which are not empty (if automatic removal is enabled). If automatic removal is disabled, it will open empty notepads as well

**_Close Notepads_**

```
ctrl-cmd-x
```

> Close all open notepads in the workspace, and deletes empty notepads (if automatic removal is enabled)

**_Delete Notepad_**

```
ctrl-cmd-r
```

> If the current editor in focus is a notepad, it will close it and delete it permanently
>
> **_Action is permanent and the contents of the notepad will be lost forever!_**

**_Purge Notepads_**

```
ctrl-cmd-z
```

> Closes any open notepads, and completely deletes all saved notepads for the current workspace
>
> **_Action is permanent and all the notepads will be lost forever!_**

**_Save Notepad to Project_**

```
ctrl-cmd-s
```

> Quickly save the current open notepad in to the project as part of the project files
>
> **_If the current active item/editor is not a notepad, nothing happens_**

## Feedback & Issues

Any feedback is appreciated!

There are a number of features that are under development, but if there are specific features you would like to see added, please [add an issue](https://github.com/skulled/notebook/issues/new) and tag it as "feature".

If you encounter any bugs or cannot get something working, please check the current [open issues](https://github.com/skulled/notebook/issues) to see if it has already been raised, before adding a new issue with the problem you are facing.