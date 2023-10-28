ASL=/usr/local/bin/asl
P2BIN=/usr/local/bin/p2bin
P2HEX=/usr/local/bin/p2hex
INC=/home/smbaker/projects/pi/h8/h8-8008/as/include
INCDEPS=16450.inc 8251-cons.inc 8251-tape.inc bbser.inc fpanel.inc fpanelvar.inc go-rom.inc h8.inc serial.inc fpanisr.inc

all: scelbal-16450.bin monitor-16450.bin calc-16450.bin shooter-16450.bin galaxy-16450.bin pi-100-digits-16450.bin pi-1000-digits-16450.bin hangman-16450.bin \
     scelbal-bitbang.bin monitor-bitbang.bin calc-bitbang.bin shooter-bitbang.bin galaxy-bitbang.bin pi-100-digits-bitbang.bin pi-1000-digits-bitbang.bin hangman-bitbang.bin \
	 scelbal-8251.bin monitor-8251.bin calc-8251.bin shooter-8251.bin galaxy-8251.bin pi-100-digits-8251.bin pi-1000-digits-8251.bin hangman-8251.bin \
	 scelbal-16450-isr.bin monitor-16450-isr.bin \
	 scelbal-16450-h9term.bin monitor-16450-h9term.bin galaxy-16450-h9term.bin \
	 monitor-8251-sbcfp.bin \
	 load-trek.bin load-40h.bin

#------- 16450 ----------

scelbal-16450.bin: $(INCDEPTS) scelbal.asm
	$(ASL) -i $(INC) -cpu 8008 -L scelbal.asm -o scelbal-16450.p -D ser16450
	$(P2BIN) scelbal-16450.p scelbal-16450.bin

monitor-16450.bin: $(INCDEPS) monitor.asm
	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-16450.p -D nocinp80 -D frontpanel
	$(P2BIN) monitor-16450.p monitor-16450.bin

calc-16450.bin: $(INCDEPTS) calc.asm
	$(ASL) -i $(INC) -cpu 8008 -L calc.asm -o calc-16450.p -D ser16450
	$(P2BIN) calc-16450.p calc-16450.bin
	$(P2HEX) calc-16450.p calc-16450.hex

shooter-16450.bin: $(INCDEPTS) shooter.asm
	$(ASL) -i $(INC) -cpu 8008 -L shooter.asm -o shooter-16450.p -D nocinp80 -D ser16450
	$(P2BIN) shooter-16450.p shooter-16450.bin
	$(P2HEX) shooter-16450.p shooter-16450.hex

galaxy-16450.bin: $(INCDEPTS) galaxy.asm
	$(ASL) -i $(INC) -cpu 8008 -L galaxy.asm -o galaxy-16450.p -D ser16450
	$(P2BIN) galaxy-16450.p galaxy-16450.bin
	$(P2HEX) galaxy-16450.p galaxy-16450.hex

hangman-16450.bin: $(INCDEPTS) hangman.asm
	$(ASL) -i $(INC) -cpu 8008 -L hangman.asm -o hangman-16450.p -D nocinp80 -D ser16450
	$(P2BIN) hangman-16450.p hangman-16450.bin
	$(P2HEX) hangman-16450.p hangman-16450.hex

pi-100-digits-16450.bin: $(INCDEPTS) pi-100-digits.asm
	$(ASL) -i $(INC) -cpu 8008 -L pi-100-digits.asm -o pi-100-digits-16450.p -D ser16450
	$(P2BIN) pi-100-digits-16450.p pi-100-digits-16450.bin
	$(P2HEX) pi-100-digits-16450.p pi-100-digits-16450.hex

pi-1000-digits-16450.bin: $(INCDEPTS) pi-1000-digits.asm
	$(ASL) -i $(INC) -cpu 8008 -L pi-1000-digits.asm -o pi-1000-digits-16450.p -D ser16450
	$(P2BIN) pi-1000-digits-16450.p pi-1000-digits-16450.bin
	$(P2HEX) pi-1000-digits-16450.p pi-1000-digits-16450.hex

#------- 16450 - uppercase ----------

