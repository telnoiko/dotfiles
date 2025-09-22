#!/bin/bash

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <AppName> <Size>"
    echo "Size options:"
    echo "  left2  - Left 2/3 of screen"
    echo "  right1 - Right 1/3 of screen"
    echo "Example: $0 Telegram right1"
    echo "Example: $0 Safari left2"
    exit 1
fi

APP_NAME="$1"
SIZE_OPTION="$2"

# Activate the specified app
osascript ~/.config/aerospace/app_toggle.scpt "$APP_NAME"

# Wait and set floating
sleep 0.1
aerospace layout floating

# Use Finder to get dynamic screen size and position app
osascript << EOF
tell application "Finder"
    -- Get the current desktop bounds dynamically
    set desktopBounds to bounds of window of desktop
    set screenWidth to item 3 of desktopBounds
    set screenHeight to item 4 of desktopBounds
end tell

tell application "System Events"
    tell process "$APP_NAME"
        -- AeroSpace gap settings (from your config)
        set gapTop to 30
        set gapLeft to 5
        set gapRight to 5
        set gapBottom to 5

        -- Calculate dimensions based on size option
        set sizeOption to "$SIZE_OPTION"
        if sizeOption is "left2" then
            -- Left 2/3 of screen
            set windowWidth to ((screenWidth * 2) / 3) - gapLeft
            set windowHeight to screenHeight - gapTop - gapBottom
            set leftX to gapLeft
            set topY to gapTop
        else if sizeOption is "right1" then
            -- Right 1/3 of screen
            set windowWidth to (screenWidth / 3) - gapRight
            set windowHeight to screenHeight - gapTop - gapBottom
            set leftX to screenWidth - windowWidth - gapRight
            set topY to gapTop
        else
            error "Invalid size option: " & sizeOption & ". Use 'left2' or 'right1'"
        end if

        try
            -- Try setting position and size separately
            set position of front window to {leftX, topY}
            delay 0.1
            set size of front window to {windowWidth, windowHeight}

        on error theError
            try
                -- Fallback: try bounds with app directly
                tell application "$APP_NAME"
                    set bounds of front window to {leftX, topY, leftX + windowWidth, topY + windowHeight}
                end tell
            on error
                -- Last resort: just set size
                set size of front window to {windowWidth, windowHeight}
            end try
        end try
    end tell
end tell
EOF
