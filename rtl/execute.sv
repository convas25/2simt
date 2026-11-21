module execute
import rv32i_types::*;
(
    input   id_ex_t id_ex,
    output  ex_mem_t ex_mem_next,
    input ex_mem_t ex_mem,
    input mem_wb_t mem_wb,
    input [31:0] rs1_v, rs2_v
);

  logic [31:0] wb_data, alu_result;
  logic [31:0] inst;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:0] pc;
  logic [31:0] imm_val;
  logic [31:0] mem_addr, mem_wdata;
  logic [3:0] mem_wmask, mem_rmask;
  logic cmp_en;
  logic mem_check;
  rv32i_opcode opcode;
  logic [31:0] ex_mem_rdv, mem_wb_rdv;
  logic [4:0] ex_mem_rds, mem_wb_rds;
  logic ex_mem_regwe, mem_wb_regwe;

  assign ex_mem_rdv = ex_mem.wb_data;
  assign ex_mem_rds = ex_mem.rd_s;
  assign ex_mem_regwe = ex_mem.regf_we;
  assign mem_wb_rdv = mem_wb.wb_data;
  assign mem_wb_rds = mem_wb.rd_s;
  assign mem_wb_regwe = mem_wb.regf_we;

  assign inst = id_ex.instruction;
  assign opcode = rv32i_opcode'(inst[6:0]);
  assign funct3 = inst[14:12];
  assign funct7 = inst[31:25];
  assign imm_val = id_ex.imm_val;
  assign pc = id_ex.pc;
  
alu_m1_sel_t m1;
    assign m1 = id_ex.alu_m1_sel;

alu_m2_sel_t m2;
    assign m2 = id_ex.alu_m2_sel;
logic [31:0] op1;
logic [31:0] op2;
logic [31:0] rs2_vnew, rs1_vnew;
always_comb begin
  unique case (m1)
    rs1_out: begin
      if(ex_mem.valid && (ex_mem_regwe == 1) && (ex_mem_rds != 0) && (ex_mem_rds == id_ex.rs1_s)) begin
        rs1_vnew = ex_mem_rdv;
        op1 = ex_mem_rdv;
      end else if(mem_wb.valid && (mem_wb_regwe == 1) && (mem_wb_rds != 0) && (mem_wb_rds == id_ex.rs1_s)) begin
        rs1_vnew = mem_wb_rdv;
        op1 = mem_wb_rdv;
      end else begin
        rs1_vnew = rs1_v;
        op1 = rs1_v;
      end
    end
    pc_out  : begin
      op1 = pc;
      rs1_vnew = rs1_v;
    end
    zero_out: begin
      op1 = 32'd0;
      rs1_vnew = rs1_v;
    end
    default : begin
      op1 = 32'd0;
      rs1_vnew = rs1_v;
    end
  endcase
  unique case (m2)
    rs2_out: begin
      if(ex_mem.valid && (ex_mem_regwe == 1) && (ex_mem_rds != 0) && (ex_mem_rds == id_ex.rs2_s)) begin
        rs2_vnew = ex_mem_rdv;
        op2 = ex_mem_rdv;
      end else if(mem_wb.valid && (mem_wb_regwe == 1) && (mem_wb_rds != 0) && (mem_wb_rds == id_ex.rs2_s)) begin
        rs2_vnew = mem_wb_rdv;
        op2 = mem_wb_rdv;
      end else begin
        rs2_vnew = rs2_v;
        op2 = rs2_v;
      end
    end
    imm_out: begin
      op2 = imm_val;
      if(ex_mem.valid && (ex_mem_regwe == 1) && (ex_mem_rds != 0) && (ex_mem_rds == id_ex.rs2_s)) begin
        rs2_vnew = ex_mem_rdv;
      end else if(mem_wb.valid && (mem_wb_regwe == 1) && (mem_wb_rds != 0) && (mem_wb_rds == id_ex.rs2_s)) begin
        rs2_vnew = mem_wb_rdv;
      end else begin
        rs2_vnew = rs2_v;
      end
    end
    default: begin
      op2 = 32'd0;
      rs2_vnew = rs2_v;
    end
  endcase
end

