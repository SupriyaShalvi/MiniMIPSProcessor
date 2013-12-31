-------------------------------------------------------------------------------
--
--  MYRISC project IN SME052 by
--
--  Anders Wallander
--  Department OF Computer Science AND Electrical Engineering
--  Luleå University OF Technology
--
--  A VHDL implementation OF a MIPS, based on the MIPS R2000 AND the
--  processor described IN Computer Organization AND Design by
--  Patterson/Hennessy
--
--
--  Memory stage
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY Work;
USE Work.RiscPackage.all;

ENTITY MemStage IS PORT (
                         Clk              : IN STD_LOGIC;
                         Reset            : IN STD_LOGIC;
                         Rdy_n            : IN STD_LOGIC;

                         In_Ctrl_WB       : IN TypeWBCtrl;
                         In_Ctrl_Mem      : IN TypeMEMCtrl;
                         In_ALU           : IN TypeWord;
                         In_Data          : IN TypeWord;
                         In_DestReg       : IN TypeRegister;

                         In_IntBusGrant_n : IN STD_LOGIC;

                         Bus_Data         : INOUT TypeWord;
                         Bus_Addr         : OUT TypeWord;
                         Bus_Rd_n         : OUT STD_LOGIC;
                         Bus_Wr_n         : OUT STD_LOGIC;

                         BP_Mem_iData     : OUT TypeWord;     -- Bypass to idecode
                         BP_Mem_iRDest    : OUT TypeRegister; -- Bypass to idecode
                         BP_Mem_iRegWrite : OUT STD_LOGIC;  -- Bypass to idecode

                         Mem_Ctrl_WB      : OUT TypeWBCtrl;
                         Mem_Data         : OUT TypeWord;
                         Mem_DestReg      : OUT TypeRegister
                        );
END;

ARCHITECTURE RTL OF MemStage  IS

  -- Mem to Reg mux
  SIGNAL mr_mux:  TypeWord;

BEGIN


-------------------------------------------------------------------------------
-- Mem to reg multiplexer
-------------------------------------------------------------------------------
  mr_mux <= Bus_Data WHEN In_Ctrl_Mem.MemRead = '1' ELSE In_ALU;

--------------------------------------------------------------------------------------
-- Bus stuff
--------------------------------------------------------------------------------------

  -- Tristate address bus IF no access...
  Bus_Addr <= In_ALU WHEN In_IntBusGrant_n = '0' ELSE (OTHERS => 'Z');

  Bus_Rd_n <= NOT In_Ctrl_Mem.MemRead WHEN In_IntBusGrant_n = '0' ELSE 'Z';

  -- Write WHEN MemWrite asserted
  Bus_Wr_n <= NOT In_Ctrl_Mem.MemWrite WHEN In_IntBusGrant_n = '0' ELSE 'Z';

  -- Output data WHEN MemWrite asserted
  Bus_Data <= In_Data WHEN In_Ctrl_Mem.MemWrite = '1' AND In_IntBusGrant_n = '0' ELSE (OTHERS => 'Z');

-------------------------------------------------------------------------------
-- Shift the pipeline
-------------------------------------------------------------------------------

  pipeline : PROCESS(Clk,Reset)
  BEGIN

    IF reset = '1' THEN
      -- TODO - do we really need to flush everything?
      Mem_Ctrl_WB <= (OTHERS => '0');
      Mem_DATA    <= (OTHERS => '0');
      Mem_DestReg <= (OTHERS => '0');

    ELSIF rising_edge(Clk) THEN

      IF (Rdy_n = '1') THEN
        Mem_Ctrl_WB <= In_Ctrl_WB;
        Mem_DATA    <= mr_mux;
        Mem_DestReg <= In_DestReg;
      END IF;

    END IF;

  END PROCESS;

-------------------------------------------------------------------------------
-- Pass signals to idecode
-------------------------------------------------------------------------------

  BP_Mem_iData     <= mr_mux;
  BP_Mem_iRDest    <= In_DestReg;
  BP_Mem_iRegWrite <= In_Ctrl_WB.RegWrite;

END ARCHITECTURE RTL;


