----------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije                  --
--  Copyright © 2009 ALL Rights Reserved                                        --
----------------------------------------------------------------------------------
--                                                                              --
-- Autor: LPRS2 TIM 2009/2010 <LPRS2@KRT.neobee.net>                            --
--                                                                              --
-- Datum izrade: /                                                              --
-- Naziv Modula: top.vhd                                                        --
-- Naziv projekta: LabVezba5                                                    --
--                                                                              --
-- Opis: vrh hijerarhije koji objedinjuje sve komponente                        --
--                                                                              --
-- Ukljucuje module: myrisc,dp_mem,regField,vga_sync,char_rom                   --
--                                                                              --
-- Verzija : 1.0                                                                --
--                                                                              --
-- Dodatni komentari: /                                                         --
--                                                                              --
-- ULAZI: FPGA_CLK                                                              --
--        FPGA_RESET                                                            --
--        PS2_MCLK                                                              --
--        PS2_MDATA                                                             --
--        UI_JOY0                                                               --
--        UI_JOY1                                                               --
--        UI_JOY3                                                               --
--        UI_JOY4                                                               --
--        UI_SW0                                                                --
--        UI_SW1                                                                --
--        UI_SW2                                                                --
--        UI_SW3                                                                --
--        UI_SW4                                                                --
--        UI_SW5                                                                --
--        UI_SW6                                                                --
--        UI_SW7                                                                --
--                                                                              --
--                                                                              --
-- IZLAZI: VGA_HSYNC                                                            --
--         VGA_VSYNC                                                            --
--         BLANK                                                                --
--         PIX_CLOCK                                                            --
--         PSAVE                                                                --
--         SYNC                                                                 --
--         RED0                                                                 --
--         RED1                                                                 --
--         RED2                                                                 --
--         RED3                                                                 --
--         RED4                                                                 --
--         RED5                                                                 --
--         RED6                                                                 --
--         RED7                                                                 --
--         GREEN0                                                               --
--         GREEN1                                                               --
--         GREEN2                                                               --
--         GREEN3                                                               --
--         GREEN4                                                               --
--         GREEN5                                                               --
--         GREEN6                                                               --
--         GREEN7                                                               --
--         BLUE0                                                                --
--         BLUE1                                                                --
--         BLUE2                                                                --
--         BLUE3                                                                --
--         BLUE4                                                                --
--         BLUE5                                                                --
--         BLUE6                                                                --
--         BLUE7                                                                --
--         UI_LED0                                                              --
--         UI_LED1                                                              --
--         UI_LED2                                                              --
--         UI_LED3                                                              --
--         UI_LED4                                                              --
--         UI_LED5                                                              --
--         UI_LED6                                                              --
--         UI_LED7                                                              --
--         LCD_IO0                                                              --
--         LCD_IO1                                                              --
--         LCD_IO2                                                              --
--         LCD_IO3                                                              --
--         LCD_IO4                                                              --
--         LCD_IO5                                                              --
--         LCD_IO6                                                              --
--         LCD_IO7                                                              --
--                                                                              --
-- PARAMETRI : /                                                                --
--                                                                              --
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY WORK;
USE WORK.RISCPACKAGE.ALL;
USE WORK.CHARPACKAGE.ALL;

