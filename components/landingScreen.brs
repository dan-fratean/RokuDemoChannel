function init()
  m.buttons = CreateObject("roSGNode", "ButtonGroup")
  m.LayoutGroup.appendChild(m.buttons)

  m.top.observeField("focusedChild", "_onFoucsChange")
end function

sub _gotData()
  _setCommonStyleAndData()

  buttons = []
  for each button in m.top.data.buttons
    buttons.push(button.title)
  end for

  m.buttons.buttons = buttons
  m.buttons.observeField("buttonSelected", "_onButtonSelected")
end sub

sub _onFoucsChange()
  if m.top.hasFocus()
    m.buttons.setFocus(TRUE)
  end if
end sub

sub _onButtonSelected()
  if m.top.data.buttons[m.buttons.buttonSelected].action.doesExist("exitApp") AND m.top.data.buttons[m.buttons.buttonSelected].action["exitApp"]
    m.top.setField("exitApp", TRUE)
  end if
  if m.top.data.buttons[m.buttons.buttonSelected].action.doesExist("goTo")
    m.top.setField("goTo", m.top.data.buttons[m.buttons.buttonSelected].action["goTo"])
  end if
end sub
