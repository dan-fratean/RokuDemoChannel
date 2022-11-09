function init()
  m.LayoutGroup = m.top.findNode("LayoutGroup")
  m.title = m.top.findNode("title")
  m.description = m.top.findNode("description")
  m.background = m.top.findNode("background")

  m.top.observeField("data", "_gotData")
end function

sub _setCommonStyleAndData()
  m.title.text = m.top.data.title
  m.description.text = m.top.data.description
  m.background.color = m.top.data.background
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if (press = FALSE) return FALSE

  if key = "back"
    m.top.backSelected = TRUE
    return TRUE
  end if

  return FALSE
end function
