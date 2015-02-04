### IMPORTS ###
# core
fs = require "fs"
path = require "path"

# atom
{$} = require "atom-space-pen-views"

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
        if atom.project.getPaths()[0]
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
        atom.commands.add "atom-workspace",
            # Notepad Core Actions
            "notebook:new-notepad": -> @notepads.new()
            "notebook:open-notepads": -> @notepads.open()
            "notebook:close-notepads": -> @notepads.close()
            "notebook:delete-notepad": -> @notepads.delete()
            "notebook:purge-notepads": -> @notepads.purge()

            # Notepad Convenience Actions
            "notebook:save-to-project": -> @notepads.saveToProject()

        # Setup event handlers
        $( window ).on "ready", =>
            console.log document.querySelector( "status-bar" )
            # Attach the event handle for the editor/buffer changes to render notepad paths
            document.querySelector( "status-bar" )?.on "active-buffer-changed", -> @notepads.activatePathUpdater()

    ### DEACTIVATE ###
    deactivate: ->
        # Destroy the notepads object at this point
        @notepads = null

    ### SERIALIZE ###
    serialize: ->