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
--  Controller
--    Decode instructions
--
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY Work;
USE Work.RiscPackage.all;

ENTITY Controller IS PORT(
                          Instr     : IN  TypeWord;
                          Ctrl_IF   : OUT TypeIFCtrl;
                          Ctrl_ID   : OUT TypeIDCtrl;
                          Ctrl_Ex   : OUT TypeExCtrl;
                          Ctrl_Mem  : OUT TypeMemCtrl;
                          Ctrl_WB   : OUT TypeWBCtrl
                        );
END;

ARCHITECTURE RTL OF Controller  IS

  -- Instruction aliases
  alias Op    : STD_LOGIC_VECTOR(5 DOWNTO 0) IS Instr(31 DOWNTO 26);
  alias Rs    : TypeRegister IS Instr(25 DOWNTO 21);
  alias Rt    : TypeRegister IS Instr(20 DOWNTO 16);
  alias Rd    : TypeRegister IS Instr(15 DOWNTO 11);
  alias Shift : TypeRegister IS Instr(10 DOWNTO 6);
  alias Funct : STD_LOGIC_VECTOR(5 DOWNTO 0) IS Instr(5 DOWNTO 0);

BEGIN

-------------------------------------------------------------------------------
-- Main Controller
-------------------------------------------------------------------------------
  mainController: Process(Op, Funct)

  variable OP_iForm      : STD_LOGIC;
  variable OP_lw         : STD_LOGIC;
  variable OP_sw         : STD_LOGIC;
  variable OP_branch     : STD_LOGIC;
  variable OP_jump       : STD_LOGIC;
  variable OP_jal        : STD_LOGIC;
  variable OP_jr         : STD_LOGIC;
  variable OP_lui        : STD_LOGIC;
  variable OP_ShiftSel   : STD_LOGIC;
  variable OP_ZeroExtend : STD_LOGIC;
  variable OP_RegWrite   : STD_LOGIC;
  variable OP_ALU_OP     : TypeALUOpcode;

  BEGIN
    OP_iForm       := '0';
    OP_lw          := '0';
    OP_sw          := '0';
    OP_branch      := '0';
    OP_jump        := '0';
    OP_jal         := '0';
    OP_jr          := '0';
    OP_lui         := '0';
    OP_ShiftSel    := '0';
    OP_ZeroExtend  := '0';
    OP_RegWrite    := '0';
    OP_ALU_OP      := (OTHERS => '0');

    IF (OP = "000000") THEN -- If OP field IS null analyse extended opfield
      OP_RegWrite := Funct(5) OR NOT(Funct(3)); -- RegWrite asserted WHEN arithmetic operation...
      CASE Funct(5 DOWNTO 3) IS

        WHEN  "100" => OP_ALU_OP := '0' & Funct(2 DOWNTO 0); -- Arithmetic

        WHEN  "101" => OP_ALU_OP := "10" & Funct(1 DOWNTO 0);  -- Slt AND sltu

        WHEN  "000" => OP_ALU_OP := "11" & Funct(1 DOWNTO 0);  OP_ShiftSel := '1';-- Shift operations

        WHEN  "001" => OP_jump := '1'; OP_jr:='1';   -- (jr)

        WHEN OTHERS =>  null;       -- TODO exception
      END CASE;
    ELSE
      OP_iForm := '1';
      OP_RegWrite := (NOT OP(5)) AND OP(3); -- RegWrite asserted WHEN arithmetic operation...

      CASE (OP) IS
        WHEN  "001000" |
              "001001"=>  OP_ALU_OP := ALU_ADD;         -- (addi) -Note: No care IS taken FOR overflow...

        WHEN  "001100" => OP_ALU_OP := ALU_AND; OP_ZeroExtend := '1'; -- (andi)

        WHEN  "001101" => OP_ALU_OP := ALU_OR;  OP_ZeroExtend := '1'; -- (ori)

        WHEN  "001110" => OP_ALU_OP := ALU_XOR; OP_ZeroExtend := '1'; -- (xori)

        WHEN  "001010" => OP_ALU_OP := ALU_SLT;         -- (slti)

        WHEN  "001011" => OP_ALU_OP := ALU_SLTU;        -- (sltiu)

        WHEN  "100011" => OP_lw     := '1';             -- (lw)
                          OP_ALU_OP := ALU_ADD;
        WHEN  "101011" => OP_sw     := '1';             -- (sw)
                          OP_ALU_OP := ALU_ADD;

        WHEN  "001111" => OP_ALU_OP   := ALU_SLL;       -- (lui)
                          OP_lui      := '1';
                          OP_ShiftSel := '1';
        WHEN  "000100" |
              "000101" => OP_branch   := '1';           -- (beq)

        WHEN  "000010" => OP_jump     := '1';           -- (j)

        WHEN  "000011" => OP_jump   := '1';
                          OP_jal    := '1';
                          OP_ALU_OP := ALU_ADD;         --(jal)

        WHEN OTHERS =>  NULL;     -- TODO exception
      END CASE;
    END IF;

    Ctrl_IF.bne             <= OP(0);
    Ctrl_IF.Branch          <= OP_branch;
    Ctrl_IF.Jump            <= OP_jump;

    Ctrl_ID.Branch          <= OP_branch;
    Ctrl_ID.Jr              <= OP_jr;
    Ctrl_ID.Lui             <= OP_lui;
    Ctrl_ID.ShiftVar        <= Funct(2);   -- Always asserted IF variable shift instruction
    Ctrl_ID.ZeroExtend      <= OP_ZeroExtend;

    Ctrl_Ex.JumpLink        <= OP_jal;
    Ctrl_Ex.ShiftSel        <= OP_ShiftSel AND NOT (OP_jal); -- Assert IF shift operations
    Ctrl_Ex.ImmSel          <= OP_iForm AND NOT (OP_jal);
    Ctrl_Ex.OP              <= OP_ALU_OP;

    Ctrl_Mem.MemRead        <= OP_lw;
    Ctrl_Mem.MemWrite       <= OP_sw;
    Ctrl_Mem.MemBusAccess_n <= NOT(OP_lw OR OP_sw);

    Ctrl_WB.RegWrite        <= OP_RegWrite OR OP_lw OR OP_jal;

  END PROCESS;

END ARCHITECTURE RTL;