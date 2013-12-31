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
--  Internal Bus State Machine
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY IntBusSM IS PORT (
                         Clk              : IN  STD_LOGIC;
                         Reset            : IN  STD_LOGIC;
                         Rdy_n            : IN  STD_LOGIC;
                         IntBusReq_n      : IN  STD_LOGIC; -- Memory request SIGNAL
                         IntBusGrant_n    : OUT STD_LOGIC  -- Memory grant SIGNAL
                        );
END IntBusSM;

--------------------------------------------------------------------------------
ARCHITECTURE RTL OF IntBusSM IS

type state_type IS (ProgramMemAccess, DataMemAccess);

SIGNAL PresentState, NextState : state_type;

BEGIN
--------------------------------------------------------------------------------
  PROCESS( Clk, Reset)
  BEGIN

    IF    (Reset = '1' )     THEN  PresentState <= ProgramMemAccess;
    ELSIF (rising_edge(Clk)) THEN  PresentState <= NextState;
    END IF;

  END PROCESS;
--------------------------------------------------------------------------------

  PROCESS(PresentState, Rdy_n,  IntBusReq_n)
  BEGIN

    CASE (PresentState) IS

      WHEN ProgramMemAccess => IntBusGrant_n <=  '1';
                               IF (IntBusReq_n = '0' AND Rdy_n = '1') THEN NextState <= DataMemAccess;
                               ELSE                                        NextState <= ProgramMemAccess;
                               END IF;

      WHEN DataMemAccess    => IntBusGrant_n <= '0';
                               IF (IntBusReq_n = '1' AND Rdy_n = '1')  THEN NextState <= ProgramMemAccess;
                               ELSE                                         NextState <= DataMemAccess;
                               END IF;

      WHEN OTHERS           =>  NextState <= ProgramMemAccess;
    END CASE;

  END PROCESS;
END;
