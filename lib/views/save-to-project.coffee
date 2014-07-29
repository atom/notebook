### IMPORTS ###
# core
path = require "path"
fs = require "fs"

# atom
{View, EditorView} = require 'atom'

### EXPORTS ###
module.exports =
    class SaveToProjectView extends View
        ### CONTENT ###
        @content: ->
            # Setup the wrapper
            @div class: "notebook overlay from-top", =>
                # Setup the container element
                @div class: "dialog save-to-project", =>
                    # Header
                    @div class: "header", =>
                        @h3 "Save To Project"

                    # Content
                    @div class: "content", =>
                        # Notes
                        @div class: "notes info", =>
                            # Header
                            @h5 outlet: "notesHeader", ""

                            # Content
                            @p outlet: "notesContent", ""

                        # Form
                        @div class: "form", =>
                            # Field
                            @div class: "field", =>
                                # Label
                                @label for: "savePath", "Enter path to save notepad as (relative to project root)"
                                # Control
                                @subview "savePath", new EditorView( mini: true )

                                # Error
                                @span outlet: "saveError", class: "error-message", ""

        ### CONSTRUCTOR ###
        constructor: ( notepadFilePath ) ->
            # Setup the notepad file path for later usage
            @notepadToSaveFilePath = notepadFilePath

            # Call the super
            super

        ### INITIALIZE ###
        initialize: ->
            # Setup the notice message based on current configuration
            deleteOnSaveToProject = atom.config.get( "notebook.removeNotepadOnSavingToProject" )

            # Check if it is true
            if deleteOnSaveToProject is true
                # Set the content appropriately
                @notesHeader.text( "This notepad will be deleted after saving to project" )
                @notesContent.text( "If you would like to keep the notepad, disable 'Remove Notepad On Saving To Project' in the package settings" )
            else
                # Set the content appropriately
                @notesHeader.text( "This notepad will NOT be deleted after saving to project" )
                @notesContent.text( "If you would like to delete it after save, enable 'Remove Notepad On Saving To Project' in the package settings" )

            # Setup the confirm & cancel event handlers
            @on "core:confirm", => @save( @savePath.getText() )
            @on "core:cancel", => @close()

            # If the focus is lost from the save path field, assume cancel
            @savePath.hiddenInput.on "focusout", => @remove()
            @savePath.getEditor().getBuffer().on "changed", => @error()

        ### ATTACH ###
        attach: ->
            # Append the view to the workspace now
            atom.workspaceView.append( this )

            # Give focus to the path entry field
            @savePath.focus()
            @savePath.scrollToCursorPosition()

        ### CLOSE ###
        close: ->
            # Remove the view now
            @remove()

            # Return back focus to the workspace
            atom.workspaceView.focus()

        ### SAVE ###
        save: ( relativePathToSave ) ->
            # Create the regular expressions for path testing
            startRegExp = new RegExp( "^" + path.sep )
            endRegExp = new RegExp( path.sep + "$" )

            # Test for file ending with directory separator
            startsWithDirectorySeparator = startRegExp.test( relativePathToSave )
            endsWithDirectorySeparator = endRegExp.test( relativePathToSave )

            # If the path starts with directory separator, remove the starting separator
            if startsWithDirectorySeparator
                # Create the new relative path
                relativePathToSave = relativePathToSave.replace( path.sep, "" )

            # Relativize the path from project root
            filePathToCreate = atom.project.resolve( relativePathToSave )

            # See if we can get a valid relative path within project
            return unless filePathToCreate

            # Wrap the FS to catch any errors
            try
                # Check if there already exists a file at the path
                if fs.existsSync( filePathToCreate )
                    # Path already exists, cannot/do not overwrite
                    @error( "'#{filePathToCreate}' already exists" )
                else
                    # Verify the slash at end is not present
                    if endsWithDirectorySeparator
                        # Throw error
                        @error( "File names must not end with a '#{path.sep}' character" )
                    else
                        console.log "Will create the file #{filePathToCreate}"
                        console.log "Source notepad file is #{@notepadToSaveFilePath}"
                        # We seem to be fine now, let us go ahead and try creating the file
                        fs.writeFileSync( filePathToCreate, fs.readFileSync( @notepadToSaveFilePath ) )

                        # Open up the newly saved file
                        atom.project.open( filePathToCreate ).then ( newProjectFileEditor ) =>
                            console.log "Opened new project file: #{newProjectFileEditor.getPath()}"

                            # Activate the new project file
                            atom.workspace.getActivePane().activateItem( newProjectFileEditor )

                            # Setup the notice message based on current configuration
                            deleteOnSaveToProject = atom.config.get( "notebook.removeNotepadOnSavingToProject" )

                            # Check if it is true
                            if deleteOnSaveToProject is true
                                # We need to remove the notepad which we just saved to project
                                # First let us close out the open notepad in the workspace
                                # Get the current open editors
                                currentEditors = atom.workspace.getEditors()

                                # Find all the open editors and see if they match the saved notepad
                                # If they match, close out that editor
                                # Loop through the editors
                                for currentEditor in currentEditors
                                    # Check if paths match
                                    if currentEditor.getPath() is @notepadToSaveFilePath
                                        console.log "Closing out the notepad now: #{@notepadToSaveFilePath}"
                                        # Close the item in the pane
                                        atom.workspace.getActivePane().destroyItem( currentEditor )

                                # Destroy the notepad now completely
                                fs.unlinkSync @notepadToSaveFilePath
                                console.log "Removed notepad file: #{@notepadToSaveFilePath}"

                            # Close out the save to project view
                            @close()
            catch createError
                # Display any error messages we might have gotten
                @error( "#{createError.message}" )

        ### ERROR ###
        error: ( message = '' ) ->
            # Set the error message
            @saveError.text( message )

            # Flash
            @flashError() if message