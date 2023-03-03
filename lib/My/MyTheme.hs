module My.MyTheme
  ( MyTheme (..),
    BorderTheme (..),
    XmobarTheme (..),
    latteTheme,
    macchiatoTheme,
    nordTheme,
    onedarkTheme
  )
where

import XMonad.Layout.Decoration (Theme (..), def)

data MyTheme = MT
  { theme :: Theme,
    borderTheme :: BorderTheme,
    xmobarTheme :: XmobarTheme,
    dmenuColor :: String,
    trayerBg :: String
  }

data BorderTheme = BT
  { myNormalBorderColor :: String,
    myFocusedBorderColor :: String
  }

data XmobarTheme = MX
  { myPpCurrentColor :: String,
    myPpVisibleColor :: String,
    myPpHiddenColor :: String,
    myPpUrgentColor :: String,
    myPpLayoutColor :: String,
    myPpSepColor :: String,
    myPpTitleFocusColor :: String,
    myPpTitleNotFocusColor :: String
  }

-- Colors from https://github.com/catppuccin/catppuccin
latteTheme :: MyTheme
latteTheme =
  MT
    { theme =
        def
          { activeColor = "#7287fd",
            inactiveColor = "#9ca0b0",
            urgentColor = "#d20f39",
            activeBorderColor = "#7287fd",
            inactiveBorderColor = "#9ca0b0",
            urgentBorderColor = "#d20f39",
            activeTextColor = "#eff1f5",
            inactiveTextColor = "#eff1f5",
            urgentTextColor = "#eff1f5"
          },
      borderTheme =
        BT
          { myNormalBorderColor = "#9ca0b0",
            myFocusedBorderColor = "#7287fd"
          },
      xmobarTheme =
        MX
          { myPpCurrentColor = "#04a5e5",
            myPpVisibleColor = "#04a5e5",
            myPpHiddenColor = "#4c4f69",
            myPpUrgentColor = "#d20f39",
            myPpLayoutColor = "#04a5e5",
            myPpSepColor = "#4c4f69",
            myPpTitleFocusColor = "#04a5e5",
            myPpTitleNotFocusColor = "#4c4f69"
          },
      dmenuColor = "#9ca0b0",
      trayerBg = "#9ca0b0"
    }

-- Colors from https://github.com/catppuccin/catppuccin
macchiatoTheme :: MyTheme
macchiatoTheme =
  MT
    { theme =
        def
          { activeColor = "#b7bdf8",
            inactiveColor = "#5b6078",
            urgentColor = "#ed8796",
            activeBorderColor = "#b7bdf8",
            inactiveBorderColor = "#5b6078",
            urgentBorderColor = "#ed8796",
            activeTextColor = "#24273a",
            inactiveTextColor = "#cad3f5",
            urgentTextColor = "#cad3f5"
          },
      borderTheme =
        BT
          { myNormalBorderColor = "#5b6078",
            myFocusedBorderColor = "#b7bdf8"
          },
      xmobarTheme =
        MX
          { myPpCurrentColor = "#8aadf4",
            myPpVisibleColor = "#8aadf4",
            myPpHiddenColor = "#cad3f5",
            myPpUrgentColor = "#ed8796",
            myPpLayoutColor = "#8aadf4",
            myPpSepColor = "#cad3f5",
            myPpTitleFocusColor = "#8aadf4",
            myPpTitleNotFocusColor = "#cad3f5"
          },
      dmenuColor = "#5b6078",
      trayerBg = "#24273a"
    }

-- Colors from https://www.nordtheme.com/
nordTheme :: MyTheme
nordTheme =
  MT
    { theme =
        def
          { activeColor = "#88c0d0",
            inactiveColor = "#4c566a",
            urgentColor = "#bf616a",
            activeBorderColor = "#88c0d0",
            inactiveBorderColor = "#4c566a",
            urgentBorderColor = "#bf616a",
            activeTextColor = "#2e3440",
            inactiveTextColor = "#d8dee9",
            urgentTextColor = "#d8dee9"
          },
      borderTheme =
        BT
          { myNormalBorderColor = "#4c566a",
            myFocusedBorderColor = "#88c0d0"
          },
      xmobarTheme =
        MX
          { myPpCurrentColor = "#88c0d0",
            myPpVisibleColor = "#88c0d0",
            myPpHiddenColor = "#d8dee9",
            myPpUrgentColor = "#bf616a",
            myPpLayoutColor = "#88c0d0",
            myPpSepColor = "#d8dee9",
            myPpTitleFocusColor = "#88c0d0",
            myPpTitleNotFocusColor = "#d8dee9"
          },
      dmenuColor = "#4c566a",
      trayerBg = "#2e3440"
    }

-- Colors from https://github.com/Binaryify/OneDark-Pro
onedarkTheme :: MyTheme
onedarkTheme =
  MT
    { theme =
        def
          { activeColor = "#8cc265",
            inactiveColor = "#4f5666",
            urgentColor = "#e05561",
            activeBorderColor = "#8cc265",
            inactiveBorderColor = "#4f5666",
            urgentBorderColor = "#e05561",
            activeTextColor = "#282c34",
            inactiveTextColor = "#abb2bf",
            urgentTextColor = "#abb2bf"
          },
      borderTheme =
        BT
          { myNormalBorderColor = "#4f5666",
            myFocusedBorderColor = "#8cc265"
          },
      xmobarTheme =
        MX
          { myPpCurrentColor = "#4aa5f0",
            myPpVisibleColor = "#4aa5f0",
            myPpHiddenColor = "#abb2bf",
            myPpUrgentColor = "#e05561",
            myPpLayoutColor = "#4aa5f0",
            myPpSepColor = "#abb2bf",
            myPpTitleFocusColor = "#4aa5f0",
            myPpTitleNotFocusColor = "#abb2bf"
          },
      dmenuColor = "#4f5666",
      trayerBg = "#282c34"
    }

-- Template
-- todoTheme :: MyTheme
-- todoTheme =
--   MT
--     { theme =
--         def
--           { activeColor = "",
--             inactiveColor = "",
--             urgentColor = "",
--             activeBorderColor = "",
--             inactiveBorderColor = "",
--             urgentBorderColor = "",
--             activeTextColor = "",
--             inactiveTextColor = "",
--             urgentTextColor = ""
--           },
--       borderTheme =
--         BT
--           { myNormalBorderColor = "",
--             myFocusedBorderColor = ""
--           },
--       xmobarTheme =
--         MX
--           { myPpCurrentColor = "",
--             myPpVisibleColor = "",
--             myPpHiddenColor = "",
--             myPpUrgentColor = "",
--             myPpLayoutColor = "",
--             myPpSepColor = "",
--             myPpTitleFocusColor = "",
--             myPpTitleNotFocusColor = ""
--           },
--       dmenuColor = "",
--       trayerBg = ""
--     }
