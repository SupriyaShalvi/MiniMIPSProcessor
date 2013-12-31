----------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije                  --
--  Copyright © 2009 ALL Rights Reserved                                        --
----------------------------------------------------------------------------------
--                                                                              --
-- Autor: LPRS2 TIM 2009/2010 <LPRS2@KRT.neobee.net>                            --
--                                                                              --
-- Datum izrade: /                                                              --
-- Naziv Modula: charPackage.vhd                                                --
-- Naziv projekta: LabVezba5                                                    --
--                                                                              --
-- Opis: paket sa adresama karaktera modula char_rom.                           --
--                                                                              --
-- Ukljucuje module: /                                                          --
--                                                                              --
-- Verzija : 1.0                                                                --
--                                                                              --
-- Dodatni komentari: /                                                         --
--                                                                              --
-- ULAZI:  /                                                                    --
-- IZLAZI: /                                                                    --
-- PARAMETRI : /                                                                --
--                                                                              --
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package charPackage is

    constant ADDR_at               : std_logic_vector(5 downto 0) := "000000";
    constant ADDR_A                : std_logic_vector(5 downto 0) := "000001";
    constant ADDR_B                : std_logic_vector(5 downto 0) := "000010";
    constant ADDR_C                : std_logic_vector(5 downto 0) := "000011";
    constant ADDR_D                : std_logic_vector(5 downto 0) := "000100";
    constant ADDR_E                : std_logic_vector(5 downto 0) := "000101";
    constant ADDR_F                : std_logic_vector(5 downto 0) := "000110";
    constant ADDR_G                : std_logic_vector(5 downto 0) := "000111";
    constant ADDR_H                : std_logic_vector(5 downto 0) := "001000";
    constant ADDR_I                : std_logic_vector(5 downto 0) := "001001";
    constant ADDR_J                : std_logic_vector(5 downto 0) := "001010";
    constant ADDR_K                : std_logic_vector(5 downto 0) := "001011";
    constant ADDR_L                : std_logic_vector(5 downto 0) := "001100";
    constant ADDR_M                : std_logic_vector(5 downto 0) := "001101";
    constant ADDR_N                : std_logic_vector(5 downto 0) := "001110";
    constant ADDR_O                : std_logic_vector(5 downto 0) := "001111";
    constant ADDR_P                : std_logic_vector(5 downto 0) := "010000";
    constant ADDR_Q                : std_logic_vector(5 downto 0) := "010001";
    constant ADDR_R                : std_logic_vector(5 downto 0) := "010010";
    constant ADDR_S                : std_logic_vector(5 downto 0) := "010011";
    constant ADDR_T                : std_logic_vector(5 downto 0) := "010100";
    constant ADDR_U                : std_logic_vector(5 downto 0) := "010101";
    constant ADDR_V                : std_logic_vector(5 downto 0) := "010110";
    constant ADDR_W                : std_logic_vector(5 downto 0) := "010111";
    constant ADDR_X                : std_logic_vector(5 downto 0) := "011000";
    constant ADDR_Y                : std_logic_vector(5 downto 0) := "011001";
    constant ADDR_Z                : std_logic_vector(5 downto 0) := "011010";
    constant ADDR_midBracketOpen   : std_logic_vector(5 downto 0) := "011011";
    constant ADDR_arrowDown        : std_logic_vector(5 downto 0) := "011100";
    constant ADDR_midBracketClosed : std_logic_vector(5 downto 0) := "011101";
    constant ADDR_arrowUp          : std_logic_vector(5 downto 0) := "011110";
    constant ADDR_arrowLeft        : std_logic_vector(5 downto 0) := "011111";
    constant ADDR_space            : std_logic_vector(5 downto 0) := "100000";
    constant ADDR_exclamation      : std_logic_vector(5 downto 0) := "100001";
    constant ADDR_quotes           : std_logic_vector(5 downto 0) := "100010";
    constant ADDR_hash             : std_logic_vector(5 downto 0) := "100011";
    constant ADDR_dollar           : std_logic_vector(5 downto 0) := "100100";
    constant ADDR_percent          : std_logic_vector(5 downto 0) := "100101";
    constant ADDR_and              : std_logic_vector(5 downto 0) := "100110";
    constant ADDR_apostrophe       : std_logic_vector(5 downto 0) := "100111";
    constant ADDR_bracketOpen      : std_logic_vector(5 downto 0) := "101000";
    constant ADDR_bracketClosed    : std_logic_vector(5 downto 0) := "101001";
    constant ADDR_asterisk         : std_logic_vector(5 downto 0) := "101010";
    constant ADDR_plus             : std_logic_vector(5 downto 0) := "101011";
    constant ADDR_comma            : std_logic_vector(5 downto 0) := "101100";
    constant ADDR_minus            : std_logic_vector(5 downto 0) := "101101";
    constant ADDR_dot              : std_logic_vector(5 downto 0) := "101110";
    constant ADDR_slash            : std_logic_vector(5 downto 0) := "101111";
    constant ADDR_0                : std_logic_vector(5 downto 0) := "110000";
    constant ADDR_1                : std_logic_vector(5 downto 0) := "110001";
    constant ADDR_2                : std_logic_vector(5 downto 0) := "110010";
    constant ADDR_3                : std_logic_vector(5 downto 0) := "110011";
    constant ADDR_4                : std_logic_vector(5 downto 0) := "110100";
    constant ADDR_5                : std_logic_vector(5 downto 0) := "110101";
    constant ADDR_6                : std_logic_vector(5 downto 0) := "110110";
    constant ADDR_7                : std_logic_vector(5 downto 0) := "110111";
    constant ADDR_8                : std_logic_vector(5 downto 0) := "111000";
    constant ADDR_9                : std_logic_vector(5 downto 0) := "111001";

end package;