scelbal-16450-h9term.bin: $(INCDEPTS) scelbal.asm
	$(ASL) -i $(INC) -cpu 8008 -L scelbal.asm -o scelbal-16450-h9term.p -D ser16450 -D forceupper -D baud600
	$(P2BIN) scelbal-16450-h9term.p scelbal-16450-h9term.bin

monitor-16450-h9term.bin: $(INCDEPS) monitor.asm
	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-16450-h9term.p -D nocinp80 -D frontpanel -D forceupper -D baud600
	$(P2BIN) monitor-16450-h9term.p monitor-16450-h9term.bin

galaxy-16450-h9term.bin: $(INCDEPTS) galaxy.asm
	$(ASL) -i $(INC) -cpu 8008 -L galaxy.asm -o galaxy-16450-h9term.p -D ser16450 -D forceupper -D baud600
	$(P2BIN) galaxy-16450-h9term.p galaxy-16450-h9term.bin
	$(P2HEX) galaxy-16450-h9term.p galaxy-16450-h9term.hex

#------- 16450 - sbcfp ----------

#monitor-16450-sbcfp.bin: $(INCDEPS) monitor.asm
#	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-16450-sbcfp.p -D nocinp80 -D sbcfp -D frontpanel
#	$(P2BIN) monitor-16450-sbcfp.p monitor-16450-sbcfp.bin

monitor-8251-sbcfp.bin: $(INCDEPS) monitor.asm
	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-8251-sbcfp.p -D nocinp80 -D sbcfp -D fp8251 -D noiomap -D sound
	$(P2BIN) monitor-8251-sbcfp.p monitor-8251-sbcfp.bin

#------- 16450-fp-isr ----------

scelbal-16450-isr.bin: $(INCDEPTS) scelbal.asm
	$(ASL) -i $(INC) -cpu 8008 -L scelbal.asm -o scelbal-16450-isr.p -D frontpanel_isr  -D nofrontpanel
	$(P2BIN) scelbal-16450-isr.p scelbal-16450-isr.bin

monitor-16450-isr.bin: $(INCDEPS) monitor.asm
	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-16450-isr.p -D nocinp80 -D frontpanel_isr
	$(P2BIN) monitor-16450-isr.p monitor-16450-isr.bin


#------- bitbang ----------

scelbal-bitbang.bin: $(INCDEPTS) scelbal.asm
	$(ASL) -i $(INC) -cpu 8008 -L scelbal.asm -o scelbal-bitbang.p -D bitbang -D nocinpne
	$(P2BIN) scelbal-bitbang.p scelbal-bitbang.bin

monitor-bitbang.bin: $(INCDEPS) monitor.asm
	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-bitbang.p -D nocinp80 -D bitbang
	$(P2BIN) monitor-bitbang.p monitor-bitbang.bin

calc-bitbang.bin: $(INCDEPTS) calc.asm
	$(ASL) -i $(INC) -cpu 8008 -L calc.asm -o calc-bitbang.p -D bitbang
	$(P2BIN) calc-bitbang.p calc-bitbang.bin
	$(P2HEX) calc-bitbang.p calc-bitbang.hex

shooter-bitbang.bin: $(INCDEPTS) shooter.asm
	$(ASL) -i $(INC) -cpu 8008 -L shooter.asm -o shooter-bitbang.p -D nocinp80 -D bitbang
	$(P2BIN) shooter-bitbang.p shooter-bitbang.bin
	$(P2HEX) shooter-bitbang.p shooter-bitbang.hex

galaxy-bitbang.bin: $(INCDEPTS) galaxy.asm
	$(ASL) -i $(INC) -cpu 8008 -L galaxy.asm -o galaxy-bitbang.p -D bitbang
	$(P2BIN) galaxy-bitbang.p galaxy-bitbang.bin
	$(P2HEX) galaxy-bitbang.p galaxy-bitbang.hex

hangman-bitbang.bin: $(INCDEPTS) hangman.asm
	$(ASL) -i $(INC) -cpu 8008 -L hangman.asm -o hangman-bitbang.p -D nocinp80 -D bitbang
	$(P2BIN) hangman-bitbang.p hangman-bitbang.bin
	$(P2HEX) hangman-bitbang.p hangman-bitbang.hex

