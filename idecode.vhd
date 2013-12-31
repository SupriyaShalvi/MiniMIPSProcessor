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
--  Instruction decode stage
--    Compute branch AND jump destinations
--    Evaluate data FOR execution units, branch conditions AND jump register
--
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY Work;
USE Work.RiscPackage.all;

ENTITY IDecode IS PORT (
                        Clk               : IN STD_LOGIC;
                        Reset             : IN STD_LOGIC;
                        Rdy_n             : IN STD_LOGIC;

                        WriteRegEn        : IN STD_LOGIC;
                        WriteData         : IN TypeWord;
                        WriteAddr         : IN TypeRegister;
                        In_IP             : IN TypeWord;
                        In_Instr          : IN TypeWord;

                        BP_Mem_iData      : IN TypeWord;     -- Bypass from memstage
                        BP_Mem_iRDest     : IN TypeRegister; -- Bypass from memstage
                        BP_Mem_iRegWrite  : IN STD_LOGIC;    -- Bypass from memstage
                        BP_EX_iData       : IN TypeWord;     -- Bypass from execution
                        BP_EX_iRDest      : IN TypeRegister; -- Bypass from execution
                        BP_EX_iRegWrite   : IN STD_LOGIC;    -- Bypass from execution

                        In_Ctrl_ID        : IN  TypeIDCtrl;
                        In_Ctrl_Ex        : IN  TypeExCtrl;
                        In_Ctrl_Mem       : IN  TypeMemCtrl;
                        In_Ctrl_WB        : IN  TypeWBCtrl;

                        In_MemBusAccess_n : IN  STD_LOGIC;

                        ID_Stall          : OUT STD_LOGIC;
                        ID_Req            : OUT STD_LOGIC;
                        ID_BAddr          : OUT TypeWord;

                        ID_Ctrl_Ex        : OUT TypeExCtrl;
                        ID_Ctrl_Mem       : OUT TypeMemCtrl;
                        ID_Ctrl_WB        : OUT TypeWBCtrl;
                        ID_A              : OUT TypeWord;
                        ID_B              : OUT TypeWord;
                        ID_IMM            : OUT TypeWord;
                        ID_Shift          : OUT TypeRegister;
                        ID_DestReg        : OUT TypeRegister;
                        ID_IP             : OUT TypeWord;

                        oReg              : OUT TypeArrayWord(7 DOWNTO 0)
                       );
END;

ARCHITECTURE RTL OF IDecode IS

  -- Instruction aliases
  alias Op    : STD_LOGIC_VECTOR(5 DOWNTO 0) IS In_Instr(31 DOWNTO 26);
  alias Rs    : TypeRegister IS In_Instr(25 DOWNTO 21);
  alias Rt    : TypeRegister IS In_Instr(20 DOWNTO 16);
  alias Rd    : TypeRegister IS In_Instr(15 DOWNTO 11);
  alias Shift : TypeRegister IS In_Instr(10 DOWNTO 6);
  alias Funct : STD_LOGIC_VECTOR(5 DOWNTO 0) IS In_Instr(5 DOWNTO 0);

  -- Register file
  SIGNAL rf_Regs  : TypeArrayWord(31  DOWNTO 0) := (OTHERS => (OTHERS => '0'));
  SIGNAL schReg   : TypeArrayWord(8 DOWNTO 0);

  SIGNAL rf_RegA  :  TypeWord;
  SIGNAL rf_RegB  :  TypeWord;
  SIGNAL rf_WE    : STD_LOGIC;

  -- Signed extended immediate
  SIGNAL immSigned : TypeWord;

  -- Destination reg multiplexer
  SIGNAL dm_TempReg : TypeRegister;
  SIGNAL dm_DestReg : TypeRegister;

  -- Shift multiplexer
  SIGNAL sm_Shift : TypeRegister;

  -- Branch logic
  SIGNAL br_JAddr : TypeWord;
  SIGNAL br_BAddr : TypeWord;

  -- Hazard detection signals
  SIGNAL hd_Nop   : STD_LOGIC;
  SIGNAL hd_Stall : STD_LOGIC;

  -- Bypass signals
  SIGNAL bp_ID_Ctrl_Mem  : TypeMemCtrl;
  SIGNAL bp_ID_Rt        : TypeRegister;

    -- Forwarding unit
  SIGNAL bp_Rs_A      : STD_LOGIC;
  SIGNAL bp_Rt_A      : STD_LOGIC;
  SIGNAL bp_Rs_B      : STD_LOGIC;
  SIGNAL bp_Rt_B      : STD_LOGIC;
  SIGNAL bp_Rs_C      : STD_LOGIC;
  SIGNAL bp_Rt_C      : STD_LOGIC;

  SIGNAL bp_Rs_A_val  : TypeWord;
  SIGNAL bp_Rt_A_val  : TypeWord;
  SIGNAL bp_Rs_B_val  : TypeWord;
  SIGNAL bp_Rt_B_val  : TypeWord;
  SIGNAL bp_Rs_C_val  : TypeWord;
  SIGNAL bp_Rt_C_val  : TypeWord;

  SIGNAL  Stall       : STD_LOGIC;

