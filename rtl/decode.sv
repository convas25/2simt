module decode
import rv32i_types::*;
(
    output logic [4:0]   rs1_s, rs2_s, rd_s,
    input   if_id_t if_id,
    output  id_ex_t id_ex_next
);

logic [31:0] pc;
logic [31:0] inst;
rv32i_opcode opcode;
logic [31:0] i_imm, u_imm, s_imm, j_imm, b_imm;
logic reg_we;
logic [31:0] imm_val;


assign inst = if_id.instruction;
assign pc = if_id.pc;
assign opcode = rv32i_opcode'(inst[6:0]);
assign rd_s   = inst[11:7];
assign i_imm  = {{21{inst[31]}}, inst[30:20]};
assign u_imm  = {inst[31:12], 12'h000};
assign s_imm  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
assign b_imm  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
assign j_imm  = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};


always_comb begin
    unique case (opcode)
        op_b_reg:  begin
            imm_val = '0;
            rs1_s  = inst[19:15];
            rs2_s  = inst[24:20];
        end
        op_b_imm:  begin
            imm_val = i_imm;
            rs1_s  = inst[19:15];
            rs2_s  = '0;
        end
        op_b_lui:  begin
            imm_val = u_imm;
            rs1_s  = '0;
            rs2_s  = '0;
        end
        op_b_auipc: begin
            imm_val = u_imm;
            rs1_s  = inst[19:15];
            rs2_s  = '0;
        end
        op_b_store: begin
            imm_val = s_imm;
            rs1_s  = inst[19:15];
            rs2_s  = inst[24:20];
        end
        op_b_load: begin
            imm_val = i_imm;
            rs1_s  = inst[19:15];
            rs2_s  = '0;
        end
        op_b_jal: begin
            imm_val = j_imm;
            rs1_s  = '0;
            rs2_s  = '0;
        end
        op_b_jalr: begin
            imm_val = i_imm;
            rs1_s  = inst[19:15];
            rs2_s  = '0;
        end
        op_b_br: begin
            imm_val = b_imm;
            rs1_s  = inst[19:15];
            rs2_s  = inst[24:20];
        end
        default: begin
            imm_val = i_imm;
            rs1_s  = inst[19:15];
            rs2_s  = inst[24:20];
        end
    endcase
    unique case (opcode)
    op_b_reg: reg_we = 1'b1;
    op_b_imm: reg_we = 1'b1;
    op_b_lui: reg_we = 1'b1;
    op_b_auipc: reg_we = 1'b1;
    op_b_load: reg_we = 1'b1;
    op_b_store: reg_we = 1'b0;
    op_b_jal: reg_we = 1'b1;
    op_b_jalr: reg_we = 1'b1;
    op_b_br: reg_we = 1'b0;
    default:   reg_we = 1'b0;
  endcase
end

always_comb begin
    id_ex_next.pc = pc;
    id_ex_next.next_pc = if_id.next_pc;
    id_ex_next.instruction = inst;
    id_ex_next.rs1_s = rs1_s;
    id_ex_next.rs2_s = rs2_s;
    id_ex_next.rd_s = rd_s;
    //decode signals
    id_ex_next.valid = if_id.valid;
    unique case (opcode)
    op_b_reg: begin // R type instructions
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = rs2_out;
    end
    op_b_imm: begin // I type instructions
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_auipc: begin // AUIPC instruction
        id_ex_next.alu_m1_sel = pc_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_lui: begin // LUI instruction
        id_ex_next.alu_m1_sel = zero_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_load: begin // Load instruction
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_store: begin // Store instructions
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_jal: begin // Jal
        id_ex_next.alu_m1_sel = pc_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_jalr: begin // JALR
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = imm_out;
    end
    op_b_br: begin // B-type
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = rs2_out;
    end
    default: begin
        id_ex_next.alu_m1_sel = rs1_out;
        id_ex_next.alu_m2_sel = rs2_out;
    end
endcase
    id_ex_next.imm_val = imm_val;
    id_ex_next.regf_we = reg_we & if_id.valid;
    id_ex_next.opcode = opcode;
end

endmodule : decode
