#!/bin/bash
# This largely taken from the excellent set of settings Mathias Bynens put
# together here:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.osx
set -e
set -x
proMode=
isMacPro=
isLaptop=
userOnly=
noDetect=

while getopts pdlu name
do
    case $name in
        p)  proMode=t
            ;;
        d)  isMacPro=t
            noDetect=t
            ;;
        l)  isLaptop=t
            noDetect=t
            ;;
        u)  userOnly=t
            ;;
    esac
done

if test -z "$noDetect" ; then
    if system_profiler SPHardwareDataType | grep 'Model Identifier' | grep -q MacPro ; then
        isMacPro=t
        isLaptop=
    else
        isMacPro=
        isLaptop=t
    fi
fi

defaults_write()
{
    domain="$1"
    shift

    /usr/bin/defaults write "$domain" "$@"

    if [ -z "$userOnly" ] ; then
        sudo /usr/bin/defaults write "/System/Library/User Template/Non_localized/Library/Preferences/$1" "$@"
    fi
}

defaults_write_global()
{
    /usr/bin/defaults write NSGlobalDomain "$@"

    if [ -z "$userOnly" ] ; then
        sudo /usr/bin/defaults write "/System/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences.plist" "$@"
    fi
}

plist_buddy()
{
    /usr/libexec/PlistBuddy -c "$1" "$HOME/Library/Preferences/$2"

    if [ -z "$userOnly" -a -n "$3" ] ; then
        sudo /usr/libexec/PlistBuddy -c "$1" "/System/Library/User Template/Non_localized/Library/Preferences/$2"
    fi
}

# Just suspend to RAM, rather than writing the image to disk.
# test -n "$isLaptop" -a -z "$userOnly" && sudo pmset -a hibernatemode 0

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Menu bar: disable transparency
defaults_write_global AppleEnableMenuBarTransparency -bool false
defaults_write com.apple.universalaccess reduceTransparency -bool true

# Menu bar: show remaining battery time (on pre-10.8); hide percentage
defaults_write com.apple.menuextra.battery ShowPercent -string "NO"
defaults_write com.apple.menuextra.battery ShowTime -string "YES"


# if test -n $isLaptop ; then
#     extraMenuItems='
#         "/System/Library/CoreServices/Menu Extras/AirPort.menu"
#         "/System/Library/CoreServices/Menu Extras/Battery.menu"
#     '
# else
#     extraMenuItems=''
# fi

# # Menu bar: hide the useless Time Machine and Volume icons
# defaults_write com.apple.systemuiserver menuExtras -array \
#     "/System/Library/CoreServices/Menu Extras/iChat.menu"       \
#     "/System/Library/CoreServices/Menu Extras/VPN.menu"         \
#     "/System/Library/CoreServices/Menu Extras/Displays.menu"    \
#     "/System/Library/CoreServices/Menu Extras/Eject.menu"       \
#     "/System/Library/CoreServices/Menu Extras/Volume.menu"      \
#     "/System/Library/CoreServices/Menu Extras/Clock.menu"       \
#     "/System/Library/CoreServices/Menu Extras/User.menu"        \
#     "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"   \
#     $extraMenuItems

# Always show scrollbars
# defaults_write_global AppleShowScrollBars -string "Always"

# Disable smooth scrolling
# (Uncomment if you’re on an older Mac that messes up the animation)
#defaults_write_global NSScrollAnimationEnabled -bool false

# Disable opening and closing window animations
defaults_write_global NSAutomaticWindowAnimationsEnabled -bool false

# Increase window resize speed for Cocoa applications
defaults_write_global NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults_write_global NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel by default
defaults_write_global PMPrintingExpandedStateForPrint -bool true

# Save to disk (not to iCloud) by default
defaults_write_global NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults_write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
# defaults_write com.apple.LaunchServices LSQuarantine -bool false

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
# defaults_write_global NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
# defaults_write_global NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
# defaults_write_global NSDisableAutomaticTermination -bool true

# Disable the crash reporter
#defaults_write com.apple.CrashReporter DialogType -string "none"

