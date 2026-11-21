module memory
import rv32i_types::*;
(   
    output  logic   [31:0]  dmem_addr,
    input   logic   [31:0]  mem_rdata, latched_rdata,
    output  logic   [3:0]   dmem_rmask,
    output  logic   [3:0]   dmem_wmask,
    output  logic   [31:0]  dmem_wdata,
    input   logic           dmem_resp, dresp_check,
    input ex_mem_t ex_mem,
    output mem_wb_t mem_wb_next
);  

    logic [31:0] load_data;
    rv32i_opcode opcode;
    logic [2:0] funct3;
    logic [31:0] wb_data;
    logic [31:0] inst, mem_addr, eff_addr, choose_rdata;

    assign choose_rdata = (dmem_resp) ? mem_rdata : latched_rdata;
    assign eff_addr = ex_mem.eff_addr;
    assign mem_addr = ex_mem.mem_addr;
    assign dmem_addr = mem_addr;
    assign opcode = rv32i_opcode'(inst[6:0]);
    assign funct3 = inst[14:12];
    assign inst = ex_mem.instruction;
    // assign dmem_rmask = ex_mem.dmem_rmask;
    // assign dmem_wmask = ex_mem.dmem_wmask;
    assign dmem_wdata = ex_mem.store_data;
    always_comb begin
        load_data = 32'b0;
        dmem_wmask = ex_mem.dmem_wmask;
        dmem_rmask = ex_mem.dmem_rmask;
        unique case (opcode)
        op_b_load: begin
                unique case (load_f3_t'(funct3))
                    load_f3_lb : load_data = {{24{choose_rdata[7 +8 *eff_addr[1:0]]}}, choose_rdata[8 *eff_addr[1:0] +: 8 ]};
                    load_f3_lbu: load_data = {{24{1'b0}}                          , choose_rdata[8 *eff_addr[1:0] +: 8 ]};
                    load_f3_lh : load_data = {{16{choose_rdata[15+16*eff_addr[1]  ]}}, choose_rdata[16*eff_addr[1]   +: 16]};
                    load_f3_lhu: load_data = {{16{1'b0}}                          , choose_rdata[16*eff_addr[1]   +: 16]};
                    load_f3_lw : load_data = choose_rdata;
                    default    : load_data = '0;
                endcase
                if(dmem_resp | dresp_check) begin
                dmem_rmask = '0;
                dmem_wmask = '0;
                end
            end
        op_b_store: begin
            if (dmem_resp | dresp_check) begin
                dmem_rmask = '0;
                dmem_wmask = '0;
            end
        end
        default: load_data = '0;
        endcase
        unique case (opcode)
            op_b_load: wb_data = load_data;
            default: wb_data = ex_mem.wb_data;
        endcase
    end
always_comb begin
    mem_wb_next.pc = ex_mem.pc;
    mem_wb_next.next_pc = ex_mem.next_pc;
    mem_wb_next.instruction = ex_mem.instruction;
    mem_wb_next.valid = ex_mem.valid;
    mem_wb_next.order = ex_mem.order;
    mem_wb_next.rs1_v = ex_mem.rs1_v;
    mem_wb_next.rs2_v = ex_mem.rs2_v;
    mem_wb_next.rs1_s = ex_mem.rs1_s;
    mem_wb_next.rs2_s = ex_mem.rs2_s;
    mem_wb_next.rd_s = ex_mem.rd_s;
    //execute signals
    mem_wb_next.wb_data = wb_data;
   mem_wb_next.regf_we = ex_mem.regf_we;
    mem_wb_next.dmem_wmask = ex_mem.dmem_wmask;
    mem_wb_next.dmem_rmask = ex_mem.dmem_rmask;
    mem_wb_next.mem_addr = ex_mem.mem_addr;
    mem_wb_next.store_data = ex_mem.store_data;
    mem_wb_next.load_data = load_data;
    mem_wb_next.dmem_rdata = choose_rdata;
end



endmodule : memory