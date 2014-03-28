#SingleInstance force
#Persistent 
#NoEnv 
DetectHiddenWindows, On
DetectHiddenText, On
Process, priority, , L ; Low Priority Process.

F2::
Loop,
{

; Works for IE, Chrome and helps prevent detection of any other window with the name Watch. If this fails it will fallback to detecting only by title. 
SetTitleMatchMode, Slow
IfWinExist , Watch, www.crunchyroll.com,
{
WinWaitActive, Watch, www.crunchyroll.com, ;Waits for the window to be the foremost window before it continues.
WinGetPos,,, FFWidth, FFHeight,
} else {
; Fall back for detecting Firefox, Chrome, IE detects popout window aswell. It should pickup Opera and Safari but I didn't bother testing. Uses RegEx to reduce the number of seraches.
SetTitleMatchMode, Regex
IfWinExist ,^[Crunchyroll |]Watch.*[Mozilla Firefox|Chrome|Internet Explorer|Opera|Safari]$
{
WinWaitActive,^[Crunchyroll |]Watch.*[Mozilla Firefox]|Chrome|Internet Explorer|Opera|Safari]$
WinGetPos,,, FFWidth, FFHeight,
}
}
ImageSearch, FoundX, FoundY, 0, 0, %FFWidth%, %FFHeight%, *75 crfs.bmp ;looking for the button.
if ErrorLevel = 0
{
MouseClick, left, %FoundX%+10, %FoundY%+10 ; Click on the fullscreen button.
sleep, 500
MouseMove, 22, 22 ; Get the mouse out of the way.
Sleep, 1000 ; make sure we give the window enough time to go fullscreen before checking again.
} else {
}
}

F3::Pause
F4::ExitApp