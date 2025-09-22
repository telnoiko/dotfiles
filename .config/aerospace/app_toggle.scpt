-- App Window Toggle Script
-- Opens an application or cycles through its windows
-- Usage: osascript app_toggle.scpt "AppName"

on run argv
	if (count of argv) = 0 then
		return 1
	end if
	
	set targetApp to item 1 of argv
	
	tell application "System Events"
		-- Get current frontmost application
		set currentApp to name of first application process whose frontmost is true
	end tell
	
	if currentApp is targetApp then
		-- Target app is active, cycle through its windows
		cycleAppWindows(targetApp)
	else
		-- Target app is not active, activate it
		tell application targetApp
			activate
			try
				if (count of windows) = 0 then
					make new document
				end if
			on error
				-- App doesn't support AppleScript window operations, just activate
			end try
		end tell
	end if
end run

-- Function to cycle through app windows (based on working Safari script)
on cycleAppWindows(appName)
	tell application appName
		try
			if (count of windows) > 1 then
				-- Get current front window index
				set currentIndex to 1
				repeat with i from 1 to (count of windows)
					if index of window i is 1 then
						set currentIndex to i
						exit repeat
					end if
				end repeat

				-- Calculate next window index (cycle)
				set nextIndex to currentIndex + 1
				if nextIndex > (count of windows) then
					set nextIndex to 1
				end if

				-- Bring next window to front
				set index of window nextIndex to 1
			end if
		on error
			-- App doesn't support AppleScript window operations
			-- Use a bash script to cycle through this app's windows
			set bashScript to "
			current_window=$(aerospace list-windows --focused | head -1 | cut -d' ' -f1)
			app_windows=$(aerospace list-windows --all | grep '" & appName & "' | cut -d' ' -f1)
			window_array=($app_windows)

			if [ ${#window_array[@]} -gt 1 ]; then
				for i in \"${!window_array[@]}\"; do
					if [ \"${window_array[$i]}\" = \"$current_window\" ]; then
						next_index=$(( (i + 1) % ${#window_array[@]} ))
						aerospace focus --window-id \"${window_array[$next_index]}\"
						break
					fi
				done
			fi"
			do shell script bashScript
		end try
	end tell
end cycleAppWindows