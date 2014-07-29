### IMPORTS ###
# core
path = require "path"
fs = require "fs"

# atom
{WorkspaceView} = require "atom"

# notebook
Notepads = require "../lib/notepads.coffee"

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Notebook Views", ->
    ### ATTRIBUTES ###
    activationPromise = null
    notepads = null

    ### SETUP ###
    beforeEach ->
        # Create the workspace to be used
        atom.workspaceView = new WorkspaceView

        # Setup the activation for the package
        activationPromise = atom.packages.activatePackage( "notebook" )

        # Create the notepads object
        @notepads = new Notepads()

    ### TEARDOWN ###
    afterEach ->
        # Purge all note pads we might have used in tests
        @notepads.purge()

    ### SAVE TO PROJECT VIEW ###
    describe "Save To Project", ->
        ### TEST ###
        # Triggering save to project when a notepad is not the current active editor does nothing
        it "does nothing when the current active editor in workspace is not a notepad", ->
            # There should be no open editors at this point
            expect( atom.workspace.getEditors().length ).toEqual( 0 )

            # Wait for package to be activated and functional
            waitsForPromise =>
                # Waits for the activation
                activationPromise

            # Verify that there is no save to project view
            runs =>
                # Run the save to project command now
                atom.workspaceView.trigger "notebook:save-to-project"

                # We should have no save to project view even now
                expect( atom.workspaceView.find( ".notebook .save-to-project" ) ).not.toExist()

        # Triggering save to project when a notepad is open should present the save dialog
        it "displays the save dialog when save to project is triggered with a notepad as the current active item in the workspace", ->
            # There should be no open editors at this point
            expect( atom.workspace.getEditors().length ).toEqual( 0 )

            # Wait for package to be activated and functional
            waitsForPromise =>
                # Waits for the activation
                activationPromise

            # Verify that there is a save to project dialog shown
            runs =>
                # Run the new notepad now to get a notepad open
                waitsForPromise =>
                    # Execute the method in the notepads object
                    @notepads.new()

                # Verify nothing actually happened
                runs =>
                    # There should be one open editor notepad at this point
                    expect( atom.workspace.getEditors().length ).toEqual( 1 )

                    # Run the save to project command
                    atom.workspaceView.trigger "notebook:save-to-project"

                    # We should have no save to project view even now
                    expect( atom.workspaceView.find( ".notebook .save-to-project" ) ).toExist()