ENTITY top      IS PORT (
                         FPGA_CLK      : IN  STD_LOGIC;
                         FPGA_RESET    : IN  STD_LOGIC;
                         -- tasteri
                         UI_JOY0       : IN  STD_LOGIC;
                         UI_JOY1       : IN  STD_LOGIC;
                         UI_JOY3       : IN  STD_LOGIC;
                         UI_JOY4       : IN  STD_LOGIC;
                         -- predikaci
                         UI_SW0        : IN  STD_LOGIC;
                         UI_SW1        : IN  STD_LOGIC;
                         UI_SW2        : IN  STD_LOGIC;
                         UI_SW3        : IN  STD_LOGIC;
                         UI_SW4        : IN  STD_LOGIC;
                         UI_SW5        : IN  STD_LOGIC;
                         UI_SW6        : IN  STD_LOGIC;
                         UI_SW7        : IN  STD_LOGIC;
                         -- led
                         UI_LED0       : OUT STD_LOGIC;
                         UI_LED1       : OUT STD_LOGIC;
                         UI_LED2       : OUT STD_LOGIC;
                         UI_LED3       : OUT STD_LOGIC;
                         UI_LED4       : OUT STD_LOGIC;
                         UI_LED5       : OUT STD_LOGIC;
                         UI_LED6       : OUT STD_LOGIC;
                         UI_LED7       : OUT STD_LOGIC;
                         -- lcd
                         LCD_IO0       : OUT STD_LOGIC;
                         LCD_IO1       : OUT STD_LOGIC;
                         LCD_IO2       : OUT STD_LOGIC;
                         LCD_IO3       : OUT STD_LOGIC;
                         LCD_IO4       : OUT STD_LOGIC;
                         LCD_IO5       : OUT STD_LOGIC;
                         LCD_IO6       : OUT STD_LOGIC;
                         LCD_IO7       : OUT STD_LOGIC;
                         -- vga
                         VGA_HSYNC     : OUT STD_LOGIC;
                         VGA_VSYNC     : OUT STD_LOGIC;
                         BLANK         : OUT STD_LOGIC;
                         PIX_CLOCK     : OUT STD_LOGIC;
                         PSAVE         : OUT STD_LOGIC;
                         SYNC          : OUT STD_LOGIC;
                         RED0          : OUT STD_LOGIC;
                         RED1          : OUT STD_LOGIC;
                         RED2          : OUT STD_LOGIC;
                         RED3          : OUT STD_LOGIC;
                         RED4          : OUT STD_LOGIC;
                         RED5          : OUT STD_LOGIC;
                         RED6          : OUT STD_LOGIC;
                         RED7          : OUT STD_LOGIC;
                         GREEN0        : OUT STD_LOGIC;
                         GREEN1        : OUT STD_LOGIC;
                         GREEN2        : OUT STD_LOGIC;
                         GREEN3        : OUT STD_LOGIC;
                         GREEN4        : OUT STD_LOGIC;
                         GREEN5        : OUT STD_LOGIC;
                         GREEN6        : OUT STD_LOGIC;
                         GREEN7        : OUT STD_LOGIC;
                         BLUE0         : OUT STD_LOGIC;
                         BLUE1         : OUT STD_LOGIC;
                         BLUE2         : OUT STD_LOGIC;
                         BLUE3         : OUT STD_LOGIC;
                         BLUE4         : OUT STD_LOGIC;
                         BLUE5         : OUT STD_LOGIC;
                         BLUE6         : OUT STD_LOGIC;
                         BLUE7         : OUT STD_LOGIC
                        );
END top;

ARCHITECTURE rtl OF top IS

  COMPONENT myrisc IS PORT (
                            Clk        : IN    STD_LOGIC;
                            Reset      : IN    STD_LOGIC;
                            Bus_Data   : INOUT TypeWord ;
                            Bus_Addr   : OUT   TypeWord ;
                            Bus_Rd_n   : OUT   STD_LOGIC;
                            Bus_Wr_n   : OUT   STD_LOGIC;
                            Init_n     : IN    STD_LOGIC;
                            Rdy_n      : IN    STD_LOGIC;
                            oReg       : OUT   TypeArrayWord(7 DOWNTO 0)    ;
                            IP         : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
                            Instr      : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
                            ALU        : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0)
                           );
  END COMPONENT myrisc;

  COMPONENT dp_mem PORT (
                         addra     : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
                         addrb     : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
                         clka      : IN  STD_LOGIC                    ;
                         clkb      : IN  STD_LOGIC                    ;
                         dina      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                         dinb      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                         douta     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                         doutb     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                         wea       : IN  STD_LOGIC_VECTOR(0 downto 0);
                         web       : IN  STD_LOGIC_VECTOR(0 downto 0)
                        );
  END COMPONENT;

  COMPONENT regField IS GENERIC (
                                 SIZE : INTEGER := 4
                                );
                          PORT (
                                clk_i         : IN  STD_LOGIC                    ;
                                addr_i        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                                data_i        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                                wr_en_n_i     : IN  STD_LOGIC                    ;
                                in_switch_i   : IN  STD_LOGIC_VECTOR(7  DOWNTO 0);
                                in_joy_i      : IN  STD_LOGIC_VECTOR(3  DOWNTO 0);
                                selected_i    : OUT STD_LOGIC                    ;
                                data_o        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                                outLED        : OUT STD_LOGIC_VECTOR(7  DOWNTO 0);
                                lcd_o         : OUT STD_LOGIC_VECTOR(7  DOWNTO 0)
                               );
  END COMPONENT;

