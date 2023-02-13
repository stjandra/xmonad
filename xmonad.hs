-------------
-- Imports --
-------------

import Data.List (intercalate)
import Data.Map qualified as M
import Data.Monoid (All)
import My.MyTheme
import System.Exit (exitSuccess)
import Text.Printf (printf)
import XMonad hiding ((|||))
import XMonad.Actions.CycleWS (nextScreen, prevScreen)
import XMonad.Actions.NoBorders (toggleBorder)
import XMonad.Hooks.DynamicLog (PP (..), shorten, wrap, xmobarColor)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (AvoidStruts, ToggleStruts (..), avoidStruts)
import XMonad.Hooks.RefocusLast (RefocusLastLayoutHook, refocusLastLayoutHook, refocusLastWhen, refocusingIsActive)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.StatusBar (defToggleStrutsKey, statusBarProp, withEasySB)
import XMonad.Hooks.UrgencyHook (NoUrgencyHook (..), focusUrgent, withUrgencyHook)
import XMonad.Layout.Decoration (Decoration, DefaultShrinker, ModifiedLayout)
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.NoBorders (SmartBorder, smartBorders)
import XMonad.Layout.Simplest (Simplest)
import XMonad.Layout.Tabbed (TabbedDecoration (..), Theme (..), shrinkText, tabbed)
import XMonad.Layout.TwoPane (TwoPane (..))
import XMonad.StackSet qualified as W
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Hacks (trayerAboveXmobarEventHook, trayerPaddingXmobarEventHook)
import XMonad.Util.Loggers (Logger, logTitle, onLogger)
import XMonad.Util.NamedWindows (getName, unName)
import XMonad.Util.SpawnOnce (spawnOnce)

---------------
-- Constants --
---------------

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
myTerminal :: String
myTerminal = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 3

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask :: KeyMask
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces :: [String]
myWorkspaces = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

myTheme :: Theme
myTheme = theme nordTheme

-- Border colors for unfocused and focused windows.
myNormalBorderColor :: String
myFocusedBorderColor :: String
myNormalBorderColor = inactiveBorderColor myTheme

myFocusedBorderColor = activeColor myTheme

myColorPpCurrent :: String
myColorPpVisible :: String
myColorPpTitleFocus :: String
myColorLayout :: String
myColorPpUrgent :: String
myColorPpHidden :: String
myColorPpTitleNotFocus :: String
myColorTitleSep :: String
myColorPpCurrent = activeColor myTheme

myColorPpVisible = activeColor myTheme

myColorPpTitleFocus = activeColor myTheme

myColorLayout = activeColor myTheme

myColorPpUrgent = urgentColor myTheme

myColorPpHidden = inactiveTextColor myTheme

myColorPpTitleNotFocus = inactiveTextColor myTheme

myColorTitleSep = inactiveTextColor myTheme

myColorDmenu :: String
myColorDmenu = inactiveColor myTheme

-- dmenu args.
myDmenuArgs :: String
myDmenuArgs = printf "-i -sb '%s'" myColorDmenu

-- .desktop files with dmenu.
myDmenuDesktop :: String
myDmenuDesktop = printf "j4-dmenu-desktop --dmenu=\"dmenu %s\"" myDmenuArgs

-- Standard dmenu.
myDmenu :: String
myDmenu = printf "dmenu_run %s" myDmenuArgs

-- passmenu.
myDmenuPassmenu :: String
myDmenuPassmenu = printf "passmenu %s" myDmenuArgs

-- dmenu scripts with the extra args.
myDmenuScript :: String -> String
myDmenuScript dMenuScript = printf "%s %s" dMenuScript myDmenuArgs

-------------
-- Layouts --
-------------

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
type MyLayout = (Choose Tall (Choose TwoPane (Choose (ModifiedLayout (Decoration TabbedDecoration DefaultShrinker) Simplest) Full)))

myLayout :: MyLayout Window
myLayout = tiled ||| twoPane ||| myTabbed ||| Full
  where
    -- Default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

    -- Always two panes
    twoPane = TwoPane delta ratio

    -- Tabbed layout
    myTabbed = tabbed shrinkText myTabConfig

-- Theme for tabbed layout.
myTabConfig :: Theme
myTabConfig =
  myTheme
    { fontName = "xft:Fira Code:weight=bold:pixelsize=13:antialias=true:hinting=true",
      decoHeight = 20
    }

------------------
-- Window Rules --
------------------

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook :: ManageHook
myManageHook =
  --  insertPosition Below Newer <+>
  composeAll
    [ className =? "MPlayer" --> doFloat,
      className =? "Gimp" --> doFloat,
      resource =? "desktop_window" --> doIgnore,
      resource =? "kdesktop" --> doIgnore
    ]

