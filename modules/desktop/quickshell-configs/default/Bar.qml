// Bar.qml
import Quickshell // for PanelWindow

Scope {

  Variants {
    model: Quickshell.screens

    PanelWindow {
      // the screen from the screens list will be injected into this
      // property
      required property var modelData

      // we can then set the window's screen to the injected property
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      ClockWidget {
        // center the bar in its parent component (the window)
        anchors.centerIn: parent
      }
    }
  }
}