# Set Help Viewer windows to non-floating mode
defaults_write com.apple.helpviewer DevMode -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
test -z "$userOnly" && sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Restart automatically if the computer freezes
test -z "$userOnly" && systemsetup -setrestartfreeze on

# Never go into computer sleep mode
# test -z "$userOnly" && systemsetup -setcomputersleep Off > /dev/null

# Check for software updates daily, not just once per week
# JSS should adjust /Library/Preferences?
# defaults_write com.apple.SoftwareUpdate ScheduleFrequency -int 1

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults_write_global com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom right corner to right-click
defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Trackpad: swipe between pages with three fingers
# defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
# defaults_write_global AppleEnableSwipeNavigateWithScrolls -bool true
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1

# Disable “natural” (Lion-style) scrolling
defaults_write_global com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults_write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults_write_global AppleKeyboardUIMode -int 3

# Automatically illuminate built-in MacBook keyboard in low light
# defaults_write com.apple.BezelServices kDim -bool true
# Turn off keyboard illumination when computer is not used for 5 minutes
# defaults_write com.apple.BezelServices kDimTime -int 300

# Set the timezone; see `systemsetup -listtimezones` for other values
test -z "$userOnly" && systemsetup -settimezone "America/New_York" > /dev/null

# Disable auto-correct
# defaults_write_global NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password 5s after sleep or screen saver begins
defaults_write com.apple.screensaver askForPassword -int 1
defaults_write com.apple.screensaver askForPasswordDelay -int 5

# Save screenshots to the desktop
defaults_write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults_write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults_write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
# defaults_write_global AppleFontSmoothing -int 1
# defaults -currentHost write -g AppleFontSmoothing -int 1

# Enable HiDPI display modes (requires restart)
# sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
# defaults_write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults_write com.apple.finder DisableAllAnimations -bool true

# Do not show icons for hard drives, servers, and removable media on the desktop
defaults_write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults_write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults_write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults_write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder: show hidden files by default
# defaults_write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults_write_global AppleShowAllExtensions -bool true

# Finder: show status bar
defaults_write com.apple.finder ShowStatusBar -bool true

# Finder: allow text selection in Quick Look
# defaults_write com.apple.finder QLEnableTextSelection -bool true

# Display full POSIX path as Finder window title
defaults_write com.apple.finder _FXShowPosixPathInTitle -bool true

# When performing a search, search the current folder by default
defaults_write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults_write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults_write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable disk image verification
# defaults_write com.apple.frameworks.diskimages skip-verify -bool true
# defaults_write com.apple.frameworks.diskimages skip-verify-locked -bool true
# defaults_write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
# defaults_write com.apple.frameworks.diskimages auto-open-ro-root -bool true
# defaults_write com.apple.frameworks.diskimages auto-open-rw-root -bool true
# defaults_write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Show item info near icons on the desktop and in other icon views
# plist_buddy "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" com.apple.finder.plist
# plist_buddy "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" com.apple.finder.plist
# plist_buddy "Set :StandardViewSettings:IconViewSettings:showItemInfo true" com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views
# plist_buddy "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" com.apple.finder.plist
# plist_buddy "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" com.apple.finder.plist
# plist_buddy "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
# plist_buddy "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" com.apple.finder.plist
# plist_buddy "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" com.apple.finder.plist
# plist_buddy "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
# plist_buddy "Set :DesktopViewSettings:IconViewSettings:iconSize 80" com.apple.finder.plist
# plist_buddy "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" com.apple.finder.plist
# plist_buddy "Set :StandardViewSettings:IconViewSettings:iconSize 80" com.apple.finder.plist

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
# defaults_write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
# defaults_write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
# defaults_write com.apple.finder EmptyTrashSecurely -bool true

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
# defaults_write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show the ~/Library folder
# chflags nohidden ~/Library

###############################################################################
# Dock & hot corners                                                          #
###############################################################################

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults_write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 56 pixels
defaults_write com.apple.dock tilesize -int 56

# Enable spring loading for all Dock items
defaults_write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults_write com.apple.dock show-process-indicators -bool true

# Don’t animate opening applications from the Dock
defaults_write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
# defaults_write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
# defaults_write com.apple.dock expose-group-by-app -bool false