COMPONENT vga_sync IS PORT (
                            clk_i          : IN   STD_LOGIC;                        -- takt
                            rst_n_i        : IN   STD_LOGIC;                        -- reset
                            red_i          : IN   STD_LOGIC;                        -- ulazna  vrednost crvene boje
                            green_i        : IN   STD_LOGIC;                        -- ulazna  vrednost zelene boje
                            blue_i         : IN   STD_LOGIC;                        -- ulazna  vrednost plave  boje
                            red_o          : OUT  STD_LOGIC;                        -- izlazna vrednost crvene boje
                            green_o        : OUT  STD_LOGIC;                        -- izlazna vrednost zelene boje
                            blue_o         : OUT  STD_LOGIC;                        -- izlazna vrednost plave  boje
                            pixel_row_o    : OUT  STD_LOGIC_VECTOR (10 DOWNTO 0);   -- pozicija pixela po vrstama
                            pixel_column_o : OUT  STD_LOGIC_VECTOR (10 DOWNTO 0);   -- pozicija pixela po kolonama
                            horiz_sync_o   : OUT  STD_LOGIC;                        -- horizontalna sinhronizacija
                            vert_sync_o    : OUT  STD_LOGIC;                        -- vertikalna   sinhronizacija
                            psave_o        : OUT  STD_LOGIC;                        -- signal kontrole napajanja, MORA uvek na visokom logickom nivou
                            blank_o        : OUT  STD_LOGIC;                        -- aktivni deo linije
                            pix_clk_o      : OUT  STD_LOGIC;                        -- takt sa kojim je sinhronizovano ispisivanje pixela
                            sync_o         : OUT  STD_LOGIC                         -- sjedinjena vertikalna i horizontalna sinhronizacija
                           );

END COMPONENT vga_sync;


COMPONENT vga IS GENERIC (
                          resolution_type : INTEGER  := 0
                         );
              PORT(
                   clk_i          : IN  STD_LOGIC;                       -- takt
                   rst_n_i        : IN  STD_LOGIC;                       -- reset
                   red_i          : IN  STD_LOGIC;                       -- ulazna  vrednost crvene boje
                   green_i        : IN  STD_LOGIC;                       -- ulazna  vrednost zelene boje
                   blue_i         : IN  STD_LOGIC;                       -- ulazna  vrednost plave  boje
                   red_o          : OUT STD_LOGIC;                       -- izlazna vrednost crvene boje
                   green_o        : OUT STD_LOGIC;                       -- izlazna vrednost zelene boje
                   blue_o         : OUT STD_LOGIC;                       -- izlazna vrednost plave  boje
                   pixel_row_o    : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);   -- pozicija pixela po vrstama
                   pixel_column_o : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);   -- pozicija pixela po kolonama
                   hsync_o        : OUT STD_LOGIC;                       -- horizontalna sinhronizacija
                   vsync_o        : OUT STD_LOGIC;                       -- vertikalna   sinhronizacija
                   psave_o        : OUT STD_LOGIC;                       -- signal kontrole napajanja, MORA uvek na visokom logickom nivou
                   blank_o        : OUT STD_LOGIC;                       -- aktivni deo linije
                   vga_pix_clk_o  : OUT STD_LOGIC;                       -- takt sa kojim je sinhronizovano ispisivanje pixela
                   vga_rst_n_o    : OUT STD_LOGIC;                       -- reset sinhronizovan sa vga_pix_clk_o taktom
                   sync_o         : OUT STD_LOGIC                        -- sjedinjena vertikalna i horizontalna sinhronizacija
                 );
