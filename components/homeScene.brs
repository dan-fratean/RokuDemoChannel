function init()
  m.top.setFocus(TRUE)

  m.screens = {}
  m.stack = []

  _retrieveJson()
end function

sub _retrieveJson()
  m.task = createObject("roSGNode", "retrieveJson")
  m.task.observeField("data", "_gotData")
  m.task.control = "RUN"
end sub

sub _gotData(data)
  ' some crude error handling
  result = data.getRoSGNode().data

  ' some crude error handling
  if type(result) = "roAssociativeArray" and result.doesExist("errorMessage")
    print "error occured during json load"
  else if type(result) = "roAssociativeArray" and result.doesExist("screens")
    _parseData(result.screens)
  end if
end sub

sub _parseData(screens)
  for each screen in screens
    _createScreen(screen, screens[screen])
    if screens[screen].showOnLaunch = TRUE
      _addOnStackAndDisplay(screen)
    end if
  end for
end sub

sub _createScreen(screenName, screenData)
  screen = CreateObject("roSGNode", screenName)
  screen.setField("data", screenData)

  screen.observeField("exitApp", "_onExitAppChanged")
  screen.observeField("goTo", "_onGoToChanged")
  screen.observeField("backSelected", "_onBackSelectedChanged")

  m.screens[screenName] = screen
end sub

sub _onExitAppChanged(event)
  if event.getData() = TRUE
    m.top.setField("exitApp", TRUE)
  end if
end sub

sub _onGoToChanged(event)
  ' some sanity checks can be added to make sure we are not trying to use junk/not defined views
  _addOnStackAndDisplay(event.getData())
end sub

sub _onBackSelectedChanged(event)
  ' last screen, will exit app
  if m.stack.Count() = 1
    m.top.setField("exitApp", TRUE)
  else
    _removeFromStackAndDestroy(m.stack.Pop())
    m.stack.Peek().setFocus(TRUE)
  end if
end sub

sub _addOnStackAndDisplay(screenName)
  ' a check be added to see if the screen if already created.
  ' we trust the api for now
  screen = m.screens[screenName]
  m.top.appendChild(screen)

  screen.visible = TRUE
  screen.setFocus(TRUE)

  m.stack.push(screen)
end sub

sub _removeFromStackAndDestroy(screen)
  screen.visible = FALSE
  m.top.removeChild(screen)
end sub
