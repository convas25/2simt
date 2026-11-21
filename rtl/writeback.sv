module writeback
import rv32i_types::*;
(
    input  mem_wb_t mem_wb,
    output [31:0] wb_data
);

assign wb_data = mem_wb.wb_data;
endmodule : writeback