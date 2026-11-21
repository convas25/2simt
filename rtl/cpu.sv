module cpu
import rv32i_types::*;
(
    input   logic           clk,
    input   logic           rst,

    output  logic   [31:0]  imem_addr,
    output  logic   [3:0]   imem_rmask,
    input   logic   [31:0]  imem_rdata,
    input   logic           imem_resp,

    output  logic   [31:0]  dmem_addr,
    output  logic   [3:0]   dmem_rmask,
    output  logic   [3:0]   dmem_wmask,
    input   logic   [31:0]  dmem_rdata,
    output  logic   [31:0]  dmem_wdata,
    input   logic           dmem_resp
);
<<<<<<< HEAD
logic global_stall, imem_stall, dmem_stall, dresp_check;
logic [31:0] pc, pc_next;
logic branch_taken;
logic [4:0]   rs1_s, rs2_s, rd_s;
logic [31:0]  rs1_v, rs2_v;
logic [31:0] wb_data, latched_rdata;
logic load_hazard;
if_id_t if_id, if_id_next;
id_ex_t id_ex, id_ex_next;
ex_mem_t ex_mem, ex_mem_next;
mem_wb_t mem_wb, mem_wb_next;

assign load_hazard = (id_ex.valid && (id_ex.opcode == op_b_load)) &&
    ((id_ex.rd_s != 0) && 
    ((id_ex.rd_s == rs1_s) || 
    (id_ex.rd_s == rs2_s)));

assign branch_taken = id_ex.valid & (
    (id_ex.opcode == op_b_br && ex_mem_next.cmp_en) ||
    id_ex.opcode == op_b_jal ||
    id_ex.opcode == op_b_jalr);

assign pc_next = branch_taken ? ex_mem_next.eff_addr : (pc + 32'd4);
logic [63:0] order_cpu;
always_ff @(posedge clk) begin
        if (dmem_resp) begin
        dresp_check <= '1;
        latched_rdata <= dmem_rdata;
    end if(~global_stall) begin
        dresp_check <= '0;
    end if (rst) begin
        if_id <= '0;
        id_ex <= '0;
        ex_mem <= '0;
        mem_wb <= '0;
        pc <= 32'haaaaa000;
        order_cpu <= 64'd0;
        dresp_check <= '0;
    end  if (~global_stall) begin
            if (branch_taken) begin
                if_id <= '0;
                id_ex <= '0;
                order_cpu <= order_cpu - 64'd1;
                ex_mem <= ex_mem_next;
                mem_wb <= mem_wb_next;
                pc <= pc_next;
            end else if(load_hazard) begin
                id_ex <= '0;
                if_id <= if_id;
                pc <= pc;
                ex_mem <= ex_mem_next;
                mem_wb <= mem_wb_next;
            end else begin
                if_id <= if_id_next;
                id_ex <= id_ex_next;
                order_cpu <= order_cpu + 64'd1;
                ex_mem <= ex_mem_next;
                mem_wb <= mem_wb_next;
                pc <= pc_next;
            end
        end
    end


assign dmem_stall = (~dresp_check & ~dmem_resp) & ex_mem.mem_check;
assign global_stall = imem_stall | dmem_stall;
logic  regf_we;
assign regf_we = mem_wb.regf_we;

regfile regfile (
  .clk     (clk),
  .rst     (rst),
  .regf_we (regf_we),
  .global_stall(global_stall),
  .rd_v    (wb_data),
  .rs1_s   (rs1_s),
  .rs2_s   (rs2_s),
  .rd_s    (mem_wb.rd_s),
  .rs1_v   (rs1_v),
  .rs2_v   (rs2_v)
);

fetch s_fetch (
  .imem_addr  (imem_addr),
  .imem_rmask (imem_rmask),
  .imem_rdata (imem_rdata),
  .imem_resp  (imem_resp),
  .imem_stall (imem_stall),
    .load_hazard(load_hazard),
    .global_stall(global_stall),
  .order_cpu  (order_cpu),
  .pc         (pc),
  .next_pc    (pc_next),
  .if_id_next (if_id_next)
);
decode s_decode (
        .rs1_s    (rs1_s),
        .rs2_s    (rs2_s),
        .rd_s     (rd_s),
        .if_id    (if_id),
        .id_ex_next(id_ex_next)
    );

execute s_execute (
        .rs1_v    (rs1_v),
        .rs2_v    (rs2_v),
        .id_ex      (id_ex),
        .ex_mem_next(ex_mem_next),
        .ex_mem(ex_mem),
        .mem_wb(mem_wb)
);
memory s_memory (
        .dmem_addr  (dmem_addr),
        .dmem_rmask (dmem_rmask),
        .dmem_wmask (dmem_wmask),
        .dmem_wdata (dmem_wdata),
        .mem_rdata  (dmem_rdata),
        .dmem_resp  (dmem_resp),
        .latched_rdata(latched_rdata),
        .dresp_check(dresp_check),
        .ex_mem (ex_mem),
        .mem_wb_next(mem_wb_next)
);

writeback s_writeback (
        .mem_wb (mem_wb),
        .wb_data (wb_data)
);

// monitor
    logic           monitor_valid;
    logic   [63:0]  monitor_order;
    logic   [31:0]  monitor_inst;
    logic   [4:0]   monitor_rs1_addr;
    logic   [4:0]   monitor_rs2_addr;
    logic   [31:0]  monitor_rs1_rdata;
    logic   [31:0]  monitor_rs2_rdata;
    logic           monitor_regf_we;
    logic   [4:0]   monitor_rd_addr;
    logic   [31:0]  monitor_rd_wdata;
    logic   [31:0]  monitor_pc_rdata;
    logic   [31:0]  monitor_pc_wdata;
    logic   [31:0]  monitor_mem_addr;
    logic   [3:0]   monitor_mem_rmask;
    logic   [3:0]   monitor_mem_wmask;
    logic   [31:0]  monitor_mem_rdata;
    logic   [31:0]  monitor_mem_wdata;
    assign monitor_valid = mem_wb.valid & ~global_stall;
    assign monitor_order = mem_wb.order;
    assign monitor_inst = mem_wb.instruction;
    assign monitor_rs1_addr = mem_wb.rs1_s;
    assign monitor_rs2_addr = mem_wb.rs2_s;
    assign monitor_rs1_rdata = mem_wb.rs1_v;
    assign monitor_rs2_rdata = mem_wb.rs2_v;
    assign monitor_regf_we = mem_wb.regf_we;
    assign monitor_rd_addr = mem_wb.rd_s;
    assign monitor_rd_wdata = mem_wb.wb_data;
    assign monitor_pc_rdata = mem_wb.pc;
    assign monitor_pc_wdata = mem_wb.next_pc;
    assign monitor_mem_addr  = mem_wb.mem_addr;
    assign monitor_mem_rmask = mem_wb.dmem_rmask;
    assign monitor_mem_wmask = mem_wb.dmem_wmask;
    assign monitor_mem_rdata = mem_wb.dmem_rdata;
    assign monitor_mem_wdata = mem_wb.store_data;
=======
>>>>>>> release/main

endmodule : cpu