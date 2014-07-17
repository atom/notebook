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
    ### ATTRIBUTES ###
    notepads: null

    ### DEACTIVATE ###
    activate: ( state ) ->
        # Setup the Notepads object
        @notepads = new Notepads()

        # Call initialize to setup commands & event handlers
        @initialize()

    ### INITIALIZE ###
    initialize: ->
        # Setup the commands
        atom.workspaceView.command "notebook:new-notepad", => @notepads.new()
        atom.workspaceView.command "notebook:open-notepads", => @notepads.open()
        atom.workspaceView.command "notebook:close-notepads", => @notepads.close()
        atom.workspaceView.command "notebook:delete-notepad", => @notepads.delete()
        atom.workspaceView.command "notebook:purge-notepads", => @notepads.purge()

        # Setup event handlers
        $( window ).on "ready", =>
            # Attach the event handle for the editor/buffer changes to render notepad paths
            atom.workspaceView.statusBar?.on "active-buffer-changed", => @notepads.updateDisplayPath()

    ### DEACTIVATE ###
    deactivate: ->
        # Destroy the notepads object at this point
        @notepads = null

    ### SERIALIZE ###
    serialize: ->