END COMPONENT vga;



  COMPONENT char_rom IS PORT(
                             clk_i                : IN   STD_LOGIC                    ;
                             character_address_i  : IN   STD_LOGIC_VECTOR (5 DOWNTO 0);
                             font_row_i           : IN   STD_LOGIC_VECTOR (2 DOWNTO 0);
                             font_col_i           : IN   STD_LOGIC_VECTOR (2 DOWNTO 0);
                             rom_mux_output_o     : OUT  STD_LOGIC
                            );
  END COMPONENT;

-------------------------------------------------------------------------------

  SIGNAL  bus_data_s       : TypeWord;
  SIGNAL  mem_in_s         : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL  mem_out_s        : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL  bus_addr_s       : TypeWord;
  SIGNAL  bus_wr_n         : STD_LOGIC_VECTOR(0 downto 0);
  SIGNAL  mem_clk_s        : STD_LOGIC;
  SIGNAL  clk_pad_s        : STD_LOGIC;
  SIGNAL  reset_s          : STD_LOGIC;
  SIGNAL  rf_in_s          : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL  rf_out_s         : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL  rf_sel_s         : STD_LOGIC;
  SIGNAL  mem_rf_data_s    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL  init_n_s         : STD_LOGIC;

  SIGNAL ip_s              : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL instr_s           : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL alu_s             : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL regs_s            : TypeArrayWord(7 DOWNTO 0);

  SIGNAL my_clk_s          : STD_LOGIC;
  SIGNAL clk_counter_s     : STD_LOGIC_VECTOR(17 DOWNTO 0);
  SIGNAL clock_91_hz_s     : STD_LOGIC;
  SIGNAL shift_pb_s        : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL joy_0_debounced_s : STD_LOGIC;

  SIGNAL red_in_s          : STD_LOGIC;
  SIGNAL blue_in_s         : STD_LOGIC;
  SIGNAL green_in_s        : STD_LOGIC;
  SIGNAL red_out_s         : STD_LOGIC;
  SIGNAL blue_out_s        : STD_LOGIC;
  SIGNAL green_out_s       : STD_LOGIC;
  SIGNAL row_s             : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SIGNAL column_s          : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SIGNAL clk_25_mhz_s      : STD_LOGIC;

  SIGNAL rom_mux_output_s  : STD_LOGIC;
  SIGNAL char_addr_s       : STD_LOGIC_VECTOR(5 DOWNTO 0);

  ALIAS char_row_s    IS row_s   (9  DOWNTO 4);
  ALIAS char_column_s IS column_s(10 DOWNTO 4);

  SIGNAL  inSwitch_s        : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  inJoy_s           : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL  outLED_s          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  outLCD_s          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  out_red_s         : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  out_blue_s        : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  out_green_s       : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  out_horiz_sync_s  : STD_LOGIC;
  SIGNAL  out_vert_sync_s   : STD_LOGIC;
  SIGNAL  out_psave_s       : STD_LOGIC;
  SIGNAL  out_blank_s       : STD_LOGIC;
  SIGNAL  out_pix_clk_s     : STD_LOGIC;
  SIGNAL  out_sync_s        : STD_LOGIC;
  SIGNAL  tc_s              : STD_LOGIC;
  SIGNAL  vga_n_rst_s       : STD_LOGIC;
  
  SIGNAL  wea               : STD_LOGIC_VECTOR(0 downto 0);
  SIGNAL  web               : STD_LOGIC_VECTOR(0 downto 0);
  ----------------------------------------------------------
