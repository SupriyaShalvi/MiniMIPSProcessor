-------------------------------------------------------------------------------
--
--  MYRISC project IN SME052 by
--
--  Anders Wallander
--  Department OF Computer Science AND Electrical Engineering
--  Luleå University OF Technology
--
--  A VHDL implementation OF a MIPS  based on the MIPS R2000 AND the
--  processor described IN Computer Organization AND Design by
--  Patterson/Hennessy
--
--
--  MYRISC toplevel
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

LIBRARY work;
USE work.RiscPackage.all;

ENTITY myrisc IS PORT (
                       Clk        : IN    STD_LOGIC                    ;
                       Reset      : IN    STD_LOGIC                    ;
                       Bus_Data   : INOUT TypeWord                     ;
                       Bus_Addr   : OUT   TypeWord                     ;
                       Bus_Rd_n   : OUT   STD_LOGIC                    ;
                       Bus_Wr_n   : OUT   STD_LOGIC                    ;
                       Init_n     : IN    STD_LOGIC                    ;
                       Rdy_n      : IN    STD_LOGIC                    ;
                       oReg       : OUT   TypeArrayWord(7 DOWNTO 0)    ;
                       IP         : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
                       Instr      : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
                       ALU        : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0)
                      );
END myrisc;

ARCHITECTURE behavior OF myrisc IS

  COMPONENT Controller IS PORT (
                                  Instr     : IN  TypeWord   ;
                                  Ctrl_IF   : OUT TypeIFCtrl ;
                                  Ctrl_ID   : OUT TypeIDCtrl ;
                                  Ctrl_Ex   : OUT TypeExCtrl ;
                                  Ctrl_Mem  : OUT TypeMemCtrl;
                                  Ctrl_WB   : OUT TypeWBCtrl
                               );
  END COMPONENT;

  COMPONENT IntBusSM IS PORT  (
                               Clk            : IN  STD_LOGIC;
                               Reset          : IN  STD_LOGIC;
                               Rdy_n          : IN  STD_LOGIC;
                               IntBusReq_n    : IN  STD_LOGIC;   -- Memory request SIGNAL
                               IntBusGrant_n  : OUT STD_LOGIC    -- Memory grant SIGNAL
                               );
  END COMPONENT IntBusSM;

  COMPONENT ifetch IS PORT (
                            Clk           : IN    STD_LOGIC ;
                            Reset         : IN    STD_LOGIC ;
                            In_Stall_IF   : IN    STD_LOGIC ;   -- Asserted IF pipe line IS stalled OR memstage memaccess
                            In_ID_Req     : IN    STD_LOGIC ;   -- Asserted IF RegA equals RegB from the registerfile (Including bypass...)
                            In_ID_BAddr   : IN    TypeWord  ;      -- Jump/Branch target address
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
  END COMPONENT ifetch;

  COMPONENT IDecode IS PORT (
                             Clk          : IN STD_LOGIC;
                             Reset        : IN STD_LOGIC;
                             Rdy_n        : IN STD_LOGIC;
                             WriteRegEn   : IN STD_LOGIC;
                             WriteData    : IN TypeWord;
                             WriteAddr    : IN TypeRegister;
                             In_IP        : IN TypeWord;
                             In_Instr     : IN TypeWord;

                             BP_Mem_iData     : IN  TypeWord;     -- Bypass from memstage
                             BP_Mem_iRDest    : IN  TypeRegister; -- Bypass from memstage
                             BP_Mem_iRegWrite : IN  STD_LOGIC;     -- Bypass from memstage
                             BP_EX_iData      : IN  TypeWord;     -- Bypass from execution
                             BP_EX_iRDest     : IN  TypeRegister; -- Bypass from execution
                             BP_EX_iRegWrite  : IN  STD_LOGIC;     -- Bypass from  execution

                             In_Ctrl_ID        : IN  TypeIDCtrl;
                             In_Ctrl_Ex        : IN  TypeExCtrl;
                             In_Ctrl_Mem       : IN  TypeMemCtrl;
                             In_Ctrl_WB        : IN  TypeWBCtrl;
                             In_MemBusAccess_n : IN  STD_LOGIC;

                             ID_Stall : OUT STD_LOGIC;
                             ID_Req   : OUT STD_LOGIC;
                             ID_BAddr : OUT TypeWord;

                             ID_Ctrl_Ex  : OUT TypeExCtrl;
                             ID_Ctrl_Mem : OUT TypeMemCtrl;
                             ID_Ctrl_WB  : OUT TypeWBCtrl;
                             ID_A        : OUT TypeWord;
                             ID_B        : OUT TypeWord;
                             ID_IMM      : OUT TypeWord;
                             ID_Shift    : OUT TypeRegister;
                             ID_DestReg  : OUT TypeRegister;
                             ID_IP       : OUT TypeWord;

                             oReg : OUT TypeArrayWord(7 DOWNTO 0)
                            );
  END COMPONENT;

  COMPONENT Execute IS PORT (
                             Clk              : IN STD_LOGIC;
                             Reset            : IN STD_LOGIC;
                             Rdy_n            : IN STD_LOGIC;
                             In_Ctrl_Ex       : IN TypeExCtrl;
                             In_Ctrl_Mem      : IN TypeMEMCtrl;
                             In_Ctrl_WB       : IN TypeWBCtrl;
                             In_A             : IN TypeWord;
                             In_B             : IN TypeWord;
                             In_IMM           : IN TypeWord;
                             In_Shift         : IN TypeRegister;
                             In_DestReg       : IN TypeRegister;
                             In_IP            : IN TypeWord;

                             BP_EX_iData      : OUT TypeWord;     -- Bypass to  idecode
                             BP_EX_iRDest     : OUT TypeRegister; -- Bypass to idecode
                             BP_EX_iRegWrite  : OUT STD_LOGIC;    -- Bypass to idecode

                             EX_Ctrl_WB       : OUT TypeWBCtrl;
                             EX_Ctrl_Mem      : OUT TypeMemCtrl;
                             EX_ALU           : OUT TypeWord;
                             EX_DATA          : OUT TypeWord;
                             EX_DestReg       : OUT TypeRegister
                             );
  END COMPONENT;

  COMPONENT MemStage IS PORT (
                              Clk               : IN STD_LOGIC;
                              Reset             : IN STD_LOGIC;
                              Rdy_n             : IN  STD_LOGIC;
                              In_Ctrl_WB        : IN TypeWBCtrl;
                              In_Ctrl_Mem       : IN TypeMEMCtrl;
                              In_ALU            : IN TypeWord;
                              In_Data           : IN TypeWord;
                              In_DestReg        : IN TypeRegister;
                              In_IntBusGrant_n  : IN  STD_LOGIC;

                              Bus_Data          : INOUT TypeWord;
                              Bus_Addr          : OUT TypeWord;
                              Bus_Rd_n          : OUT STD_LOGIC;
                              Bus_Wr_n          : OUT STD_LOGIC;

                              BP_Mem_iData      : OUT TypeWord;     -- Bypass to idecode
                              BP_Mem_iRDest     : OUT TypeRegister; -- Bypass to idecode
                              BP_Mem_iRegWrite  : OUT STD_LOGIC;  -- Bypass to idecode

                              Mem_Ctrl_WB       : OUT TypeWBCtrl;
                              Mem_Data          : OUT TypeWord;
                              Mem_DestReg       : OUT TypeRegister
                              );
  END COMPONENT;

  -- Controller
  SIGNAL  ctrl_IF : TypeIFCtrl;
  SIGNAL  ctrl_ID : TypeIDCtrl;
  SIGNAL  ctrl_Ex : TypeExCtrl;
  SIGNAL  ctrl_Mem: TypeMemCtrl;
  SIGNAL  ctrl_WB : TypeWBCtrl;

  -- IntBusSM
  SIGNAL  ib_IntBusGrant_n  :  STD_LOGIC;  -- Bus grant SIGNAL

  -- ifetch
  SIGNAL IF_IP         :  TypeWord;
  SIGNAL IF_Instr      :  TypeWord := (OTHERS => '0');      -- Avoid metastability during simulation

  -- iDecode
  SIGNAL ID_Stall     : STD_LOGIC   ;
  SIGNAL ID_Req       : STD_LOGIC   ;
  SIGNAL ID_BAddr     : TypeWord    ;
  SIGNAL ID_Ctrl_Ex   : TypeExCtrl  ;
  SIGNAL ID_Ctrl_Mem  : TypeMemCtrl ;
  SIGNAL ID_Ctrl_WB   : TypeWBCtrl  ;
  SIGNAL ID_A         : TypeWord    ;
  SIGNAL ID_B         : TypeWord    ;
  SIGNAL ID_IMM       : TypeWord    ;
  SIGNAL ID_Shift     : TypeRegister;
  SIGNAL ID_DestReg   : TypeRegister;
  SIGNAL ID_IP        : TypeWord    ;

  -- Execute
  SIGNAL BP_EX_iData      : TypeWord    ; -- Bypass to idecode
  SIGNAL BP_EX_iRDest     : TypeRegister; -- Bypass to idecode
  SIGNAL BP_EX_iRegWrite  : STD_LOGIC   ; -- Bypass to idecode
  SIGNAL BP_Mem_iData     : TypeWord    ; -- Bypass to idecode
  SIGNAL BP_Mem_iRDest    : TypeRegister; -- Bypass to idecode
  SIGNAL BP_Mem_iRegWrite : STD_LOGIC   ; -- Bypass to idecode

  SIGNAL EX_Ctrl_Mem      : TypeMemCtrl;
  SIGNAL EX_Ctrl_WB       : TypeWBCtrl ;
  SIGNAL EX_ALU           : TypeWord   ;
  SIGNAL EX_DATA          : TypeWord   ;
  SIGNAL EX_DestReg       : TypeRegister := (OTHERS => '0');

  -- Memstage
  SIGNAL Mem_Ctrl_WB      : TypeWBCtrl;
  SIGNAL Mem_Data         : TypeWord := (OTHERS => '0')    ;
  SIGNAL Mem_DestReg      : TypeRegister := (OTHERS => '0'); -- Avoid metastability during simulation


BEGIN

  controller1: controller
    PORT MAP (
              Instr     =>  IF_Instr ,
              Ctrl_IF   =>  ctrl_IF  ,
              Ctrl_ID   =>  ctrl_ID  ,
              Ctrl_Ex   =>  ctrl_Ex  ,
              Ctrl_Mem  =>  ctrl_Mem ,
              Ctrl_WB   =>  ctrl_WB
              );

  intBusSM1: IntBusSM
    PORT MAP (
              Clk           => Clk                        ,
              Reset         => Reset                      ,
              Rdy_n         => Rdy_n                      ,
              IntBusReq_n   => ID_Ctrl_Mem.MemBusAccess_n ,    -- Internal bus request signal
              IntBusGrant_n => ib_IntBusGrant_n
             );

  ifetch1: ifetch
    PORT MAP (
              Clk         =>  Clk      ,
              Reset       =>  reset    ,
              In_Stall_IF =>  ID_Stall ,
              In_ID_Req   =>  ID_Req   ,
              In_ID_BAddr =>  ID_Baddr ,
              In_Ctrl_IF  =>  ctrl_IF  ,
              Init_n      =>  Init_n   ,
              Rdy_n       =>  Rdy_n    ,
              Bus_Data    =>  Bus_Data ,
              Bus_Addr    =>  Bus_Addr ,
              Bus_Rd_n    =>  Bus_Rd_n ,
              Bus_Wr_n    =>  Bus_Wr_n ,
              IF_IP       =>  if_ip    ,
              IF_Instr    =>  if_instr
              );

  IDecode1: IDecode
    PORT MAP (
              Clk               => Clk                        ,
              Reset             => reset                      ,
              Rdy_n             => Rdy_n                      ,
              WriteRegEn        => Mem_Ctrl_WB.RegWrite       ,
              WriteData         => Mem_Data                   ,
              WriteAddr         => Mem_DestReg                ,
              In_IP             => IF_IP                      ,
              In_Instr          => IF_Instr                   ,

              BP_Mem_iData      => BP_Mem_iData               ,  -- Bypass from memstage
              BP_Mem_iRDest     => BP_Mem_iRDest              ,  -- Bypass from memstage
              BP_Mem_iRegWrite  => BP_Mem_iRegWrite           ,  -- Bypass from memstage
              BP_EX_iData       => BP_EX_iData                ,  -- Bypass from execution
              BP_EX_iRDest      => BP_EX_iRDest               ,  -- Bypass from execution
              BP_EX_iRegWrite   => BP_EX_iRegWrite            ,  -- Bypass from execution

              In_Ctrl_ID        => ctrl_ID                    ,
              In_Ctrl_Ex        => ctrl_Ex                    ,
              In_Ctrl_Mem       => ctrl_Mem                   ,
              In_Ctrl_WB        => ctrl_WB                    ,

              In_MemBusAccess_n => Ex_Ctrl_mem.MemBusAccess_n ,

              ID_Stall          => ID_Stall                   ,
              ID_Req            => ID_Req                     ,
              ID_BAddr          => ID_BAddr                   ,

              ID_Ctrl_Ex        => ID_Ctrl_Ex                 ,
              ID_Ctrl_Mem       => ID_Ctrl_Mem                ,
              ID_Ctrl_WB        => ID_Ctrl_WB                 ,
              ID_A              => ID_A                       ,
              ID_B              => ID_B                       ,
              ID_IMM            => ID_IMM                     ,
              ID_Shift          => ID_Shift                   ,
              ID_DestReg        => ID_DestReg                 ,
              ID_IP             => ID_IP                      ,

              oReg              => oReg
            );

  execute1: execute
   PORT MAP (
              Clk             => Clk            ,
              Reset           => reset          ,
              Rdy_n           => Rdy_n          ,
              In_Ctrl_WB      => ID_Ctrl_WB     ,
              In_Ctrl_Mem     => ID_Ctrl_Mem    ,
              In_Ctrl_Ex      => ID_Ctrl_Ex     ,
              In_A            => ID_A           ,
              In_B            => ID_B           ,
              In_IMM          => ID_IMM         ,
              In_Shift        => ID_Shift       ,
              In_DestReg      => ID_DestReg     ,
              In_IP           => ID_IP          ,
              BP_EX_iData     => BP_EX_iData    ,
              BP_EX_iRDest    => BP_EX_iRDest   ,
              BP_EX_iRegWrite => BP_EX_iRegWrite,
              EX_Ctrl_Mem     => EX_Ctrl_Mem    ,
              EX_Ctrl_WB      => EX_Ctrl_WB     ,
              EX_ALU          => EX_ALU         ,
              EX_DATA         => EX_DATA        ,
              EX_DestReg      => EX_DestReg
          );
  memstage1:  memstage
    PORT MAP (
              Clk              => Clk              ,
              Reset            => reset            ,
              Rdy_n            => Rdy_n            ,
              In_Ctrl_WB       => EX_Ctrl_WB       ,
              In_Ctrl_Mem      => EX_Ctrl_Mem      ,
              In_ALU           => EX_ALU           ,
              In_Data          => EX_Data          ,
              In_DestReg       => EX_DestReg       ,

              In_IntBusGrant_n => ib_IntBusGrant_n ,

              Bus_Data         => Bus_Data         ,
              Bus_Addr         => Bus_Addr         ,
              Bus_Rd_n         => Bus_Rd_n         ,
              Bus_Wr_n         => Bus_Wr_n         ,
              BP_Mem_iData     => BP_Mem_iData     ,
              BP_Mem_iRDest    => BP_Mem_iRDest    ,
              BP_Mem_iRegWrite => BP_Mem_iRegWrite ,
              Mem_Ctrl_WB      => Mem_Ctrl_WB      ,
              Mem_Data         => Mem_Data         ,
              Mem_DestReg      => Mem_DestReg
            );

  IP    <= IF_IP;
  Instr <= IF_Instr;
  ALU   <= EX_ALU;


END behavior;