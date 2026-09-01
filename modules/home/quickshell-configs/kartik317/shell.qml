// Kartik317-inspired Shell - Adapted for MangoWM
// Original: https://github.com/kartik317/Quickshell-configuration
// Simplified to remove Hyprland dependencies

import Quickshell
import QtQuick
import "./bar"

ShellRoot {
    // Bar for each screen
    Variants {
        model: Quickshell.screens
        
        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
