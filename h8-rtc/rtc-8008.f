hex
1E constant clkmap_data_port
1F constant clkmap_addr_port
6 constant clkin_port
16 constant clkout_port
17 constant clkaddr_port
0 constant clks1
1 constant clks10
2 constant clkm1
3 constant clkm10
4 constant clkh1
5 constant clkh10
6 constant clkd1
7 constant clkd10
8 constant clkmo1
9 constant clkmo10
A constant clky1
B constant clky10
C constant clkW
D constant clkCD  ( 30s IRQ BUSY HOLD )
E constant clkCE  ( t1 t0 itrpt mask )
F constant clkCF  ( test 24/12 stop reset )

: map_ports A0 clkmap_data_port out A1 clkmap_addr_port out ;

: zeros begin dup 0> while '0' emit 1- repeat drop ;

: u.r0 swap dup uwidth rot swap - zeros U.NP ;

: clk_addr clkaddr_port out ;
: clk_inp clk_addr clkin_port in F and ;
: clk_outp clkout_port out ;

: clk_in clk_addr 0 begin drop clkin_port in dup clkin_port in = until F AND ;
: clk_out clk_addr clkout_port out ;

: clk_sec clks10 clk_in 10 * clks1 clk_in + ;
: clk_min clkm10 clk_in 10 * clkm1 clk_in + ;
: clk_hour clkh10 clk_in 10 * clkh1 clk_in + ;

: clk_sec_set dup 10 / clks10 clk_out F and clks1 clk_out ;
: clk_min_set dup 10 / clkm10 clk_out F and clkm1 clk_out ;
: clk_hour_set dup 10 / clkh10 clk_out F and clkh1 clk_out ;

: clk_once clk_hour 2 u.r0 ':' EMIT clk_min 2 u.r0 ':' EMIT clk_sec 2 u.r0 ;

: clk_forever begin clk_once 0D emit again ;


