sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    input = CreateObject("roInput")
    input.SetMessagePort(m.port)

    scene = screen.CreateScene("homeScene")
    screen.show()

    scene.observeField("exitApp", m.port)

    while(TRUE)
      msg = wait(0, m.port)
      msgType = type(msg)

      if msgType = "roSGScreenEvent"
        if msg.isScreenClosed() then return
      end if

      if msgType = "roSGNodeEvent"
        if (msg.getField() = "exitApp")
          screen.close()
        end if
      end if

      if type(msg) = "roInputEvent"
        if msg.IsInput()
          info = msg.GetInfo()
          debug_debug("Received input: " + FormatJSON(info))
        end if
      end if
    end while

end sub
