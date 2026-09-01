// Time.qml

// with this line our type becomes a Singleton
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string time: {
    Qt.formatDateTime(clock.date, "hh:mm AP | dddd MMMM d yyyy")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
