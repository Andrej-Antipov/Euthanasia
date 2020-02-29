# Euthanasia
Correct auto sleep by timer for Mac OS 10.14.6 - 10.15.3+

The helper sleep service

After service is set up, checks monitor power state, with interval according system power settings, 
puts system to sleep with "sudo pmset sleepnow" command after time interval accordind "System Sleep Timer" settings.
Set up, start, stop and remove service with applet. Safely stores password for sudo in system keychain. 
For system (hackintosh) which is not sleep automatically, but can sleep via "apple" menu. ( check is it working?)
Also for mac's that not sleep because the dictation is active.

Last release archive updated with last commits.
