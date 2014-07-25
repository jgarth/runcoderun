url = require 'url'

RunCodeRunView = require './runcoderun-view'

module.exports =
  runCodeRunView: null

  activate: (state) ->
    atom.workspaceView.command "runcoderun:run", => @showEditor()
    atom.workspaceView.command "runcoderun:tree", => @showFile()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse(uriToOpen)
      pathname = decodeURI(pathname) if pathname
      return unless protocol is 'runcoderun:'

      if host is 'editor'
        @runCodeRunView = new RunCodeRunView(editorId: pathname.substring(1))
      else
        @runCodeRunView = new RunCodeRunView(filePath: pathname.substring(1))

  deactivate: ->
    @runCodeRunView?.destroy()

  serialize: ->
    runCodeRunViewState: @runCodeRunView?.serialize()

  showEditor: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    previousActivePane = atom.workspace.getActivePane()

    uri = "runcoderun://editor/#{editor.id}"
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (runCodeRunView) ->
      runCodeRunView.runCode()
      previousActivePane.activate()

  showFile: ->
    rootDir = atom.project.getRootDirectory().path
    filePath = atom.workspaceView.find('.tree-view .selected .name').data("path")
    uri = "runcoderun://file/#{rootDir}/#{filePath}"
    
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (runCodeRunView) ->
      runCodeRunView.runCode()
