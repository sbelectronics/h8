y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L scelbal.asm -o scelbal-16450.p -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin scelbal-16450.p scelbal-16450.bin || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L monitor.asm -o monitor-16450.p -D nocinp80 -D frontpanel || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin monitor-16450.p monitor-16450.bin || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L calc.asm -o calc-16450.p -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin calc-16450.p calc-16450.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex calc-16450.p calc-16450.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L shooter.asm -o shooter-16450.p -D nocinp80 -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin shooter-16450.p shooter-16450.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex shooter-16450.p shooter-16450.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L galaxy.asm -o galaxy-16450.p -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin galaxy-16450.p galaxy-16450.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex galaxy-16450.p galaxy-16450.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L hangman.asm -o hangman-16450.p -D nocinp80 -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin hangman-16450.p hangman-16450.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex hangman-16450.p hangman-16450.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L pi-100-digits.asm -o pi-100-digits-16450.p -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin pi-100-digits-16450.p pi-100-digits-16450.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex pi-100-digits-16450.p pi-100-digits-16450.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L pi-1000-digits.asm -o pi-1000-digits-16450.p -D ser16450 || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin pi-1000-digits-16450.p pi-1000-digits-16450.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex pi-1000-digits-16450.p pi-1000-digits-16450.hex || exit /b

REM ---------- bitbang -----------

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L scelbal.asm -o scelbal-bitbang.p -D bitbang -D nocinpne || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin scelbal-bitbang.p scelbal-bitbang.bin || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L monitor.asm -o monitor-bitbang.p -D nocinp80 -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin monitor-bitbang.p monitor-bitbang.bin || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L calc.asm -o calc-bitbang.p -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin calc-bitbang.p calc-bitbang.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex calc-bitbang.p calc-bitbang.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L shooter.asm -o shooter-bitbang.p -D nocinp80 -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin shooter-bitbang.p shooter-bitbang.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex shooter-bitbang.p shooter-bitbang.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L galaxy.asm -o galaxy-bitbang.p -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin galaxy-bitbang.p galaxy-bitbang.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex galaxy-bitbang.p galaxy-bitbang.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L hangman.asm -o hangman-bitbang.p -D nocinp80 -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin hangman-bitbang.p hangman-bitbang.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex hangman-bitbang.p hangman-bitbang.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L pi-100-digits.asm -o pi-100-digits-bitbang.p -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin pi-100-digits-bitbang.p pi-100-digits-bitbang.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex pi-100-digits-bitbang.p pi-100-digits-bitbang.hex || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L pi-1000-digits.asm -o pi-1000-digits-bitbang.p -D bitbang || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin pi-1000-digits-bitbang.p pi-1000-digits-bitbang.bin || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2hex pi-1000-digits-bitbang.p pi-1000-digits-bitbang.hex || exit /b

REM ---------- loaders ------------

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L load-trek.asm || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin load-trek.p load-trek.bin || exit /b

y:\projects\pi\h8\h8-8008\as\bin\asw -i y:\projects\pi\h8\h8-8008\as\include -cpu 8008 -L load-40h.asm || exit /b
y:\projects\pi\h8\h8-8008\as\bin\p2bin load-40h.p load-40h.bin || exit /b