----------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije                  --
--  Copyright © 2009 ALL Rights Reserved                                        --
----------------------------------------------------------------------------------
--                                                                              --
-- Autor: LPRS2 TIM 2009/2010 <LPRS2@KRT.neobee.net>                            --
--                                                                              --
-- Datum izrade: /                                                              --
-- Naziv Modula: regField.vhd                                                   --
-- Naziv projekta: LabVezba5                                                    --
--                                                                              --
-- Opis: registarska polja za komunikaciju izmedju dioda, prekidaca, tastera i  --
-- lcd-a                                                                        --
--                                                                              --
-- Ukljucuje module: /                                                          --
--                                                                              --
-- Verzija : 1.0                                                                --
--                                                                              --
-- Dodatni komentari: /                                                         --
--                                                                              --
-- ULAZI: clk_i                                                                 --
--        addr_i                                                                --
--        data_i                                                                --
--        wr_en_n_i                                                             --
--        in_switch_i                                                           --
--        in_joy_i                                                              --
--        selected_i                                                            --
--                                                                              --
-- IZLAZI: data_o                                                               --
--         outLED                                                               --
--         lcd_o                                                                --
--                                                                              --
-- PARAMETRI : /                                                                --
--                                                                              --
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

LIBRARY work;
USE work.RiscPackage.ALL;

ENTITY regField IS GENERIC (
                            SIZE : INTEGER := 4
                           );
                     PORT (
                            clk_i       : IN  STD_LOGIC;
                            addr_i      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                            data_i      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                            wr_en_n_i   : IN  STD_LOGIC;
                            in_switch_i : IN  STD_LOGIC_VECTOR(7  DOWNTO 0);
                            in_joy_i    : IN  STD_LOGIC_VECTOR(3  DOWNTO 0);
                            selected_i  : OUT STD_LOGIC;
                            data_o      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                            outLED      : OUT STD_LOGIC_VECTOR(7  DOWNTO 0);
                            lcd_o       : OUT STD_LOGIC_VECTOR(7  DOWNTO 0)
                           );
END regField;

ARCHITECTURE aRegField OF regField IS

  SIGNAL regs_in_s   : TypeArrayWord(SIZE-1 DOWNTO 0) := (OTHERS => (OTHERS => '0'));
  SIGNAL regs_out_s  : TypeArrayWord(SIZE-1 DOWNTO 0) := (OTHERS => (OTHERS => '0'));
  SIGNAL regs_sel_s  : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL regs_addr_s : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL regs_we_s   : STD_LOGIC;

BEGIN

  -- output registers (100 - 111)

  PROCESS(clk_i)
    VARIABLE i : INTEGER;
  BEGIN

    IF (clk_i'event and clk_i = '1') THEN

      IF (regs_we_s = '1') THEN

        FOR i IN SIZE-1 DOWNTO 0 LOOP
          IF(regs_sel_s(i+4) = '1') THEN
            regs_out_s(i) <= data_i;
          ELSE
            regs_out_s(i) <= regs_out_s(i);
          END IF;
        END LOOP;

      ELSE

        FOR i IN SIZE-1 DOWNTO 0 LOOP
          regs_out_s(i) <= regs_out_s(i);
        END LOOP;

      END IF;

    END IF;

  END PROCESS;

  -- input registers (000 - 011)
  PROCESS(regs_sel_s, regs_in_s)
  BEGIN

    CASE regs_sel_s IS

      WHEN RF_SWITCH_SEL => data_o <= regs_in_s(0);
      WHEN RF_JOY_SEL    => data_o <= regs_in_s(1);
      WHEN OTHERS        => data_o <= (OTHERS => '0');

    END CASE;

  END PROCESS;

  PROCESS(clk_i)
  BEGIN

    IF (clk_i'event and clk_i = '1') THEN
      regs_in_s(0) <= x"000000"  & in_switch_i;
      regs_in_s(1) <= x"0000000" & in_joy_i;
    END IF;

  END PROCESS;

  -- WRITE enable IF addr[31:2] are ALL ones AND wr_en_n_i = '0'
  regs_we_s <= '1' WHEN (addr_i(31 DOWNTO 2) = x"FFFFFFF" & "11" AND wr_en_n_i = '0') ELSE '0';

  -- address decoder
  PROCESS(addr_i)
  BEGIN

    CASE addr_i(2 DOWNTO 0) IS
      WHEN RF_SWITCH => regs_sel_s <= RF_SWITCH_SEL;
      WHEN RF_JOY    => regs_sel_s <= RF_JOY_SEL;
      WHEN RF_LED    => regs_sel_s <= RF_LED_SEL;
      WHEN RF_LCD    => regs_sel_s <= RF_LCD_SEL;
      WHEN OTHERS    => regs_sel_s <= "00000000";
    END CASE;

  END PROCESS;

  -- selected SIGNAL indicates whether the REGISTER field IS addressed OR NOT
  selected_i <= '1' WHEN (addr_i(31 DOWNTO 3) = x"FFFFFFF" & '1') ELSE '0';

  outLED <= regs_out_s(0)(7 DOWNTO 0);
  lcd_o <= regs_out_s(1)(7 DOWNTO 0);

END aRegField;