pi-100-digits-bitbang.bin: $(INCDEPTS) pi-100-digits.asm
	$(ASL) -i $(INC) -cpu 8008 -L pi-100-digits.asm -o pi-100-digits-bitbang.p -D bitbang
	$(P2BIN) pi-100-digits-bitbang.p pi-100-digits-bitbang.bin
	$(P2HEX) pi-100-digits-bitbang.p pi-100-digits-bitbang.hex

pi-1000-digits-bitbang.bin: $(INCDEPTS) pi-1000-digits.asm
	$(ASL) -i $(INC) -cpu 8008 -L pi-1000-digits.asm -o pi-1000-digits-bitbang.p -D bitbang
	$(P2BIN) pi-1000-digits-bitbang.p pi-1000-digits-bitbang.bin
	$(P2HEX) pi-1000-digits-bitbang.p pi-1000-digits-bitbang.hex

#------- 8251 ----------

scelbal-8251.bin: $(INCDEPTS) scelbal.asm
	$(ASL) -i $(INC) -cpu 8008 -L scelbal.asm -o scelbal-8251.p -D ser8251
	$(P2BIN) scelbal-8251.p scelbal-8251.bin

monitor-8251.bin: $(INCDEPS) monitor.asm
	$(ASL) -i $(INC) -cpu 8008 -L monitor.asm -o monitor-8251.p -D nocinp80 -D ser8251
	$(P2BIN) monitor-8251.p monitor-8251.bin

calc-8251.bin: $(INCDEPTS) calc.asm
	$(ASL) -i $(INC) -cpu 8008 -L calc.asm -o calc-8251.p -D ser8251
	$(P2BIN) calc-8251.p calc-8251.bin
	$(P2HEX) calc-8251.p calc-8251.hex

shooter-8251.bin: $(INCDEPTS) shooter.asm
	$(ASL) -i $(INC) -cpu 8008 -L shooter.asm -o shooter-8251.p -D nocinp80 -D ser8251
	$(P2BIN) shooter-8251.p shooter-8251.bin
	$(P2HEX) shooter-8251.p shooter-8251.hex

galaxy-8251.bin: $(INCDEPTS) galaxy.asm
	$(ASL) -i $(INC) -cpu 8008 -L galaxy.asm -o galaxy-8251.p -D ser8251
	$(P2BIN) galaxy-8251.p galaxy-8251.bin
	$(P2HEX) galaxy-8251.p galaxy-8251.hex

hangman-8251.bin: $(INCDEPTS) hangman.asm
	$(ASL) -i $(INC) -cpu 8008 -L hangman.asm -o hangman-8251.p -D nocinp80 -D ser8251
	$(P2BIN) hangman-8251.p hangman-8251.bin
	$(P2HEX) hangman-8251.p hangman-8251.hex

pi-100-digits-8251.bin: $(INCDEPTS) pi-100-digits.asm
	$(ASL) -i $(INC) -cpu 8008 -L pi-100-digits.asm -o pi-100-digits-8251.p -D ser8251
	$(P2BIN) pi-100-digits-8251.p pi-100-digits-8251.bin
	$(P2HEX) pi-100-digits-8251.p pi-100-digits-8251.hex

pi-1000-digits-8251.bin: $(INCDEPTS) pi-1000-digits.asm
	$(ASL) -i $(INC) -cpu 8008 -L pi-1000-digits.asm -o pi-1000-digits-8251.p -D ser8251
	$(P2BIN) pi-1000-digits-8251.p pi-1000-digits-8251.bin
	$(P2HEX) pi-1000-digits-8251.p pi-1000-digits-8251.hex

#---------- loaders ---------

load-trek.bin: $(INCDEPTS) rom2ram.inc load-trek.asm
	$(ASL) -i $(INC) -cpu 8008 -L load-trek.asm -o load-trek.p
	$(P2BIN) load-trek.p load-trek.bin

load-40h.bin: $(INCDEPTS) rom2ram.inc load-40h.asm
	$(ASL) -i $(INC) -cpu 8008 -L load-40h.asm -o load-40h.p
	$(P2BIN) load-40h.p load-40h.bin

clean:
	rm -f *.p *.bin *.hex *.lst

rom:
	cd ../rom && make