--------------------
-- Event Handling --
--------------------

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook

--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook :: Event -> X All
myEventHook =
  -- Refocus the last focused window after closing a window (especially a popup).
  -- https://github.com/samhh/dotfiles/commit/d9e28572c7a413b83d09e21e54ec653f5dfba251
  refocusLastWhen refocusingIsActive <> trayerAboveXmobarEventHook <> trayerPaddingXmobarEventHook

-----------------------------
-- Status Bars and Logging --
-----------------------------

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook :: X ()
myLogHook = return ()

myXmobarPP :: PP
myXmobarPP =
  def
    { ppCurrent = xmobarColor myColorPpCurrent "" . wrap "[" "]", -- Current workspace.
      ppVisible = xmobarColor myColorPpVisible "", -- Visible, but not current workspace.
      ppHidden = xmobarColor myColorPpHidden "", -- Hidden workspaces.
      ppUrgent = xmobarColor myColorPpUrgent "" . wrap "!" "!",
      ppSep = " | ", -- Separator.
      ppLayout = myPpLayout,
      ppExtras = [myExtras],
      ppOrder = \(ws : l : _ : ex) -> [ws, l] ++ ex -- ws: workspaces, l: layout, t: title, ex: extra
    }

myPpLayout :: String -> String
myPpLayout layout = case layout of
  "Tall" -> myLayoutString "\xf58e"
  "Mirror Tall" -> myLayoutString "\xf7a4"
  "TwoPane" -> myLayoutString "\xf7a5"
  "Tabbed Simplest" -> myLayoutString "\xf24d"
  "Full" -> myLayoutString "\xf0c8"
  u -> printf "Unhandled layout %s" u

myLayoutString :: String -> String
myLayoutString string = xmobarColor myColorLayout "" $ printf "<fn=1>%s</fn>" string

-- Tabbed layout: show only focused window title
-- Other layouts: show all window titles
myExtras :: Logger
myExtras =
  do
    layout <- myCurLayout
    case layout of
      "Tabbed Simplest" -> onLogger (xmobarColor myColorPpTitleFocus "") logTitle
      _ -> myLogTitles (xmobarColor myColorPpTitleFocus "") (xmobarColor myColorPpTitleNotFocus "")

-- Adapted from
-- https://hackage.haskell.org/package/xmonad-contrib-0.16/docs/src/XMonad.Util.Loggers.html#logLayout
myCurLayout :: X String
myCurLayout = withWindowSet $ return . description . W.layout . W.workspace . W.current

-- List of all window titles and the ability to format the focused window.
-- Adapted from from https://bbs.archlinux.org/viewtopic.php?id=123299
myLogTitles :: (String -> String) -> (String -> String) -> Logger
myLogTitles ppFocus ppNotFocus =
  let windowTitles myWindowset = mapM (fmap showName . getName) (W.index myWindowset)
        where
          fw = W.peek myWindowset -- focused element of the current stack
          showName nw =
            let window = unName nw
                name = shorten 40 (show nw)
             in if Just window == fw
                  then ppFocus name
                  else ppNotFocus name
   in withWindowSet $ fmap (Just . intercalate myTitleSep) . windowTitles

-- Separator for window titles.
myTitleSep :: String
myTitleSep = xmobarColor myColorTitleSep "" " | "

------------------
-- Startup Hook --
------------------

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "~/.fehbg" -- Set wallpaper.
  --  Run Emacs daemon from kitty in order to fix color issue when client is opened in terminal
  spawnOnce "kitty --single-instance $HOME/git/scripts-public/start_emacs"
  spawnOnce "nm-applet"
  spawnOnce "dropbox start"
  spawn "$HOME/.config/xmonad/trayer.sh"

  -- Fix for Java Swing apps.
  -- https://bbs.archlinux.org/viewtopic.php?id=95437
  setWMName "LG3D"

----------------
-- Run xmonad --
----------------

-- Run xmonad with the settings you specify.
main :: IO ()
main = xmonad . ewmhFullscreen . ewmh . withUrgencyHook NoUrgencyHook . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey $ myConfig

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
myConfig :: XConfig (ModifiedLayout SmartBorder (ModifiedLayout AvoidStruts (ModifiedLayout RefocusLastLayoutHook MyLayout)))
myConfig =
  def
    { -- simple stuff
      terminal = myTerminal,
      focusFollowsMouse = myFocusFollowsMouse,
      clickJustFocuses = myClickJustFocuses,
      borderWidth = myBorderWidth,
      modMask = myModMask,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      -- key bindings
      keys = myKeys,
      mouseBindings = myMouseBindings,
      -- hooks, layouts
      layoutHook = smartBorders $ avoidStruts $ refocusLastLayoutHook myLayout,
      manageHook = myManageHook,
      handleEventHook = myEventHook,
      logHook = myLogHook,
      startupHook = myStartupHook
    }
    `additionalKeysP` myAdditionalKeys

