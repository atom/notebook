### IMPORTS ###
# core
fs = require "fs"
path = require "path"

# atom
{$} = require "atom"

# notebook
Notepads = require "./notepads.coffee"

### EXPORTS ###
module.exports =
    ### CONFIGURATION ###
    configDefaults:
        # Auto Save - default to true, good to have it this way
        autosaveEnabled: true
        # Auto Remove Empty Notepads - default to true, don't bother keeping empty files around
        removeEmptyNotepadsAutomatically: true
        # Remove notepads which are saved to project - default to false, notepad still remains
        removeNotepadOnSavingToProject: false

    ### ATTRIBUTES ###
    notepads: null

    ### DEACTIVATE ###
    activate: ( state ) ->
        # We only want to activate the package if there is a valid project
        # Not handling atom being loaded without a project at this point - TODO
        if atom.project.getPath()
            # Setup the Notepads object
            @notepads = new Notepads()

            # Call initialize to setup commands & event handlers
            @initialize()
        else
            # Throw an error for the benefit of package manager activePackage
            throw { stack: "- Notebook is active & functional only with a valid project open" }

    ### INITIALIZE ###
    initialize: ->
        # Setup the commands
        # Notepad Core Actions
        atom.workspaceView.command "notebook:new-notepad", => @notepads.new()
        atom.workspaceView.command "notebook:open-notepads", => @notepads.open()
        atom.workspaceView.command "notebook:close-notepads", => @notepads.close()
        atom.workspaceView.command "notebook:delete-notepad", => @notepads.delete()
        atom.workspaceView.command "notebook:purge-notepads", => @notepads.purge()

        # Notepad Convenience Actions
        atom.workspaceView.command "notebook:save-to-project", => @notepads.saveToProject()

        # Setup event handlers
        $( window ).on "ready", =>
            # Attach the event handle for the editor/buffer changes to render notepad paths
            atom.workspaceView.statusBar?.on "active-buffer-changed", => @notepads.activatePathUpdater()

    ### DEACTIVATE ###
    deactivate: ->
        # Destroy the notepads object at this point
        @notepads = null

    ### SERIALIZE ###
    serialize: ->