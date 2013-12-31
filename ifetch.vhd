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
--  Instruction fetch stage
--    - Evaluate the program counter
--    - Fetch instructions
--
--
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY Work;
USE Work.RiscPackage.all;

ENTITY ifetch IS PORT (
                       Clk           : IN    STD_LOGIC ;
                       Reset         : IN    STD_LOGIC ;
                       In_Stall_IF   : IN    STD_LOGIC ;    -- Asserted IF pipe line IS stalled
                       In_ID_Req     : IN    STD_LOGIC ;    -- Asserted IF RegA equals RegB from the registerfile (Including bypass...)
                       In_ID_BAddr   : IN    TypeWord  ;    -- Jump/Branch target address
                       In_Ctrl_IF    : IN    TypeIFCtrl;
                       Init_n        : IN    STD_LOGIC ;
                       Rdy_n         : IN    STD_LOGIC ;
                       Bus_Data      : INOUT TypeWord  ;
                       Bus_Addr      : OUT   TypeWord  ;
                       Bus_Rd_n      : OUT   STD_LOGIC ;
                       Bus_Wr_n      : OUT   STD_LOGIC ;
                       IF_IP         : OUT   TypeWord  ;
                       IF_Instr      : OUT   TypeWord
                      );

END ifetch;

Architecture Struct OF ifetch IS

  SIGNAL nextPC      : TypeWord;         -- Next PC
  SIGNAL intPC       : TypeWord;         -- Internal PC
  SIGNAL intIncPC    : TypeWord;         -- Internal incremented PC
  SIGNAL instrData_i : TypeWord;
  SIGNAL Stall       : STD_LOGIC;
  SIGNAL TriStateBus : STD_LOGIC;

BEGIN

  PROCESS (Clk, Reset)
  BEGIN
    IF Reset = '1' THEN
      intPC <= x"0000_0100";
    ELSIF rising_edge(Clk) THEN

      IF (Stall = '0')  THEN intPC <= nextPC; END IF;

      IF (Init_n = '0') THEN intPC <= x"0000_0100"; END IF;

    END IF;
  END PROCESS;


  -- Multiplex next PC
  nextPC <= In_ID_BAddr WHEN ( ( (In_ID_Req = '1' XOR In_Ctrl_IF.bne = '1') AND In_Ctrl_IF.Branch = '1') OR In_Ctrl_IF.Jump = '1') ELSE
            intIncPC;

  -- Increment PC with 4
  intIncPC <= intPC + x"0000_0004";


--------------------------------------------------------------------------------------
-- Bus stuff
--------------------------------------------------------------------------------------

  -- Evaluate stall
  Stall       <= In_Stall_IF OR (NOT Rdy_n);
  TriStateBus <= In_Stall_IF;

  -- Tristate address bus IF stall
  Bus_Addr <= intPC WHEN TriStateBus = '0' ELSE (OTHERS => 'Z');

  -- Insert NOP instruction IF stall...
  InstrData_i <= Bus_Data;

  -- Only read from bus WHEN data memory IS NOT accessed
  Bus_Rd_n <= '0' WHEN TriStateBus = '0' ELSE 'Z';

  Bus_Wr_n <= '1' WHEN TriStateBus = '0' ELSE 'Z';

  -- Always output tristate on data (never write...)
  Bus_Data <= (OTHERS => 'Z');


--------------------------------------------------------------------------------------
-- Shift pipeline
--------------------------------------------------------------------------------------
  pipeline : PROCESS(Clk, Reset)
  BEGIN
    IF (reset = '1') THEN
      IF_IP    <= x"0000_0100";
      IF_Instr <= (OTHERS => '0');
    ELSIF rising_edge(Clk) THEN
      IF (Stall = '0') THEN
        IF_IP    <= intIncPC;
        IF_Instr <= InstrData_i;
      END IF;

      IF (Init_n = '0') THEN
        IF_IP    <= x"0000_0100";
        IF_Instr <= (OTHERS => '0');
      END IF;

    END IF;
  END PROCESS;


END ARCHITECTURE Struct;
