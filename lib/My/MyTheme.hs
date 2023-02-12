module My.MyTheme
  ( nordTheme,
    ThemeInfo (..),
  )
where

import XMonad.Layout.Decoration (Theme (..), def)
import XMonad.Util.Themes (ThemeInfo (..))

nordTheme :: ThemeInfo
nordTheme =
  TI
    { themeName = "nordTheme",
      themeAuthor = "stjandra",
      themeDescription = "https://www.nordtheme.com/",
      theme =
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
          }
    }