# Don’t show Dashboard as a Space
# defaults_write com.apple.dock dashboard-in-overlay -bool true

# Remove the auto-hiding Dock delay
defaults_write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults_write com.apple.dock autohide-time-modifier -float 0

# Enable the 2D Dock
#defaults_write com.apple.dock no-glass -bool true

# Automatically hide and show the Dock
defaults_write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults_write com.apple.dock showhidden -bool true

# Reset Launchpad
# find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
#  8: Spaces
# 10: Put display to sleep
# 11: Launchpad
# Top left screen corner → Screen Saver
defaults_write com.apple.dock wvous-tl-corner -int 5
defaults_write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Spaces
defaults_write com.apple.dock wvous-tr-corner -int 8
defaults_write com.apple.dock wvous-tr-modifier -int 0

# Disable switching desktops via control keys.
# Ensure key exists.
plist_buddy "Add :AppleSymbolicHotKeys: dict" com.apple.symbolichotkeys.plist t || true

# Control-up (Mission Control)
plist_buddy "Add :AppleSymbolicHotKeys:32: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:32:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:32:enabled 0" com.apple.symbolichotkeys.plist t
plist_buddy "Add :AppleSymbolicHotKeys:34: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:34:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:34:enabled 0" com.apple.symbolichotkeys.plist t
# Control-down (Applications)
plist_buddy "Add :AppleSymbolicHotKeys:33: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:33:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:33:enabled 0" com.apple.symbolichotkeys.plist t
plist_buddy "Add :AppleSymbolicHotKeys:35: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:35:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:35:enabled 0" com.apple.symbolichotkeys.plist t
# Control-left (Move left a space)
plist_buddy "Add :AppleSymbolicHotKeys:79: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:79:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:79:enabled 0" com.apple.symbolichotkeys.plist t
plist_buddy "Add :AppleSymbolicHotKeys:80: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:80:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:80:enabled 0" com.apple.symbolichotkeys.plist t
# Control-right (Move right a space)
plist_buddy "Add :AppleSymbolicHotKeys:81: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:81:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:81:enabled 0" com.apple.symbolichotkeys.plist t
plist_buddy "Add :AppleSymbolicHotKeys:82: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:82:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:82:enabled 0" com.apple.symbolichotkeys.plist t
# Control-1 (Switch to desktop 1)
plist_buddy "Add :AppleSymbolicHotKeys:118: dict" com.apple.symbolichotkeys.plist t || true
plist_buddy "Add :AppleSymbolicHotKeys:118:enabled bool" com.apple.symbolichotkeys.plist t || true
plist_buddy "Set :AppleSymbolicHotKeys:118:enabled 0" com.apple.symbolichotkeys.plist t

# Get rid of cached preferences...
killall cfprefsd
launchctl stop com.apple.Dock.agent

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults_write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
test -z "$userOnly" && hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

# Enable the debug menu in Address Book
# defaults_write com.apple.addressbook ABShowDebugMenu -bool true

# Enable Dashboard dev mode (allows keeping widgets on the desktop)
# defaults_write com.apple.dashboard devmode -bool true

# Enable the debug menu in iCal (pre-10.8)
# defaults_write com.apple.iCal IncludeDebugMenu -bool true

# Use plain text mode for new TextEdit documents
# defaults_write com.apple.TextEdit RichText -int 0
# Open and save files as UTF-8 in TextEdit
# defaults_write com.apple.TextEdit PlainTextEncoding -int 4
# defaults_write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the debug menu in Disk Utility
# defaults_write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults_write com.apple.DiskUtility advanced-image-options -bool true

# Disable swipe page on Chrome
defaults_write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

# Disable App Nap for iTerm2
defaults_write com.googlecode.iterm2 NSAppSleepDisabled -bool YES

# Disable startup chime
test -z "$userOnly" && sudo nvram "SystemAudioVolume=%00"
test -z "$userOnly" && sudo nvram boot-args="-v"

echo "You need to logout and back in for some preferences to take effect."

echo "Run 'sudo scutil --set HostName <hostname>' to set the host name for the machine"
