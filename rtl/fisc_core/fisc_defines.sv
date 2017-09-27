`ifndef FISC_DEFINES_SV_
`define FISC_DEFINES_SV_

/**************************************************************************/
/* File: defines.sv *******************************************************/
/**************************************************************************/

/* FISC Instruction Set Defines ***/
`define FISC_INSTRUCTION_SZ    32
`define FISC_INTEGER_SZ        64
`define FISC_ADDRESS_BOOT_SZ   11

`define FISC_REGISTER_GP_COUNT 32 /* General Purpose registers */
`define FISC_REGISTER_SP_COUNT 14 /* Special registers         */

`define R_FMT_OPCODE_SZ        11
`define R_FMT_RM_SZ            5
`define R_FMT_SHAMT_SZ         6
`define R_FMT_RN_SZ            5
`define R_FMT_RD_SZ            5

`define I_FMT_OPCODE_SZ        10
`define I_FMT_ALUI_SZ          12
`define I_FMT_RN_SZ            5
`define I_FMT_RD_SZ            5

`define D_FMT_OPCODE_SZ        11
`define D_FMT_DT_ADDR_SZ       9
`define D_FMT_OP_SZ            2
`define D_FMT_RN_SZ            5
`define D_FMT_RT_SZ            5

`define B_FMT_OPCODE_SZ        6
`define B_FMT_BR_ADDR          26

`define CB_FMT_OPCODE_SZ       8
`define CB_FMT_COND_BR_ADDR_SZ 19
`define CB_FMT_RT_SZ           5

`define IW_FMT_OPCODE_SZ       11
`define IW_FMT_MOVI_SZ         16
`define IW_FMT_RD_SZ           5

/* Microcode Unit Defines */
`define CTRL_WIDTH             32
`define FUNC_WIDTH             32
`define CTRL_DEPTH             256
`define SEGMENT_MAXCOUNT       256
`define CTRL_DEPTH_ENC         ($clog2(`CTRL_DEPTH) - 1)
`define SEGMENT_MAXCOUNT_ENC   ($clog2(`SEGMENT_MAXCOUNT) - 1)
`define CALLSTACK_SIZE         256

`define ALIGN_INSTR(val) ((val) << 2)	

`endif