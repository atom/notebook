### IMPORTS ###
# core
fs = require "fs"
path = require "path"

### EXPORTS ###
module.exports =
    class Notepads
        ### ATTRIBUTES ###
        storagePath: null
        projectNotepadsPath: null
        currentProject: null

        ### CONSTRUCTOR ###
        constructor: ( notepadsPath ) ->
            # Setup the current project
            @currentProject = atom.project.getPath()

            # Setup some paths
            @storagePath = notepadsPath || null

            # Call the setStoragePath
            @setStoragePath()

            # Call the setProjectNotepadsPath
            @setProjectNotepadsPath()

        ### ACTIONS ###
        ### NEW ###
        new: ->
            # Get the saved notepads for the project
            savedNotepads = @getSaved()

            # Get currently open notepads even though they might not be persistent,
            # this is to avoid opening new notepads with same paths
            openNotepads = @getOpen()

            # If there are no saved or open notepads, start with 1
            # Use Case: No saved or open(temp) notepads
            if savedNotepads.length is 0 and openNotepads.length is 0
                # Start at notepad index 1
                notepadFile = "notepad-1"
            else
                # Check if we there are both saved and open notepads & their length matches
                # Use Case: All open notepads are saved, so new one needed
                if savedNotepads.length is openNotepads.length
                    # Set the next notepad index to saved + 1
                    notepadFile = "notepad-#{savedNotepads.length + 1}"
                else
                    # Check if we have more saved notepads then open ones
                    # Use Case: Saved notepads present, but not all are open, in which case
                    # we can work off the saved notepads length safely
                    if savedNotepads.length > openNotepads.length
                        # Set the next notepad index to saved + 1
                        notepadFile = "notepad-#{savedNotepads.length + 1}"
                    else
                        # Use Case: We have more open notepads than saved, which means
                        # there is already at least one empty notepad, just switch to the
                        # first open notepad which is unsaved and don't open a new one
                        for unsavedNotepad in openNotepads
                            # Make sure it is not a saved notepad
                            if unsavedNotepad not in savedNotepads
                                # Set the notepad file to this open notepad
                                notepadFile = unsavedNotepad

                                # We found the first unsaved, get out at this point
                                break

            # Set the title and the note pad file path
            notepadPath = @getPath( notepadFile )

            # Check if perhaps we already have this notepad open, don't open nultiple buffers
            # Set a flag to use for notepad being open
            notepadAlreadyOpen = false

            # Get the current open editors
            currentEditors = atom.workspace.getEditors()

            # Find all the open editors and see if they match a notepad path
            # If they match, close out that editor
            # Loop through the editors
            for currentEditor in currentEditors
                # Check if base path of this editor path matches notepads base path
                if currentEditor.getPath() is notepadPath
                    # Set the notepad already open flag
                    notepadAlreadyOpen = true

                    # Just switch to that editor which is the notepad and be done
                    atom.workspace.getActivePane().activateItem( currentEditor )

                    # We are done here, so just exit out
                    break

            # Create a new editor for the notepad only if not already open
            if notepadAlreadyOpen is false
                # Create a note pad
                atom.project.open( notepadPath ).then ( notepadEditor ) =>
                    # Render the notepad editor now
                    atom.workspace.getActivePane().activateItem( notepadEditor )

                    # Auto-save on change
                    notepadEditor.buffer.on "changed", => @save( notepadEditor )

        ### OPEN ###
        open: ->
            # Get the saved notepads for the project
            savedNotepads = @getSaved()

            # Get the current open Notepads
            openNotepads = @getOpen()

            # Make sure we have saved notepads to open
            if savedNotepads.length > 0
                # Loop through them, and open them up
                for notepadFile in savedNotepads
                    # Setup the notepad file path for open
                    notepadFilePath = @getPath( notepadFile )

                    # Check if this notepad is already open by any chance
                    if notepadFile not in openNotepads
                        # Open the note pad
                        atom.project.open( notepadFilePath ).then ( notepadEditor ) =>
                            # Activate the note pad
                            atom.workspace.getActivePane().activateItem( notepadEditor )

                            # Auto-save on change
                            notepadEditor.buffer.on "changed", => @save( notepadEditor )
            else
                # Check if there are unsaved notepad buffers, if there are
                # just switch to the first one there, don't open another one
                # If there are no open unsaved notepad buffers, we want to open a new
                # one, both the cases are handled properly by the `notebook:new-notepad`
                # so just call it
                @new()

        ### SAVE ###
        save: ( notepadToSave ) ->
            # Save the notepad
            notepadToSave.save()

            # Update the file path since it reverts from the core at this point
            @updateDisplayPath()

        ### CLOSE ###
        close: ->
            # Get the current open editors
            currentEditors = atom.workspace.getEditors()

            # Find all the open editors and see if they match a notepad path
            # If they match, close out that editor
            # Loop through the editors
            for currentEditor in currentEditors
                # Check if base path of this editor path matches notepads base path
                if path.dirname( currentEditor.getPath() ) is @getProjectNotepadsPath()
                    # Close the item in the pane
                    atom.workspace.getActivePane().destroyItem( currentEditor )

        ### DELETE ###
        delete: ->
            # Get the active editor item if available
            currentActiveEditorItem = atom.workspace.getActiveEditor()

            # Check first if our active item is an editor, otherwise we have nothing to do
            if currentActiveEditorItem
                # Check if the current editor is actually a notepad, otherwise we don't
                # want to or have to do anything
                if path.dirname( currentActiveEditorItem.getPath() ) is @getProjectNotepadsPath()
                    # Setup the open notepad file name
                    currentOpenNotepadFile = path.basename( currentActiveEditorItem.getPath() )

                    # Get the saved notepads for the project
                    savedNotepads = @getSaved()

                    # Check if we have saved notepads, only then do we need to some additional work
                    if savedNotepads.length is 0
                        # The current open notepad is unsaved, just close the editor and be done
                        atom.workspace.getActivePane().destroyItem( currentActiveEditorItem )
                    else
                        # We have saved notepads, and this has to be one of them
                        # In spec mode do not do confirmations
                        if atom.mode is "spec"
                            # Set delete confirmation to true
                            deleteConfirmation = true
                        else
                            # Add the confirmation dialog before full delete
                            deleteConfirmation = atom.confirm
                                # Confirm dialog options
                                message: "Delete #{currentOpenNotepadFile}?"
                                detailedMessage: "This action is irreversible, and the notepad will be permanently deleted. Are you sure?"
                                buttons:
                                    Yes: ->
                                        # Delete has been confirmed
                                        return true
                                    No: ->
                                        # Return false, since the delete was canceled
                                        return false

                        # Check if the delete was confirmed
                        if deleteConfirmation is true
                            # Close the item in the pane
                            atom.workspace.getActivePane().destroyItem( currentActiveEditorItem )

                            # Call the remove notepad, and let it handle the file removal
                            @remove( currentActiveEditorItem.getPath() )

        ### PURGE ###
        purge: ->
            # Close out all the notepads, in case there are open ones
            @close()

            # Get the saved notepads for the project
            savedNotepads = @getSaved()

            # Make sure there are notepads to remove
            if savedNotepads.length > 0
                # In spec mode do not do confirmations
                if atom.mode is "spec"
                    # Set purge confirmation to true
                    purgeConfirmation = true
                else
                    # Add the confirmation dialog before purging notepads
                    purgeConfirmation = atom.confirm
                        # Confirm dialog options
                        message: "Purge All Project Notepads?"
                        detailedMessage: "This action is irreversible, and all saved notepads will be permanently deleted. Are you sure?"
                        buttons:
                            Yes: ->
                                # Purge has been confirmed
                                return true
                            No: ->
                                # Return false, since the purge was canceled
                                return false

                # Check if the purge was confirmed
                if purgeConfirmation is true
                    # Loop through the notepads and build the paths
                    for notepadFile in savedNotepads
                        # Purge the notepad completely
                        @remove( @getPath( notepadFile ) )

        ### REMOVE ###
        remove: ( notepadFilePath ) ->
            # Destroy the notepad completely
            fs.unlinkSync notepadFilePath

        ### VIEWS ###
        ### UPDATE DISPLAY PATH ###
        updateDisplayPath: ->
            # Get the status bar file info path object
            fileInfoElement = atom.workspaceView.find( ".status-bar .file-info .current-path" )

            # Make sure we have a valid one
            if fileInfoElement
                # Check if base path of file info status matches notepads base path
                if path.dirname( fileInfoElement.text() ) is @getProjectNotepadsPath()
                    # Get the current active editor
                    currentActiveEditorItem = atom.workspace.getActivePane().getActiveItem()

                    # Update the path to only display file name/title, no need for full path
                    fileInfoElement.text( currentActiveEditorItem.getTitle() )

        ### COLLECTIONS ###
        ### GET SAVED ###
        getSaved: ->
            # Project notepads path
            projectNotepadsPath = @getProjectNotepadsPath()

            # Check if we already have notepads for this project
            notepads_exist = fs.existsSync projectNotepadsPath

            # Set the notepads for the current project
            projectNotepads = fs.readdirSync( projectNotepadsPath )

            # Return the notepads
            return projectNotepads

        ### GET OPEN ###
        getOpen: ->
            # Setup the return notepads
            openNotepads = []

            # Get the current open editors
            currentEditors = atom.workspace.getEditors()

            # We want to get a list of currently opened notepads, even if they
            # aren't saved/persisted
            # Loop through the editors
            for currentEditor in currentEditors
                # Check if base path of this editor path is same as the project notepads path
                if path.dirname( currentEditor.getPath() ) is @getProjectNotepadsPath()
                    # Add this editor object to the open notepads
                    openNotepads.push path.basename( currentEditor.getPath() )

            # Return the open notepads
            return openNotepads

        ### PATHS ###
        ### GET PATH ###
        getPath: ( notepadFileName ) ->
            # Create the full path to the note pad file
            notepadFilePath = path.join( @getProjectNotepadsPath(), notepadFileName )

            # Return the path
            return notepadFilePath

        ### SET PATH ###

        ### GET PROJECT NOTEPADS PATH ###
        getProjectNotepadsPath: ->
            # Return the current project notepads path
            return @projectNotepadsPath

        ### SET PROJECT NOTEPADS PATH ###
        setProjectNotepadsPath: ->
            # Create the full path to the project notepads folder
            @projectNotepadsPath = path.join(
                                    @getStoragePath(),
                                    new Buffer( @currentProject, "utf8" ).toString( "base64" )
                                )

            # Check if project notepads path exists
            projectNotepadsPathExists = fs.existsSync @projectNotepadsPath

            # We don't seem to have it, lets try and create it
            if not projectNotepadsPathExists
                # Create the notepads directory
                fs.mkdir @projectNotepadsPath, ( createError ) =>
                    if createError
                        # The storage path didn't exist and we couldn't create it either
                        console.log "Project notepads folder '#{@projectNotepadsPath}' could not be created - #{createError}"

                        # Error out
                        throw createError

        ### GET STORAGE PATH ###
        getStoragePath: ->
            # Return the current notepads storage path
            return @storagePath

        ### SET STORAGE PATH ###
        setStoragePath: ->
            # Check if we have a valid path provided
            if not @storagePath
                # No path was provided, so let us build the default
                @storagePath = "#{atom.getConfigDirPath()}/.notebook"

            # THIS IS SPECIAL HANDLING FOR MIGRATION FROM PROTONS
            # WILL BE REMOVED AFTER A CERTAIN PERIOD OF TIME AFTER PROTONS IS COMPLETELY RETIRED
            # Check if Proton existed and if we have any data in it
            protonNotepadsStorageExists = fs.existsSync path.join( atom.getConfigDirPath(), ".proton", "notepads" )

            # Check if storage path exists
            notepadsSavePathExists = fs.existsSync @storagePath

            # Check if the protons notepads path existed
            if protonNotepadsStorageExists and not notepadsSavePathExists
                # If it exists, let us move the path to the new notebook storage
                fs.renameSync path.join( atom.getConfigDirPath(), ".proton", "notepads" ), @storagePath
            else
                # Doesn't look like proton notepads storage existed, just go ahead as normal
                # We don't seem to have it, lets try and create it
                if not notepadsSavePathExists
                    # Create the notepads directory
                    fs.mkdir @storagePath, ( createError ) =>
                        if createError
                            # The storage path didn't exist and we couldn't create it either
                            console.log "Notepads storage folder '#{@storagePath}' could not be created - #{createError}"

                            # Error out
                            throw createError