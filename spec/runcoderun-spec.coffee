RunCodeRun = require '../lib/runcoderun'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

# describe "Runcoderun", ->
#   activationPromise = null
#
#   beforeEach ->
#     atom.workspaceView = new WorkspaceView
#     activationPromise = atom.packages.activatePackage('runcoderun')
#
#   describe "when the runcoderun:run event is triggered", ->
#     it "opens a new pane", ->
#       expect(atom.workspaceView.find('.runcoderun')).not.toExist()
#
#       # This is an activation event, triggering it will cause the package to be
#       # activated.
#       atom.workspaceView.trigger 'runcoderun:run'
#
#       waitsForPromise ->
#         activationPromise
#
#       runs ->
#         expect(atom.workspaceView.find('.runcoderun')).toExist()
#
#       expect(atom.workspaceView.find('.runcoderun')).not.toExist()