------------------------------------------------------------

BEGIN


  mem1 : dp_mem PORT MAP (
                          addra  => bus_addr_s(13 DOWNTO 2),
                          addrb  => bus_addr_s(13 DOWNTO 2),
                          clka   => mem_clk_s              ,
                          clkb   => mem_clk_s              ,
                          dina   => mem_in_s               ,
                          dinb   => (OTHERS => '0')        ,
                          douta  => OPEN                   ,
                          doutb  => mem_out_s              ,
                          wea    => wea                    ,
                          web    => web
                        );

 wea <= not bus_wr_n;
 web <= (others => '0');
 
  dut : myrisc PORT MAP (
                         Clk        =>  my_clk_s  ,
                         Reset      =>  reset_s   ,
                         Bus_Data   =>  bus_data_s,
                         Bus_Addr   =>  bus_addr_s,
                         Bus_Rd_n   =>  OPEN      ,
                         Bus_Wr_n   =>  bus_wr_n(0),
                         Init_n     =>  init_n_s  ,
                         Rdy_n      =>  '1'       ,
                         oReg       =>  regs_s    ,
                         IP         =>  ip_s      ,
                         Instr      =>  instr_s   ,
                         ALU        =>  alu_s
                        );

  rf : regField GENERIC MAP (
                             SIZE => 4
                            )
                  PORT MAP (
                            clk_i       => mem_clk_s ,
                            addr_i      => bus_addr_s,
                            data_i      => rf_in_s   ,
                            wr_en_n_i   => bus_wr_n(0),
                            in_switch_i => inSwitch_s,
                            in_joy_i    => inJoy_s   ,
                            selected_i  => rf_sel_s  ,
                            data_o      => rf_out_s  ,
                            outLED      => outLED_s  ,
                            lcd_o       => outLCD_s
                           );

  vga_i:vga GENERIC MAP(
                         resolution_type => 0
                       )
              PORT MAP (
                         clk_i           => FPGA_CLK        ,
                         rst_n_i         => FPGA_RESET      ,
                         red_i           => red_in_s        ,
                         green_i         => green_in_s      ,
                         blue_i          => blue_in_s       ,
                         red_o           => red_out_s       ,
                         green_o         => green_out_s     ,
                         blue_o          => blue_out_s      ,
                         pixel_row_o     => row_s           ,
                         pixel_column_o  => column_s        ,
                         hsync_o         => out_horiz_sync_s,
                         vsync_o         => out_vert_sync_s ,
                         psave_o         => out_psave_s     ,
                         blank_o         => out_blank_s     ,
                         vga_pix_clk_o   => out_pix_clk_s   ,
                         vga_rst_n_o     => vga_n_rst_s     ,
                         sync_o          => out_sync_s
                       );


  crom : char_rom PORT MAP (
                            clk_i                 => out_pix_clk_s       ,
                            character_address_i   => char_addr_s         ,
                            font_row_i            => row_s(3 DOWNTO 1)   ,
                            font_col_i            => column_s(3 DOWNTO 1),
                            rom_mux_output_o      => rom_mux_output_s
                           );




  inSwitch_s(0) <= UI_SW0;
  inSwitch_s(1) <= UI_SW1;
  inSwitch_s(2) <= UI_SW2;
  inSwitch_s(3) <= UI_SW3;
  inSwitch_s(4) <= UI_SW4;
  inSwitch_s(5) <= UI_SW5;
  inSwitch_s(6) <= UI_SW6;
  inSwitch_s(7) <= UI_SW7;

  inJoy_s(0)    <= UI_JOY0;
  inJoy_s(1)    <= UI_JOY1;
  inJoy_s(2)    <= UI_JOY3;
  inJoy_s(3)    <= UI_JOY4;

  UI_LED0       <= outLED_s(0);
  UI_LED1       <= outLED_s(1);
  UI_LED2       <= outLED_s(2);
  UI_LED3       <= outLED_s(3);
  UI_LED4       <= outLED_s(4);
  UI_LED5       <= outLED_s(5);
  UI_LED6       <= outLED_s(6);
  UI_LED7       <= outLED_s(7);

  LCD_IO0       <= outLCD_s(0);
  LCD_IO1       <= outLCD_s(1);
  LCD_IO2       <= outLCD_s(2);
  LCD_IO3       <= outLCD_s(3);
  LCD_IO4       <= outLCD_s(4);
  LCD_IO5       <= outLCD_s(5);
  LCD_IO6       <= outLCD_s(6);
  LCD_IO7       <= outLCD_s(7);

  RED0          <= out_red_s(0);
  RED1          <= out_red_s(1);
  RED2          <= out_red_s(2);
  RED3          <= out_red_s(3);
  RED4          <= out_red_s(4);
  RED5          <= out_red_s(5);
  RED6          <= out_red_s(6);
  RED7          <= out_red_s(7);

  GREEN0        <= out_green_s(0);
  GREEN1        <= out_green_s(1);
  GREEN2        <= out_green_s(2);
  GREEN3        <= out_green_s(3);
  GREEN4        <= out_green_s(4);
  GREEN5        <= out_green_s(5);
  GREEN6        <= out_green_s(6);
  GREEN7        <= out_green_s(7);

  BLUE0         <= out_blue_s(0);
  BLUE1         <= out_blue_s(1);
  BLUE2         <= out_blue_s(2);
  BLUE3         <= out_blue_s(3);
  BLUE4         <= out_blue_s(4);
  BLUE5         <= out_blue_s(5);
  BLUE6         <= out_blue_s(6);
  BLUE7         <= out_blue_s(7);

  VGA_HSYNC     <= out_horiz_sync_s;
  VGA_VSYNC     <= out_vert_sync_s;
  BLANK         <= out_blank_s;
  PIX_CLOCK     <= out_pix_clk_s;
  PSAVE         <= out_psave_s;
  SYNC          <= out_sync_s;

  -------------------------------------------------------------

  mem_rf_data_s <= rf_out_s      WHEN rf_sel_s    = '1' ELSE mem_out_s;
  mem_in_s      <= bus_data_s    WHEN bus_wr_n(0) = '0' ELSE (OTHERS => 'Z');
  rf_in_s       <= bus_data_s    WHEN bus_wr_n(0) = '0' ELSE (OTHERS => 'Z');
  bus_data_s    <= mem_rf_data_s WHEN bus_wr_n(0) = '1' ELSE (OTHERS => 'Z');

