y:\projects\pi\h8\8008\as\bin\asw -i y:\projects\pi\h8\8008\as\include -cpu 8008 -L scelbal-16450.asm || exit /b
y:\projects\pi\h8\8008\as\bin\p2bin scelbal-16450.p scelbal-16450.bin || exit /b

y:\projects\pi\h8\8008\as\bin\asw -i y:\projects\pi\h8\8008\as\include -cpu 8008 -L monitor-16450.asm -D nocinp80 || exit /b
y:\projects\pi\h8\8008\as\bin\p2bin monitor-16450.p monitor-16450.bin || exit /b

y:\projects\pi\h8\8008\as\bin\asw -i y:\projects\pi\h8\8008\as\include -cpu 8008 -L scelbal-in-eprom.asm || exit /b
y:\projects\pi\h8\8008\as\bin\p2bin scelbal-in-eprom.p scelbal-in-eprom.bin || exit /b

y:\projects\pi\h8\8008\as\bin\asw -i y:\projects\pi\h8\8008\as\include -cpu 8008 -L monitor.asm || exit /b
y:\projects\pi\h8\8008\as\bin\p2bin monitor.p monitor.bin || exit /b