-- `additionalMouseBindings` myAdditionalMouseBindings

------------------
-- Key Bindings --
------------------

-- Key bindings. Add, modify or remove key bindings here.
-- TODO move to myAdditionalKeys
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    [ -- Reset the layouts on the current workspace to default
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    ]
      ++
      -- Backtick/grave key: worskspace 0
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) (xK_grave : [xK_1 .. xK_9]),
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_e, xK_w, xK_r] [0 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

myAdditionalKeys :: [(String, X ())]
myAdditionalKeys =
  [ ("M-<Return>", spawn "kitty --single-instance --directory ~"),
    -- Launch dmenu desktop
    ("M-p", spawn myDmenuDesktop),
    -- Launch dmenu
    ("M-S-p", spawn myDmenu),
    -- Close focused window
    ("M-S-c", kill),
    -- Rotate through the available layout algorithms
    ("M-<Space>", sendMessage NextLayout),
    -- Resize viewed windows to the correct size
    ("M-n", refresh),
    -- Move focus to the next window
    ("M-<Tab>", windows W.focusDown),
    -- Move focus to the next window
    ("M-j", windows W.focusDown),
    -- Move focus to the previous window
    ("M-k", windows W.focusUp),
    -- Move focus to the master window
    ("M-m", windows W.focusMaster),
    -- Swap the focused window and the master window
    ("M-S-<Return>", windows W.swapMaster),
    -- Focus the most recently urgent window
    ("M-u", focusUrgent),
    -- Swap the focused window with the next window
    ("M-S-j", windows W.swapDown),
    -- Swap the focused window with the previous window
    ("M-S-k", windows W.swapUp),
    -- Shrink the master area
    ("M-h", sendMessage Shrink),
    -- Expand the master area
    ("M-l", sendMessage Expand),
    -- Push window back into tiling
    ("M-t", withFocused $ windows . W.sink),
    -- Move focus to next screen
    ("M-.", nextScreen),
    -- Move focus to previous screen
    ("M-,", prevScreen),
    -- Increment the number of windows in the master area
    ("M-S-.", sendMessage (IncMasterN 1)),
    -- Deincrement the number of windows in the master area
    ("M-S-,", sendMessage (IncMasterN (-1))),
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    ("M-b", sendMessage ToggleStruts),
    -- Toggle the border of focused window.
    -- Also push window back into tiling to fill the space left by the border.
    ("M-S-b", sequence_ [withFocused toggleBorder, withFocused $ windows . W.sink]),
    -- Quit xmonad
    ("M-S-q", io exitSuccess),
    -- Restart xmonad
    ("M-q", spawn "xmonad --recompile; xmonad --restart"),
    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    ("M-S-/", spawn ("echo \"" ++ help ++ "\" | xmessage -file -")),
    -- Suspend
    ("M-S-s", spawn "systemctl suspend"),
    -- Adjust volume
    ("<XF86AudioLowerVolume>", spawn "$HOME/git/scripts-public/pactl_volume -5%"),
    ("<XF86AudioRaiseVolume>", spawn "$HOME/git/scripts-public/pactl_volume +5%"),
    ("<XF86AudioMute>", spawn "$HOME/git/scripts-public/pactl_toggle"),
    -- Adjust brightness
    ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 3%"),
    ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 3%"),
    -- A 65% keyboard does not have a dedicated backtick '`' key.
    -- Also use mod+esc for workspace 0.
    ("M-<Esc>", windows $ W.greedyView "0"),
    ("M-S-<Esc>", windows $ W.shift "0"),
    -- Launch apps.
    ("M-x c", spawn "google-chrome-stable"),
    ("M-x e", spawn "emacsclient --create-frame --no-wait --socket-name=main"),
    ("M-x f", spawn "firefox"),
    ("M-x S-f", spawn "pcmanfm"),
    ("M-x i", spawn "idea"),
    ("M-x p", spawn "pavucontrol"),
    ("M-x q", spawn "qutebrowser"),
    ("M-x s", spawn "flameshot gui"),
    ("M-x S-s", spawn "soapui"),
    -- dmenu scripts.
    ("M-d c", spawn $ myDmenuScript "$HOME/git/scripts-dmenu-public/dm_copypaste"),
    ("M-d p", spawn myDmenuPassmenu),
    ("M-d s", spawn $ myDmenuScript "$HOME/git/scripts-dmenu-public/dm_shutdown"),
    ("M-d t", spawn $ myDmenuScript "$HOME/git/scripts-dmenu-public/dm_tmux_session"),
    -- Layout.
    ("M-a g", sendMessage $ JumpToLayout "Tall"),
    ("M-a 2", sendMessage $ JumpToLayout "TwoPane"),
    ("M-a t", sendMessage $ JumpToLayout "Tabbed Simplest"),
    ("M-a f", sendMessage $ JumpToLayout "Full")
  ]

-- myAdditionalMouseBindings =
--    [
--      ((0, 9), (\_ -> windows W.focusDown)) -- browser forward button.
--    , ((0, 8), (\_ -> windows W.focusUp)) -- browser backward button.
--    ]

-- Mouse bindings: default actions bound to mouse events
myMouseBindings :: XConfig l -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        \w ->
          focus w
            >> mouseMoveWindow w
            >> windows W.shiftMaster
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), \w -> focus w >> windows W.shiftMaster),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        \w ->
          focus w
            >> mouseResizeWindow w
            >> windows W.shiftMaster
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- Finally, a documentation of the bindings in simple textual tabular format.
help :: String
help =
  unlines
    [ "The modifier key is 'super'. Keybindings:",
      "",
      "-- Launching and killing programs",
      "mod-Enter        Launch terminal",
      "mod-p            Launch dmenu with .desktop files",
      "mod-Shift-p      Launch dmenu",
      "mod-Shift-c      Close/kill the focused window",
      "mod-n            Resize/refresh viewed windows to the correct size",
      "",
      "-- Launch a specific program",
      "M-x c    Chrome",
      "M-x e    Emacs (client)",
      "M-x f    Firefox",
      "M-x S-f  File manager (PCManFM)",
      "M-x i    IntelliJ",
      "M-x p    PulseAudio Volume Control",
      "M-x q    Qutebrowser",
      "M-x s    Flameshot",
      "M-x S-s  SoapUI",
      "",
      "-- Launch a dmenu script",
      "M-d c   Copy menu",
      "M-d p   Pass menu",
      "M-d s   Shutdown menu",
      "M-d t   tmux session menu",
      "",
      "-- Switch layout",
      "M-<Space>   Rotate through the available layout algorithms",
      "M-S-<Space> Reset the layouts on the current workSpace to default",
      "M-a g       Switch to grid layout",
      "M-a 2       Switch to two pane layout",
      "M-a t       Switch to tabbed layout",
      "M-a f       Switch to full layout",
      "",
      "-- Move focus up or down the window stack",
      "mod-Tab        Move focus to the next window",
      "mod-Shift-Tab  Move focus to the previous window",
      "mod-j          Move focus to the next window",
      "mod-k          Move focus to the previous window",
      "mod-m          Move focus to the master window",
      "mod-u          Move focus to the most recently urgent window",
      "",
      "-- Modifying the window order",
      "mod-Shift-Return   Swap the focused window and the master window",
      "mod-Shift-j        Swap the focused window with the next window",
      "mod-Shift-k        Swap the focused window with the previous window",
      "",
      "-- Resizing the master/slave ratio",
      "mod-h  Shrink the master area",
      "mod-l  Expand the master area",
      "",
      "-- Floating layer support",
      "mod-t  Push window back into tiling; unfloat and re-tile it",
      "",
      "-- Increase or decrease number of windows in the master area",
      "mod-Shift-comma  (mod-,)   Increment the number of windows in the master area",
      "mod-Shift-period (mod-.)   Deincrement the number of windows in the master area",
      "",
      "-- Quit or restart",
      "mod-Shift-q  Quit xmonad",
      "mod-q        Restart xmonad",
      "mod-grave    Switch to workSpace 0",
      "mod-Esc      Switch to workSpace 0",
      "mod-[1..9]   Switch to workSpace N",
      "mod-Shift-s  Suspend",
      "",
      "-- Border",
      "mod-b        Toggle struts.",
      "mod-Shift-b  Toggle the border of focused window.",
      "",
      "-- Workspaces & screens",
      "mod-Shift-grave    Move client to workspace 0",
      "mod-Shift-Esc      Move client to workspace 0",
      "mod-Shift-[1..9]   Move client to workspace N",
      "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
      "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
      "mod-comma  (mod-.) Move focus to the next screen",
      "mod-period (mod-,) Move focus to the previous screen",
      "",
      "-- Mouse bindings: default actions bound to mouse events",
      "mod-button1  Set the window to floating mode and move by dragging",
      "mod-button2  Raise the window to the top of the stack",
      "mod-button3  Set the window to floating mode and resize by dragging"
    ]