-------------------------------------------------------------------------------

    out_red_s   <= "11111111" WHEN red_out_s   = '1' ELSE "00000000";
    out_green_s <= "11111111" WHEN green_out_s = '1' ELSE "00000000";
    out_blue_s  <= "11111111" WHEN blue_out_s  = '1' ELSE "00000000";

    red_in_s    <= rom_mux_output_s;
    green_in_s  <= rom_mux_output_s;
    blue_in_s   <= '1';

-----------------------------------------------------------------------------------------

PROCESS(out_pix_clk_s)
  BEGIN

    IF(out_pix_clk_s'EVENT AND out_pix_clk_s='1') THEN

      IF  (vga_n_rst_s = '0') THEN   clk_counter_s <= (OTHERS => '0');
      ELSE                           clk_counter_s <= clk_counter_s + 1;
      END IF;

   END IF;
END PROCESS;

PROCESS (clk_counter_s)
  BEGIN

    IF (clk_counter_s = "111111111111111111" ) THEN tc_s <= '1';
    ELSE                                            tc_s <= '0';
    END IF;

END PROCESS;

PROCESS(out_pix_clk_s)
  BEGIN
    IF (out_pix_clk_s'EVENT AND out_pix_clk_s = '1') THEN

      IF (vga_n_rst_s = '0') THEN

         shift_pb_s <= (OTHERS => '0');

     ELSIF ( tc_s ='1' ) THEN

        shift_pb_s(2 DOWNTO 0) <= shift_pb_s(3 DOWNTO 1);
        shift_pb_s(3) <= inJoy_s(0);

    END IF;
   END IF;


END PROCESS;


PROCESS (shift_pb_s)
  BEGIN

        IF ( shift_pb_s(3 DOWNTO 0) = "0000" ) THEN joy_0_debounced_s <= '0';
        ELSE                                        joy_0_debounced_s <= '1';
        END IF;

END PROCESS;


  my_clk_s     <= joy_0_debounced_s;
  mem_clk_s    <= NOT(my_clk_s);
  reset_s      <= NOT(vga_n_rst_s);
  init_n_s     <= vga_n_rst_s;


-----------------------------------------------------------------------------------------

  -- output FOR VGA
  PROCESS(
          char_row_s    ,
          char_column_s ,
          regs_s(7)     ,
          regs_s(6)     ,
          regs_s(5)     ,
          regs_s(4)     ,
          regs_s(3)     ,
          regs_s(2)     ,
          regs_s(1)     ,
          regs_s(0)     ,
          instr_s       ,
          alu_s         ,
          ip_s
          )
  BEGIN
    IF(char_row_s = 1) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 12     => char_addr_s <= ADDR_M;
        WHEN 13     => char_addr_s <= ADDR_Y;
        WHEN 14     => char_addr_s <= ADDR_R;
        WHEN 15     => char_addr_s <= ADDR_I;
        WHEN 16     => char_addr_s <= ADDR_S;
        WHEN 17     => char_addr_s <= ADDR_C;
        WHEN 20     => char_addr_s <= ADDR_D;
        WHEN 21     => char_addr_s <= ADDR_E;
        WHEN 22     => char_addr_s <= ADDR_B;
        WHEN 23     => char_addr_s <= ADDR_U;
        WHEN 24     => char_addr_s <= ADDR_G;
        WHEN 25     => char_addr_s <= ADDR_G;
        WHEN 26     => char_addr_s <= ADDR_E;
        WHEN 27     => char_addr_s <= ADDR_R;
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSIF(char_row_s = 2) THEN

      IF(char_column_s >= 12 AND char_column_s <= 27) THEN  char_addr_s <= ADDR_minus;
      ELSE                                                  char_addr_s <= ADDR_space;
      END IF;

    ELSIF(char_row_s = 4) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 15     => char_addr_s <= ADDR_R;
        WHEN 16     => char_addr_s <= ADDR_E;
        WHEN 17     => char_addr_s <= ADDR_G;
        WHEN 18     => char_addr_s <= ADDR_I;
        WHEN 19     => char_addr_s <= ADDR_S;
        WHEN 20     => char_addr_s <= ADDR_T;
        WHEN 21     => char_addr_s <= ADDR_E;
        WHEN 22     => char_addr_s <= ADDR_R;
        WHEN 23     => char_addr_s <= ADDR_S;
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSIF(char_row_s >= 6 AND char_row_s <= 13) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 14     => char_addr_s <= ADDR_dollar;
        WHEN 15     => char_addr_s <= ADDR_1 + (char_row_s - 6);
        WHEN 17     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(31 DOWNTO 28);
        WHEN 18     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(27 DOWNTO 24);
        WHEN 19     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(23 DOWNTO 20);
        WHEN 20     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(19 DOWNTO 16);
        WHEN 21     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(15 DOWNTO 12);
        WHEN 22     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(11 DOWNTO 8) ;
        WHEN 23     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(7  DOWNTO 4) ;
        WHEN 24     => char_addr_s <= ADDR_0 + regs_s(conv_integer(char_row_s-6))(3  DOWNTO 0) ;
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSIF(char_row_s = 15) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 14     => char_addr_s <= ADDR_I;
        WHEN 15     => char_addr_s <= ADDR_N;
        WHEN 16     => char_addr_s <= ADDR_S;
        WHEN 17     => char_addr_s <= ADDR_T;
        WHEN 18     => char_addr_s <= ADDR_R;
        WHEN 19     => char_addr_s <= ADDR_U;
        WHEN 20     => char_addr_s <= ADDR_C;
        WHEN 21     => char_addr_s <= ADDR_T;
        WHEN 22     => char_addr_s <= ADDR_I;
        WHEN 23     => char_addr_s <= ADDR_O;
        WHEN 24     => char_addr_s <= ADDR_N;
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSIF(char_row_s = 17) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 13     => char_addr_s <= ADDR_C;
        WHEN 14     => char_addr_s <= ADDR_O;
        WHEN 15     => char_addr_s <= ADDR_D;
        WHEN 16     => char_addr_s <= ADDR_E;
        WHEN 18     => char_addr_s <= ADDR_0 + instr_s(31 DOWNTO 28);
        WHEN 19     => char_addr_s <= ADDR_0 + instr_s(27 DOWNTO 24);
        WHEN 20     => char_addr_s <= ADDR_0 + instr_s(23 DOWNTO 20);
        WHEN 21     => char_addr_s <= ADDR_0 + instr_s(19 DOWNTO 16);
        WHEN 22     => char_addr_s <= ADDR_0 + instr_s(15 DOWNTO 12);
        WHEN 23     => char_addr_s <= ADDR_0 + instr_s(11 DOWNTO  8);
        WHEN 24     => char_addr_s <= ADDR_0 + instr_s(7  DOWNTO  4);
        WHEN 25     => char_addr_s <= ADDR_0 + instr_s(3  DOWNTO  0);
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSIF(char_row_s = 18) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 15     => char_addr_s <= ADDR_P;
        WHEN 16     => char_addr_s <= ADDR_C;
        WHEN 18     => char_addr_s <= ADDR_0 + ip_s(31 DOWNTO 28);
        WHEN 19     => char_addr_s <= ADDR_0 + ip_s(27 DOWNTO 24);
        WHEN 20     => char_addr_s <= ADDR_0 + ip_s(23 DOWNTO 20);
        WHEN 21     => char_addr_s <= ADDR_0 + ip_s(19 DOWNTO 16);
        WHEN 22     => char_addr_s <= ADDR_0 + ip_s(15 DOWNTO 12);
        WHEN 23     => char_addr_s <= ADDR_0 + ip_s(11 DOWNTO  8);
        WHEN 24     => char_addr_s <= ADDR_0 + ip_s(7  DOWNTO  4);
        WHEN 25     => char_addr_s <= ADDR_0 + ip_s(3  DOWNTO  0);
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSIF(char_row_s = 20) THEN

      CASE conv_integer(char_column_s) IS

        WHEN 14     => char_addr_s <= ADDR_A;
        WHEN 15     => char_addr_s <= ADDR_L;
        WHEN 16     => char_addr_s <= ADDR_U;
        WHEN 18     => char_addr_s <= ADDR_0 + alu_s(31 DOWNTO 28);
        WHEN 19     => char_addr_s <= ADDR_0 + alu_s(27 DOWNTO 24);
        WHEN 20     => char_addr_s <= ADDR_0 + alu_s(23 DOWNTO 20);
        WHEN 21     => char_addr_s <= ADDR_0 + alu_s(19 DOWNTO 16);
        WHEN 22     => char_addr_s <= ADDR_0 + alu_s(15 DOWNTO 12);
        WHEN 23     => char_addr_s <= ADDR_0 + alu_s(11 DOWNTO  8);
        WHEN 24     => char_addr_s <= ADDR_0 + alu_s(7  DOWNTO  4);
        WHEN 25     => char_addr_s <= ADDR_0 + alu_s(3  DOWNTO  0);
        WHEN OTHERS => char_addr_s <= ADDR_space;

      END CASE;

    ELSE

      char_addr_s <= ADDR_space;

    END IF;

  END PROCESS;

END rtl;
