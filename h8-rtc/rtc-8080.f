hex
1F constant clkmap_port
7 constant clkin_port
17 constant clkout_port
A0 constant clks1
A1 constant clks10
A2 constant clkm1
A3 constant clkm10
A4 constant clkh1
A5 constant clkh10
A6 constant clkd1
A7 constant clkd10
A8 constant clkmo1
A9 constant clkmo10
AA constant clky1
AB constant clky10
AC constant clkW
AD constant clkCD  ( 30s IRQ BUSY HOLD )
AE constant clkCE  ( t1 t0 itrpt mask )
AF constant clkCF  ( test 24/12 stop reset )

: zeros begin dup 0> while '0' emit 1- repeat drop ;

: u.r0 swap dup uwidth rot swap - zeros U.NP ;

: clk_addr clkmap_port out ;
: clk_in clk_addr clkin_port in F and ;
: clk_out clkout_port out ;

: clk_in clk_addr 0 begin drop clkin_port in dup clkin_port in = until F AND ;

: clk_sec clks10 clk_in 10 * clks1 clk_in + ;
: clk_min clkm10 clk_in 10 * clkm1 clk_in + ;
: clk_hour clkh10 clk_in 10 * clkh1 clk_in + ;

: clk_once clk_hour 2 u.r0 ':' EMIT clk_min 2 u.r0 ':' EMIT clk_sec 2 u.r0 ;

: clk_forever begin clk_once cr again ;


