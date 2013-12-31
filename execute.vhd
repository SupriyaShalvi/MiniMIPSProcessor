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
--  Execute stage
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;



LIBRARY Work;
USE Work.RiscPackage.all;

ENTITY Execute IS PORT (
                        Clk             : IN STD_LOGIC;
                        Reset           : IN STD_LOGIC;
                        Rdy_n           : IN STD_LOGIC;

                        In_Ctrl_Ex      : IN TypeExCtrl;
                        In_Ctrl_Mem     : IN TypeMEMCtrl;
                        In_Ctrl_WB      : IN TypeWBCtrl;
                        In_A            : IN TypeWord;
                        In_B            : IN TypeWord;
                        In_IMM          : IN TypeWord;
                        In_Shift        : IN TypeRegister;
                        In_DestReg      : IN TypeRegister;
                        In_IP           : IN TypeWord;

                        BP_EX_iData     : OUT TypeWord;       -- Bypass to idecode
                        BP_EX_iRDest    : OUT TypeRegister;   -- Bypass to idecode
                        BP_EX_iRegWrite : OUT STD_LOGIC;      -- Bypass to idecode

                        EX_Ctrl_WB      : OUT TypeWBCtrl;
                        EX_Ctrl_Mem     : OUT TypeMemCtrl;
                        EX_ALU          : OUT TypeWord;
                        EX_DATA         : OUT TypeWord;
                        EX_DestReg      : OUT TypeRegister
                       );
END;

ARCHITECTURE RTL OF Execute IS

  -- ALU
  SIGNAL alu_RegA   : TypeWord;
  SIGNAL alu_RegB   : TypeWord;
  SIGNAL alu_Shift  : TypeWord;
  SIGNAL alu_Result : TypeWord;

BEGIN
-------------------------------------------------------------------------------
-- Zero extend shift value
-------------------------------------------------------------------------------

  alu_Shift <= x"000000" & "000" & In_Shift;

-------------------------------------------------------------------------------
-- Shift / JumpLink multiplexer
-------------------------------------------------------------------------------

  alu_RegA <= alu_Shift    WHEN In_Ctrl_Ex.ShiftSel = '1' ELSE
              x"0000_0004" WHEN In_Ctrl_Ex.JumpLink = '1' ELSE
              In_A;

-------------------------------------------------------------------------------
-- Immediate / JumpLink multiplexer
-------------------------------------------------------------------------------

  alu_RegB <= In_IMM WHEN In_Ctrl_Ex.ImmSel   = '1' ELSE
              In_IP  WHEN In_Ctrl_Ex.JumpLink = '1' ELSE
              In_B;

-------------------------------------------------------------------------------
-- ALU
-------------------------------------------------------------------------------

  ALU : PROCESS(alu_RegA, alu_RegB, In_Ctrl_Ex.OP)

    variable difference: integer;

  BEGIN

    CASE (In_Ctrl_Ex.OP) IS

      WHEN  ALU_ADD | ALU_ADDU  => alu_Result <= alu_RegA + alu_RegB;
      WHEN  ALU_SUB | ALU_SUBU  => alu_Result <= alu_RegA - alu_RegB;
      WHEN  ALU_AND             => alu_Result <= alu_RegA AND alu_RegB;
      WHEN  ALU_OR              => alu_Result <= alu_RegA OR alu_RegB;
      WHEN  ALU_XOR             => alu_Result <= alu_RegA XOR alu_RegB;
      WHEN  ALU_NOR             => alu_Result <= alu_RegA nor alu_RegB;

      WHEN  ALU_SLT => difference := conv_integer(signed(alu_RegA)) - conv_integer(signed(alu_RegB));
                       alu_Result(31 DOWNTO 1) <= (OTHERS => '0');

                         IF (difference < 0) THEN alu_Result(0) <= '1';
                         ELSE                                       alu_Result(0) <= '0';
                         END IF;

     WHEN ALU_SLTU => alu_Result(31 DOWNTO 1) <= (OTHERS => '0');

                      IF(alu_RegA < alu_RegB) THEN alu_Result(0) <= '1';
                      ELSE                                               alu_Result(0) <= '0';
                      END IF;

      WHEN  ALU_SLL => alu_Result <=  STD_LOGIC_VECTOR(shl( unsigned(alu_RegB), unsigned(alu_RegA(4 DOWNTO 0))));
      WHEN  ALU_SRL => alu_Result <=  STD_LOGIC_VECTOR(shr( unsigned(alu_RegB), unsigned(alu_RegA(4 DOWNTO 0))));
      WHEN  ALU_SRA => alu_Result <=  STD_LOGIC_VECTOR(unsigned(shr( signed(alu_RegB), unsigned(alu_RegA(4 DOWNTO 0)))));
      WHEN  OTHERS  => alu_Result <= (OTHERS=>'-');
    END CASE;

  END PROCESS;


-------------------------------------------------------------------------------
-- Shift the pipeline
-------------------------------------------------------------------------------

  pipeline : PROCESS(Clk,Reset)
  BEGIN
    IF reset = '1' THEN

      EX_Ctrl_Mem <= ('0','0','1');
      EX_Ctrl_WB  <= (OTHERS => '0');
      EX_ALU      <= (OTHERS => '0');
      EX_DATA     <= (OTHERS => '0');
      EX_DestReg  <= (OTHERS => '0');

    ELSIF rising_edge(Clk) THEN

      IF (Rdy_n = '1') THEN

        EX_Ctrl_Mem <= In_Ctrl_Mem;
        EX_Ctrl_WB  <= In_Ctrl_WB;
        EX_ALU      <= alu_Result;
        EX_DATA     <= In_B;
        EX_DestReg  <= In_DestReg;

      END IF;

    END IF;
  END PROCESS;


-------------------------------------------------------------------------------
-- Bypass signals to idecode
-------------------------------------------------------------------------------

  BP_EX_iData     <= alu_Result;
  BP_EX_iRDest    <= In_DestReg;
  BP_EX_iRegWrite <= In_Ctrl_WB.RegWrite;

END ARCHITECTURE RTL;





