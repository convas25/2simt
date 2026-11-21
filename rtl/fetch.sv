module fetch
import rv32i_types::*;
(
    input logic [63:0] order_cpu,
    output  logic   [31:0]  imem_addr,
    output  logic   [3:0]   imem_rmask,
    input   logic   [31:0]  imem_rdata,
    input   logic           imem_resp,
    output logic imem_stall,
    input logic global_stall, load_hazard,
    input  logic   [31:0]  pc, next_pc,
    output if_id_t if_id_next
);
assign imem_rmask = '1;
assign imem_stall = ~imem_resp;
always_comb begin
    imem_addr = pc;
    if(imem_resp & ~global_stall & !load_hazard) begin
        imem_addr = next_pc;
    end
    if_id_next.valid = imem_resp;
    if_id_next.pc = pc;
    if_id_next.next_pc = next_pc;
    if_id_next.instruction = imem_rdata;
    if_id_next.order = order_cpu;
end



endmodule : fetch