BEGIN

-------------------------------------------------------------------------------
-- Register file
-------------------------------------------------------------------------------

  -- Write register file -- Write on positive flank
  rf : PROCESS(Clk, Reset)
  BEGIN

    IF Reset = '1' THEN

      rf_Regs <= (OTHERS => (OTHERS => '0'));
      schReg <= (OTHERS => (OTHERS => '0'));

    ELSIF rising_edge(Clk) THEN

      IF rf_WE  = '1' THEN
          rf_Regs(conv_integer(unsigned(WriteAddr))) <= WriteData;
          schReg(0) <= rf_Regs(0);
          schReg(1) <= rf_Regs(1);
          schReg(2) <= rf_Regs(2);
          schReg(3) <= rf_Regs(3);
          schReg(4) <= rf_Regs(4);
          schReg(5) <= rf_Regs(5);
          schReg(6) <= rf_Regs(6);
          schReg(7) <= rf_Regs(7);
          schReg(8) <= rf_Regs(8);
      END IF;

    END IF;

  END PROCESS;

  oReg <= schReg(8 DOWNTO 1);

  rf_WE <= WriteRegEn WHEN WriteAddr /= "00000" ELSE '0';

  -- Read register file
  rf_RegA <= rf_Regs(conv_integer(unsigned(Rs)));
  rf_RegB <= rf_Regs(conv_integer(unsigned(Rt)));

-------------------------------------------------------------------------------
-- Sign OR zero extend immediate data
--
-- If In_Ctrl_ID.ZeroExtend IS asserted THEN we will zero extend
--
-------------------------------------------------------------------------------
  immSigned(15 DOWNTO 0)  <= In_Instr(15 DOWNTO 0) ;
  immSigned(31 DOWNTO 16) <= (OTHERS => (In_Instr(15) AND NOT(In_Ctrl_ID.ZeroExtend)));

-------------------------------------------------------------------------------
-- Regdest multiplexer
-------------------------------------------------------------------------------

  dm_TempReg <= Rd WHEN In_Ctrl_Ex.ImmSel = '0' ELSE  -- always asserted WHEN ImmSel IS ssserted
                Rt;

  dm_DestReg <= dm_TempReg WHEN In_Ctrl_Ex.JumpLink = '0' ELSE  -- If jal instruction, load destreg with $31
                "11111";

-------------------------------------------------------------------------------
-- Shift amount multiplexer
-------------------------------------------------------------------------------

  sm_Shift <= "10000" WHEN In_Ctrl_ID.Lui = '1' ELSE              -- If lui instruction force ALU to shift left 16bits
              bp_Rs_C_val(4 DOWNTO 0) WHEN In_Ctrl_ID.ShiftVar = '1' ELSE  -- If shift variable IS used
              Shift;                                              -- Else shift amount IS used

-------------------------------------------------------------------------------
-- Branch AND Jump logic
-------------------------------------------------------------------------------

  -- Calculate branch target
  br_BAddr <= shl(unsigned(immSigned), x"0000_0002") + unsigned(In_IP);

  -- Assert Req IF bp_Rs_C_val equals bp_Rt_C_val
  ID_Req <=   '1' WHEN bp_Rs_C_val =  bp_Rt_C_val ELSE
              '0';

  -- Multiplex jump target
  br_JAddr <= bp_Rs_C_val WHEN In_Ctrl_ID.Jr = '1' ELSE
              In_IP(31 DOWNTO 28) & STD_LOGIC_VECTOR(shl(unsigned(In_Instr(27 DOWNTO 0)), x"0000_0002"));


  -- Multiplex Jump AND Branch targets
  ID_BAddr <= br_BAddr WHEN In_Ctrl_ID.Branch = '1' ELSE
              br_JAddr;

-------------------------------------------------------------------------------
-- Forwarding units
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- ALU bypass multiplexer Rs_A  From Writeback stage
-------------------------------------------------------------------------------

  bp_Rs_A_val <=  WriteData WHEN bp_Rs_A = '1' ELSE
                  rf_RegA;

-------------------------------------------------------------------------------
-- Bypass multiplexer Rs_B  From Memstage
-------------------------------------------------------------------------------

  bp_Rs_B_val <=  BP_Mem_iData WHEN bp_Rs_B = '1' ELSE
                  bp_Rs_A_val;

-------------------------------------------------------------------------------
-- ALU bypass multiplexer Rs_C  From Execution stage
-------------------------------------------------------------------------------

  bp_Rs_C_val <=  BP_EX_iData WHEN bp_Rs_C = '1' ELSE
                  bp_Rs_B_val;

-------------------------------------------------------------------------------
-- ALU bypass multiplexer Rt_A  From Writeback stage
-------------------------------------------------------------------------------

  bp_Rt_A_val <=  WriteData WHEN bp_Rt_A = '1' ELSE
                  rf_RegB;

