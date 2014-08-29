#SingleInstance force
#Persistent 
#NoEnv 
DetectHiddenWindows, On
DetectHiddenText, On
Process, priority, , L ; Low Priority Process.

defaulttraymsg := "Crunchyroll Fullscreen F2 to start`, F3 to pause`, F4 to close." ; default tray popup message.
Menu, Tray, NoStandard ; removing all the normal tray controls AHK adds.
Menu, Tray, Tip, %defaulttraymsg% ; displaying above message in in tool tip popup.
Menu, Sleep, Add, Cancel, SleepCancel ; sleep submenu - cancel menu will trigger SleepCancel which cancels the timer.
Menu, Sleep, Add, 5, SleepMenuHandler ; menu triggers sleep handler on click pulling he value of this menu and using it for the command.
Menu, Sleep, Add, 10, SleepMenuHandler
Menu, Sleep, Add, 15, SleepMenuHandler
Menu, Sleep, Add, 20, SleepMenuHandler
Menu, Sleep, Add, 25, SleepMenuHandler
Loop, 9 { ;using loop to create the rest of the menu.
; add 10 every loop.
MenuTime += 10
Menu, Sleep, Add, %MenuTime%, SleepMenuHandler
} 
Loop, 7 { ;using loop to create the rest of the menu.
; add 30 every loop.
MenuTime += 30
Menu, Sleep, Add, %MenuTime%, SleepMenuHandler
} 
MenuTime = 0; set back to 0.
Menu, Tray, Add, Sleep, :Sleep ;insert the sleep submenu into the tray as Sleep.

Menu, Shutdown, Add, Cancel, ShutdownCancel ; same as sleep. just triggering the shutdown gotos.
Menu, Shutdown, Add, 5, ShutdownMenuHandler ; same as the sleephandler.
Menu, Shutdown, Add, 10, ShutdownMenuHandler
Menu, Shutdown, Add, 15, ShutdownMenuHandler
Menu, Shutdown, Add, 20, ShutdownMenuHandler
Menu, Shutdown, Add, 25, ShutdownMenuHandler
Loop, 9 { ;using loop to create the rest of the menu.
; add 10 every loop.
MenuTime += 10
Menu, Sleep, Add, %MenuTime%, ShutdownMenuHandler
} 
Loop, 7 { ;using loop to create the rest of the menu.
; add 30 every loop.
MenuTime += 30
Menu, Sleep, Add, %MenuTime%, ShutdownMenuHandler
} 
MenuTime =; clear the var.
Menu, Tray, Add, Shutdown, :Shutdown ; adding the submenu into Shutdown.

Menu, Tray, Add ; adds bar spacing into menu.
Menu, Tray, add, Start, F2 ; adding start stop and exit menu items tied to the same hotkeys.
Menu, Tray, add, Stop, F3
Menu, Tray, Add, Exit, F4

return ;we don't want to run through all the other commands ahead of time.

;SleepUpdate is the timer command triggered that will count down and go to the next command sleepytime.
SleepUpdate:
SleepMinutes -= 1
if SleepMinutes <= 0
  Goto, SleepyTime
Menu, Tray, Tip, Crunchyroll Fullscreen will pause in %SleepMinutes% Minutes.
return

;Sleepy time will make sure to have either the flash player or chrome render window as top most to pause by pressing space.
SleepyTime:
SetTimer, SleepUpdate, OFF

Send, {SPACE}
Menu, Tray, Tip, Crunchyroll Fullscreen is now paused.
  Goto, F3
return

;cancels the sleep timer.
SleepCancel:
SetTimer, SleepUpdate, OFF
  Menu, Tray, Tip, %defaulttraymsg%
return

;the menu handle that reads the value and triggers the sleep timer command with the set time.
SleepMenuHandler:
SleepTimer(A_ThisMenuItem)
SleepMinutes := A_ThisMenuItem
return

