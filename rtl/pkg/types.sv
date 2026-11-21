package rv32i_types;
    typedef enum logic [6:0] {
        op_b_lui       = 7'b0110111, // load upper immediate (U type)
        op_b_auipc     = 7'b0010111, // add upper immediate PC (U type)
        op_b_jal       = 7'b1101111, // jump and link (J type)
        op_b_jalr      = 7'b1100111, // jump and link register (I type)
        op_b_br        = 7'b1100011, // branch (B type)
        op_b_load      = 7'b0000011, // load (I type)
        op_b_store     = 7'b0100011, // store (S type)
        op_b_imm       = 7'b0010011, // arith ops with register/immediate operands (I type)
        op_b_reg       = 7'b0110011  // arith ops with register operands (R type)
    } rv32i_opcode;

    typedef enum logic [2:0] {
        arith_f3_add   = 3'b000, // check logic 30 for sub if op_reg op
        arith_f3_sll   = 3'b001,
        arith_f3_slt   = 3'b010,
        arith_f3_sltu  = 3'b011,
        arith_f3_xor   = 3'b100,
        arith_f3_sr    = 3'b101, // check logic 30 for logical/arithmetic
        arith_f3_or    = 3'b110,
        arith_f3_and   = 3'b111
    } arith_f3_t;

    typedef enum logic [1:0] {
        rs1_out = 2'b00,
        pc_out  = 2'b01,
        zero_out = 2'b10
    } alu_m1_sel_t;

    typedef enum logic {
        rs2_out = 1'b0,
        imm_out  = 1'b1
    } alu_m2_sel_t;

    typedef enum logic [2:0] {
        load_f3_lb     = 3'b000,
        load_f3_lh     = 3'b001,
        load_f3_lw     = 3'b010,
        load_f3_lbu    = 3'b100,
        load_f3_lhu    = 3'b101
    } load_f3_t;

    typedef enum logic [2:0] {
        store_f3_sb    = 3'b000,
        store_f3_sh    = 3'b001,
        store_f3_sw    = 3'b010
    } store_f3_t;

    typedef enum logic [2:0] {
        branch_f3_beq  = 3'b000,
        branch_f3_bne  = 3'b001,
        branch_f3_blt  = 3'b100,
        branch_f3_bge  = 3'b101,
        branch_f3_bltu = 3'b110,
        branch_f3_bgeu = 3'b111
    } branch_f3_t;

    typedef enum logic [2:0] {
        alu_op_add     = 3'b000,
        alu_op_sll     = 3'b001,
        alu_op_sra     = 3'b010,
        alu_op_sub     = 3'b011,
        alu_op_xor     = 3'b100,
        alu_op_srl     = 3'b101,
        alu_op_or      = 3'b110,
        alu_op_and     = 3'b111
    } alu_ops;


    typedef struct packed {
            logic [31:0] instruction;
            logic [31:0] pc, next_pc;
            logic valid;
        } if_id_t;

        typedef struct packed {
            logic [31:0] instruction;
            logic [31:0] pc, next_pc;
            logic valid;
            //decode signals
            logic [4:0] rs1_s, rs2_s, rd_s;
            logic [31:0] imm_val;
            alu_m1_sel_t alu_m1_sel;
            alu_m2_sel_t alu_m2_sel;
            logic regf_we;
            rv32i_opcode opcode;
        } id_ex_t;

        typedef struct packed {
            logic [31:0] instruction;
            logic [31:0] pc, next_pc;
            logic valid;
            //decode signals
            logic [4:0] rs1_s, rs2_s, rd_s;
            logic [31:0] rs1_v, rs2_v;
            //execute signals
            logic [31:0] wb_data, mem_addr, eff_addr;
            logic regf_we, mem_check;
            logic [3:0] dmem_rmask, dmem_wmask;
            logic [31:0] store_data;
            logic cmp_en;
            rv32i_opcode opcode;
        } ex_mem_t;

        typedef struct packed {
            logic [31:0] instruction;
            logic [31:0] pc, next_pc;
            logic valid;
            //decode signals
            logic [4:0] rs1_s, rs2_s, rd_s;
            logic [31:0] rs1_v, rs2_v;
            //execute signals
            logic [31:0] wb_data, mem_addr;
            logic regf_we;
            logic [3:0] dmem_rmask, dmem_wmask;
            logic [31:0] store_data, dmem_rdata;
            logic [31:0] load_data;
            //memory signals
        } mem_wb_t;


endpackage : rv32i_types