logic [31:0] eff_addr;
alu_ops     aluop;
branch_f3_t cmpop;
logic use_cmpop;
always_comb begin
    // safe defaults
    aluop = alu_op_add;
    use_cmpop = 1'b0;
    cmpop = branch_f3_beq;
    mem_addr = '0;
    eff_addr = '0;
    mem_rmask = 4'd0;
    mem_wmask = 4'd0;
    mem_wdata = '0;
    mem_check = '0;
    unique case (opcode)
      op_b_reg: begin // R-type
        unique case (arith_f3_t'(funct3))
          arith_f3_add: aluop = (funct7[5] ? alu_op_sub : alu_op_add);
          arith_f3_sll: aluop = alu_op_sll;
          arith_f3_slt: begin
            cmpop = branch_f3_blt;
            use_cmpop = 1'b1;
          end
          arith_f3_sltu: begin
            cmpop = branch_f3_bltu;
            use_cmpop = 1'b1;
          end
          arith_f3_xor: aluop = alu_op_xor;
          arith_f3_sr: aluop = (funct7[5] ? alu_op_sra : alu_op_srl);
          arith_f3_or: aluop = alu_op_or;
          arith_f3_and: aluop = alu_op_and;
          default: aluop = alu_op_add;
        endcase
      end
      op_b_imm: begin // I-type
        unique case (arith_f3_t'(funct3))
          arith_f3_add: aluop = alu_op_add;
          arith_f3_sll: aluop = alu_op_sll;
          arith_f3_slt: begin
            cmpop = branch_f3_blt;
            use_cmpop = 1'b1;
          end
          arith_f3_sltu: begin
            cmpop = branch_f3_bltu;
            use_cmpop = 1'b1;
          end
          arith_f3_xor: aluop = alu_op_xor;
          arith_f3_sr: aluop = (funct7[5] ? alu_op_sra : alu_op_srl);
          arith_f3_or: aluop = alu_op_or;
          arith_f3_and: aluop = alu_op_and;
          default: aluop = alu_op_add;
        endcase
      end
      op_b_load: begin // Load-type
        aluop = alu_op_add;
        eff_addr = alu_result;
        mem_addr = {eff_addr[31:2], 2'b00};
        if(id_ex.valid) begin
          mem_check = '1;
        unique case (load_f3_t'(funct3))
          load_f3_lb, load_f3_lbu: mem_rmask = 4'b0001 << eff_addr[1:0];
          load_f3_lh, load_f3_lhu: mem_rmask = 4'b0011 << eff_addr[1:0];
          load_f3_lw             : mem_rmask = 4'b1111;
          default                : mem_rmask = '0;
        endcase
        end else begin
          mem_check = '0;
          mem_rmask = '0;
        end
      end
      op_b_store: begin // Store-type
        aluop = alu_op_add;
        eff_addr = alu_result;
        mem_addr = {eff_addr[31:2], 2'b00};
        if(id_ex.valid) begin
          mem_check = '1;
        unique case (store_f3_t'(funct3))
          store_f3_sb: begin
            mem_wmask = 4'b0001 << eff_addr[1:0];
            mem_wdata[8 *eff_addr[1:0] +: 8 ] = rs2_vnew[7 :0];
          end
          store_f3_sh: begin
            mem_wmask = 4'b0011 << eff_addr[1:0];
            mem_wdata[16*eff_addr[1]   +: 16] = rs2_vnew[15:0];
          end
          store_f3_sw: begin
            mem_wmask = 4'b1111;
            mem_wdata = rs2_vnew;
          end
          default: begin
            mem_wmask = '0;
            mem_wdata = '0;
          end
        endcase
        end else begin
          mem_check = '0;
          mem_wmask = '0;
        end
      end
      op_b_jal: begin
        eff_addr = alu_result;

      end
      op_b_jalr: begin
        eff_addr = alu_result & 32'hfffffffe;
      end
      op_b_br: begin
        eff_addr = pc + imm_val;
        use_cmpop = 1'b1;
        cmpop = branch_f3_t'(funct3);
      end

      op_b_auipc: begin
        aluop = alu_op_add;
      end

      default: begin
        aluop = alu_op_add;
      end
    endcase
  end
  // OPERATIONS
always_comb begin
    unique case (aluop)
      alu_op_add: alu_result = op1 + op2;
      alu_op_sub: alu_result = op1 - op2;
      alu_op_and: alu_result = op1 & op2;
      alu_op_or : alu_result = op1 | op2;
      alu_op_xor: alu_result = op1 ^ op2;
      alu_op_sll: alu_result = op1 << op2[4:0];
      alu_op_srl: alu_result = op1 >> op2[4:0];
      alu_op_sra: alu_result = $unsigned($signed(op1) >>> op2[4:0]);
      default:    alu_result = 32'b0;
    endcase
    unique case (cmpop)
      branch_f3_beq : cmp_en = (op1 == op2);
      branch_f3_bne : cmp_en = (op1 != op2);
      branch_f3_blt : cmp_en = ($signed(op1) < $signed(op2));
      branch_f3_bge : cmp_en = ($signed(op1) >= $signed(op2));
      branch_f3_bltu: cmp_en = (op1 < op2);
      branch_f3_bgeu: cmp_en = (op1 >=  op2);
      default: cmp_en = 1'b0;
    endcase
  end
logic [31:0] cmp_res;
logic [31:0] store_data;
assign store_data = mem_wdata;
assign cmp_res = {31'd0, cmp_en};
always_comb begin
    unique case (opcode)
      op_b_lui: wb_data = imm_val;
      op_b_store: wb_data = '0;
      op_b_load: wb_data = '0;
      op_b_jal:   wb_data = pc + 32'd4;
      op_b_jalr:  wb_data = pc + 32'd4; 
      op_b_br:    wb_data = '0;
      op_b_reg, op_b_imm, op_b_auipc: wb_data = (use_cmpop) ? cmp_res : alu_result;
      default:    wb_data = '0;
    endcase
  end
always_comb begin
    ex_mem_next.pc = pc;
    ex_mem_next.next_pc = ((opcode == op_b_br && cmp_en) || opcode == op_b_jal || opcode == op_b_jalr) ? eff_addr : id_ex.next_pc;
    ex_mem_next.instruction = inst;
    ex_mem_next.rs1_v = rs1_vnew;
    ex_mem_next.rs2_v = rs2_vnew;
    ex_mem_next.rs1_s = id_ex.rs1_s;
    ex_mem_next.rs2_s = id_ex.rs2_s;
    ex_mem_next.valid = id_ex.valid;
    ex_mem_next.rd_s = (opcode == op_b_store || opcode == op_b_br) ? 5'd0 : id_ex.rd_s;
    //execute signals
    ex_mem_next.wb_data = wb_data;
    ex_mem_next.regf_we = id_ex.regf_we;
    ex_mem_next.dmem_wmask = mem_wmask;
    ex_mem_next.dmem_rmask = mem_rmask;
    ex_mem_next.mem_addr = mem_addr;
    ex_mem_next.store_data = store_data;
    ex_mem_next.eff_addr = eff_addr;
    ex_mem_next.mem_check = mem_check;
    ex_mem_next.cmp_en = cmp_en;
    ex_mem_next.opcode = opcode;
end

endmodule : execute