-------------------------------------------------------------------------------
-- Bypass multiplexer Rt_B  From Memstage
-------------------------------------------------------------------------------

  bp_Rt_B_val <=  BP_Mem_iData WHEN bp_Rt_B = '1' ELSE
                  bp_Rt_A_val;

-------------------------------------------------------------------------------
-- ALU bypass multiplexer Rt_C From Execution stage
-------------------------------------------------------------------------------

  bp_Rt_C_val <=  BP_EX_iData WHEN bp_Rt_C = '1' ELSE
                  bp_Rt_B_val;


-------------------------------------------------------------------------------
-- Forwarding evaluation
-------------------------------------------------------------------------------

  -- See IF want to bypass Rs from Writeback stage
  bp_Rs_A <= '1' WHEN (WriteRegEn = '1' AND
                       WriteAddr /= "00000" AND
                       WriteAddr = Rs) ELSE
              '0';

  -- See IF want to bypass Rs from MemStage
  bp_Rs_B <=  '1' WHEN (BP_Mem_iRegWrite = '1' AND
                        BP_Mem_iRDest /= "00000" AND
                        BP_Mem_iRDest = Rs)
                        --TODO???
                        --(BP_EX_iRDest /= In_Rs OR BP_EX_MEM(0) = '0') AND       -- Prevent dest reg after load instr.
                        ELSE
              '0';

  -- See IF want to bypass Rs from Execution stage
  bp_Rs_C <= '1' WHEN (BP_EX_iRegWrite = '1' AND
                       BP_EX_iRDest /= "00000" AND
                       BP_EX_iRDest = Rs) ELSE
              '0';

  -- See IF want to bypass Rt from Writeback stage
  bp_Rt_A <= '1' WHEN (WriteRegEn = '1' AND
                       WriteAddr /= "00000" AND
                       WriteAddr = Rt) ELSE
              '0';


  -- See IF want to bypass Rt from MemStage
  bp_Rt_B <=  '1' WHEN (BP_Mem_iRegWrite = '1' AND
                        BP_Mem_iRDest /= "00000" AND
                        BP_Mem_iRDest = Rt)
                        --TODO???
                        --(BP_EX_iRDest /= In_Rs OR BP_EX_MEM(0) = '0') AND       -- Prevent dest reg after load instr.
                        ELSE
              '0';

  -- See IF want to bypass Rt from Execution stage
  bp_Rt_C <= '1' WHEN (BP_EX_iRegWrite = '1' AND
                       BP_EX_iRDest /= "00000" AND
                       BP_EX_iRDest = Rt) ELSE
              '0';

-------------------------------------------------------------------------------
-- Hazard detection
--
-- Stall the pipeline IF USE OF the same register as the load instruction IN
-- the previous operation.
--
-------------------------------------------------------------------------------

  hd_Nop <= '1' WHEN  (bp_ID_Ctrl_Mem.MemRead = '1' AND
                      ((bp_ID_Rt = Rs) OR  bp_ID_Rt = Rt)) ELSE
            '0';

  hd_Stall <= hd_Nop OR NOT(In_MemBusAccess_n);

  ID_Stall <= hd_Stall;     -- Avoid using INOUT type...

  Stall    <= hd_Stall OR (NOT Rdy_n);

-------------------------------------------------------------------------------
-- Shift pipeline
-------------------------------------------------------------------------------

  pipeline : PROCESS(Clk,Reset)
  BEGIN
    IF reset = '1' THEN

      ID_Ctrl_EX     <= ('0','0','0',"0000");
      bp_ID_Ctrl_Mem <= ('0','0','1');
      ID_Ctrl_WB     <= (OTHERS => '0');
      ID_A           <= (OTHERS => '0');
      ID_B           <= (OTHERS => '0');
      ID_IMM         <= (OTHERS => '0');
      ID_Shift       <= (OTHERS => '0');
      ID_DestReg     <= (OTHERS => '0');
      ID_IP          <= (OTHERS => '0');
      bp_ID_Rt       <= (OTHERS => '0');

    ELSIF rising_edge(Clk) THEN

      IF (Stall = '0') THEN
        ID_Ctrl_EX     <= In_Ctrl_Ex;
        bp_ID_Ctrl_Mem <= In_Ctrl_Mem;
        ID_Ctrl_WB     <= In_Ctrl_WB;

        ID_A          <= bp_Rs_C_val;
        ID_B          <= bp_Rt_C_val;
        ID_IMM        <= immSigned;
        ID_Shift      <= sm_Shift;
        ID_DestReg    <= dm_DestReg;
        ID_IP         <= In_IP;
        bp_ID_Rt      <= Rt;
      END IF;

      IF (hd_Stall = '1') THEN
        --If the pipeline IS stalled by hazard detection: insert NOP...
        ID_Ctrl_EX     <= ('0','0','0',"0000");
        bp_ID_Ctrl_Mem <= ('0','0','1');
        ID_Ctrl_WB     <= (OTHERS => '0');
      END IF;

    END IF;
  END PROCESS;

  ID_Ctrl_Mem <= bp_ID_Ctrl_Mem;

END ARCHITECTURE RTL;
