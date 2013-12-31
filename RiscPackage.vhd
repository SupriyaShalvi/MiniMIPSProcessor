-------------------------------------------------------------------------------
--
--  MYRISC project IN SME052 by
--
--  Anders Wallander
--  Department OF Computer Science AND Electrical Engineering
--  Luleå University OF Technology
--
--  A VHDL implementation OF the MIPS RISC processor described IN
--  Computer Organization AND Design by Patterson/Hennessy
--
--
--  PACKAGE FOR MYRISC
--
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;



PACKAGE RiscPackage IS

  SUBTYPE TypeWord IS STD_LOGIC_VECTOR(31 DOWNTO  0);
  TYPE    TypeArrayWord IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

  SUBTYPE TypeRegister IS STD_LOGIC_VECTOR(4 DOWNTO 0);

  SUBTYPE TypeALUOpcode IS STD_LOGIC_VECTOR(3 DOWNTO 0);

  TYPE TypeIFCtrl IS RECORD
    Branch    : STD_LOGIC;    -- IF asserted, branch TO NEW address IF (registers are equal) XOR (bne).
    Jump      : STD_LOGIC;    -- IF asserted, branch TO NEW address.
    bne       : STD_LOGIC;    -- IF assered, branch only ON non equal registers.
  END RECORD;

  TYPE TypeIDCtrl IS RECORD
    Branch    : STD_LOGIC;    -- IF asserted branch target = branch address, ELSE jump address.
    Jr        : STD_LOGIC;    -- IF asserted jumpaddress = Rs.
    Lui       : STD_LOGIC;    -- IF asserted Shiftvalue = 16.
    ShiftVar  : STD_LOGIC;    -- IF asserted Shiftvalue = Rs(4 DOWNTO 0).
    ZeroExtend: STD_LOGIC;    -- IF asserted, zero extend imm VALUE, ELSE sign extend imm VALUE.
  END RECORD;

  TYPE TypeExCtrl IS RECORD
    ImmSel    : STD_LOGIC;    -- IF asserted, ALU_B = imm VALUE, ELSE ALU_B = Rt.
    JumpLink  : STD_LOGIC;    -- IF asserted DestReg = 31, WriteData = IP + 1
    ShiftSel  : STD_LOGIC;    -- IF asserted, ALU_A = zero extended shiftvalue, ELSE ALU_A=Rs.
    OP: TypeALUOpcode;        -- ALU opcode.
  END RECORD;

  TYPE TypeMemCtrl IS RECORD
    MemRead        : STD_LOGIC; -- READ from datamemory IF asserted.
    MemWrite       : STD_LOGIC; -- WRITE TO datamemory IF asserted.
    MemBusAccess_n : STD_LOGIC; -- Asserted WHEN memory stage IS ACTIVE (will stall instruction fetch)
  END RECORD;

  TYPE TypeWBCtrl IS RECORD
    RegWrite  : STD_LOGIC;    -- WRITE TO registerfile IF asserted.
  END RECORD;


  -- Try TO match up against MIPS op-codes
  CONSTANT ALU_ADD    : TypeALUOpcode := "0000";
  CONSTANT ALU_ADDU   : TypeALUOpcode := "0001";
  CONSTANT ALU_SUB    : TypeALUOpcode := "0010";
  CONSTANT ALU_SUBU   : TypeALUOpcode := "0011";
  CONSTANT ALU_AND    : TypeALUOpcode := "0100";
  CONSTANT ALU_OR     : TypeALUOpcode := "0101";
  CONSTANT ALU_XOR    : TypeALUOpcode := "0110";
  CONSTANT ALU_NOR    : TypeALUOpcode := "0111";
  CONSTANT ALU_SLT    : TypeALUOpcode := "1010";
  CONSTANT ALU_SLTU   : TypeALUOpcode := "1011";
  CONSTANT ALU_SLL    : TypeALUOpcode := "1100";
  CONSTANT ALU_SRL    : TypeALUOpcode := "1110";
  CONSTANT ALU_SRA    : TypeALUOpcode := "1111";

  CONSTANT RF_SWITCH_SEL : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001";
  CONSTANT RF_JOY_SEL    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000010";
  CONSTANT RF_LED_SEL    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00010000";
  CONSTANT RF_LCD_SEL    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00100000";
  CONSTANT RF_SWITCH     : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"     ;
  CONSTANT RF_JOY        : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001"     ;
  CONSTANT RF_LED        : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100"     ;
  CONSTANT RF_LCD        : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101"     ;

END PACKAGE RiscPackage;

