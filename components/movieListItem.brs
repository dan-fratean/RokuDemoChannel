sub init()
  m.button = m.top.findNode("button")
  m.title = m.top.findNode("title")
  m.description = m.top.findNode("description")
end sub

sub itemContentChanged()
  m.title.text = m.top.itemContent.title
  m.description.text = m.top.itemContent.description
end sub

function showfocus()
  m.button.opacity = m.top.focusPercent
end function
