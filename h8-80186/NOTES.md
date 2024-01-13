Interrupt Vector 0C = INT0 FPANEL-INT1
Interrupt Vector 0D = INT1 UART
Interrupt Vector 0F = INT2 FDC

# Misc Stuff

* The reason zork printed nasty ANSI sequences everywhere. It seems to assume ansi.sys is installed
  when it is not. Edit the setup.inf file to set the third character to "N".

* The reason galways failed on creating the playernews file. Need to increase the "files=" setting in config.sys. GW uses a lot of files.

* GWBasic doesn't work. This is the same as on the SBC188.

# Serial output stuff

CLS sends the following

```
[22;24;37;40;25m  - 22:normal_intensity, 24:no_uline, 37:fgc=7, 40:bgc=0, 25:noblink
[01;25r           - set window
[25S		  - scroll 25 lines
[r		  - set window?
[01;01H		  - move to row, column