;Sleep timer that makes sure time provided isn't 0 goes to a default of 120. Which in reality doesn't do anything since its not possible to trigger via the menu with out proper time.
SleepTimer(SleepMinutes=0) {
if SleepMinutes < 1 ;Checks if any command line parameters were passed
    SleepMinutes = 120 ;Sets timer to 120 min if no parameters were passed

Menu, Tray, Tip, Crunchyroll Fullscreen will pause %SleepMinutes% Minutes.
SetTimer, SleepUpdate, 60000
SetTimer, FSCheck, 1000 ; making sure your Fullscreen check is running incase you started the timmer first.
return
}

;please refer to the sleep versions of these commands they are essentially the same for the exception at the end this turns your computer off.
ShutdownUpdate:
ShutdownMinutes -= 1
if ShutdownMinutes <= 0
  Goto, ShutdownTime
Menu, Tray, Tip, Windows will shutdown in %ShutdownMinutes% Minutes.
return

ShutdownTime:
  Menu, Tray, Tip, %defaulttraymsg%
SetTimer, ShutdownUpdate, OFF
; basic force shtudown with 60 sec timer command.
run, shutdown -f -s -t 60
return

;disable shutdown timer and abort shutdown if it has been initialized.
ShutdownCancel:
  Menu, Tray, Tip, %defaulttraymsg%
SetTimer, ShutdownUpdate, OFF
run, shutdown -a
return

ShutdownMenuHandler:
ShutdownTimer(A_ThisMenuItem)
ShutdownMinutes := A_ThisMenuItem
return

ShutdownTimer(ShutdownMinutes=0) {
if ShutdownMinutes < 1 ;Checks if any command line parameters were passed
    ShutdownMinutes = 120 ;Sets timer to 120 min if no parameters were passed

Menu, Tray, Tip, Windows will shutdown in %ShutdownMinutes% Minutes.
SetTimer, ShutdownUpdate, 60000
SetTimer, FSCheck, 1000
return
}
;hotkeys: if you change these make sure you update the menus above. You could have labels set instead just before each hotkey and use that, but that's for another day.
;F2 hotkey which starts a timer instead of a loops now.
F2::
SetTimer, FSCheck, 1000
return

;Fullscreen check. Some changes from the original which was a loop, but mostly the same.
FSCheck:
; Works for IE, Chrome and helps prevent detection of any other window with the name Watch. If this fails it will fallback to detecting only by title. 
SetTitleMatchMode, Slow
; Chrome changed its fullscreen flash window name making it harder to detect. Only detecting the fact that you are on a chrome window without Crunchyroll in the title.
If WinExist("Adobe Flash Player") or isChomeFS()
{
;sleeping while you watch.
sleep, 1000
return
} else {
IfWinExist , Crunchyroll -,, ;If we find a crunchy roll window we move forward and make sure its active.
{
WinActivate, Crunchyroll -,, ;Activates window.
} else {
; Fall back for detecting Firefox, Chrome, IE detects pop out window as well. It should pick up Opera and Safari but I didn't bother testing. Uses RegEx to reduce the number of seraches.
SetTitleMatchMode, Regex
IfWinExist ,^[Crunchyroll - Watch|Crunchyroll -].*[Mozilla Firefox|Chrome|Internet Explorer|Opera|Safari|]$
{
WinActivate,^[Crunchyroll - Watch|Crunchyroll -].*[Mozilla Firefox]|Chrome|Internet Explorer|Opera|Safari|]$, ;Activates window.
}
}
ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *75 crfs.bmp ;looking for the button.
if ErrorLevel = 0
{
MouseClick, left, %FoundX%+10, %FoundY%+10 ; Click on the fullscreen button.
sleep, 500
MouseMove, 22, 22 ; Get the mouse out of the way.
}
Sleep, 1000 ; make sure we give the window enough time to go fullscreen before checking again.
}
return
;stops the timer
F3::
SetTimer, FSCheck, OFF
return
;closes this app.
F4::ExitApp
;The End.


; full screen check for chrome function
isChomeFS() {
SetTitleMatchMode, Regex
IfWinActive ,^[Crunchyroll - Watch|Crunchyroll -].*Chrome$
{
WinGetPos, Xpos, Ypos, Width, Height,
if (Xpos = 0 && Ypos = 0 && Width = A_ScreenWidth && Height = A_ScreenHeight)
return true
}
return false
}