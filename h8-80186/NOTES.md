Interrupt Vector 0C = INT0 FPANEL-INT1
Interrupt Vector 0D = INT1 UART
Interrupt Vector 0F = INT2 FDC

# Misc Stuff

* The reason zork printed nasty ANSI sequences everywhere. It seems to assume ansi.sys is installed
  when it is not. Edit the setup.inf file to set the third character to "N".

* The reason galways failed on creating the playernews file. Need to increase the "files=" setting in config.sys. GW uses a lot of files.

* GWBasic doesn't work. This is the same as on the SBC188.