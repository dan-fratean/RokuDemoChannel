' some comments:
' - the button is faked using a rectangle, more elegant solution ca be used but
' this was good enough for this purpose
' - the video player is not on app stack since is only usable from this screen
' but the same mechanism that is implemented for the main scene can be used here
' I just thought it was overkill for this small test channel

function init()
  m.movieList = CreateObject("roSGNode", "movieList")
  m.LayoutGroup.appendChild(m.movieList)

  m.videoPlayer = m.top.findNode("videoPlayer")
  m.videoPlayer.observeField("state", "_gotState")

  m.top.observeField("focusedChild", "_onFoucsChange")
end function

sub _gotData()
  _setCommonStyleAndData()

  movieListContent = CreateObject("roSGNode", "ContentNode")
  for each movie in m.top.data.movies
    movieNode = movieListContent.CreateChild("movieListData")

    movieNode.title = movie.title
    movieNode.description = movie.description
  end for

  m.movieList.content = movieListContent
  m.movieList.observeField("itemSelected", "_onItemSelected")
end sub

sub _onFoucsChange()
  if m.top.hasFocus()
    m.movieList.setFocus(TRUE)
  end if
end sub

sub _onItemSelected()
  m.videoPlayer.visible = TRUE
  m.videoPlayer.setFocus(TRUE)

  videoContent = createObject("RoSGNode", "ContentNode")
  videoContent.url = m.top.data.movies[m.movieList.itemSelected].streamURL
  videoContent.title = m.top.data.movies[m.movieList.itemSelected].title

  if m.top.data.movies[m.movieList.itemSelected].format = "hls"
    videoContent.streamformat = "hls"
  end if

  if m.top.data.movies[m.movieList.itemSelected].format = "widevine"
    drmParams = {
      keySystem: "Widevine"
      licenseServerURL: m.top.data.movies[m.movieList.itemSelected].licenseURL
    }
    videoContent.streamFormat = "dash"
    videoContent.drmParams = drmParams
  end if

  m.videoPlayer.content = videoContent
  m.videoPlayer.control = "play"
end sub

sub _gotState()
  if m.videoPlayer.getField("state") = "finished" OR m.videoPlayer.getField("state") = "error"
    _endVideoPlayback()
  end if
end sub

sub _endVideoPlayback()
  m.videoPlayer.control = "stop"
  m.videoPlayer.visible = FALSE
  m.movieList.setFocus(TRUE)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if (press = FALSE) return FALSE

  if key = "back"
    if m.videoPlayer.visible = TRUE
      _endVideoPlayback()
    else
      m.top.backSelected = TRUE
    end if
    return TRUE
  end if

  return FALSE
end function
