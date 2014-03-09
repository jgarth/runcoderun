RunCodeRunView = require '../lib/runcoderun-view'
{WorkspaceView} = require 'atom'

describe "RunCodeRunView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    atom.workspaceView.attachToDom()
    filePath = atom.project.resolve('subdir/test.rb')

    jasmine.unspy(window, 'setTimeout')

    spyOn(RunCodeRunView.prototype, 'render')
    spyOn(RunCodeRunView.prototype, 'initialize')

    waitsForPromise ->
      atom.packages.activatePackage("runcoderun")

  describe "when opened", ->
    it "splits the current pane to the right with run output for the file", ->
      waitsForPromise ->
        atom.workspace.open("subdir/test.rb")

      runs ->
        atom.workspaceView.getActiveView().trigger 'runcoderun:run'

      waitsFor ->
        RunCodeRunView::render.callCount > 0

      runs ->
        expect(atom.workspaceView.getPanes()).toHaveLength 2
        [editorPane, runPane] = atom.workspaceView.getPanes()

        expect(editorPane.items).toHaveLength 1
        runView = runPane.getActiveItem()
        expect(runView).toBeInstanceOf(RunCodeRunView)
        expect(runView.filePath).toBe atom.workspaceView.getActivePaneItem().getPath()
        expect(editorPane).toHaveFocus()

    describe "when the editor's path does not exist", ->
      it "should not trigger", ->
        waitsForPromise ->
          atom.workspace.open("new.txt")

        runs ->
          atom.workspaceView.getActiveView().trigger 'runcoderun:run'

        waitsFor ->
          RunCodeRunView::initialize.callCount > 0

        runs ->
          expect(atom.workspaceView.getPanes()).toHaveLength 1
          expect(RunCodeRunView::render.callCount == 0)
