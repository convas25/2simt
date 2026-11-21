module cpu_tb;
    timeunit 1ns;
    timeprecision 1ps;

    localparam logic [31:0] BASE_PC = 32'haaaaa000;
    localparam int WORDS = 256;
    logic clk;
    logic rst;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    logic [31:0] imem_addr, imem_rdata;
    logic [3:0] imem_rmask;
    logic imem_resp;
    logic [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    logic [3:0] dmem_rmask, dmem_wmask;
    logic dmem_resp;
    logic [31:0] instructions [WORDS];
    logic [31:0] data [WORDS];

    cpu dut (.*);

    // Registered responses match the original CPU's memory interface timing.
    always @(posedge clk) begin
        if (rst) begin
            imem_resp <= 0;
            dmem_resp <= 0;
            imem_rdata <= 0;
            dmem_rdata <= 0;
        end else begin
            imem_resp <= |imem_rmask;
            if (|imem_rmask) begin
                assert (imem_addr >= BASE_PC && imem_addr < BASE_PC + 4 * WORDS
                        && imem_addr[1:0] == 0)
                    else $fatal(1, "Instruction address out of range: %h", imem_addr);
                imem_rdata <= instructions[(imem_addr - BASE_PC) >> 2];
            end
            dmem_resp <= (|dmem_rmask) || (|dmem_wmask);
            if ((|dmem_rmask) || (|dmem_wmask)) begin
                assert (dmem_addr < 4 * WORDS && dmem_addr[1:0] == 0)
                    else $fatal(1, "Data address out of range: %h", dmem_addr);
                assert (!((|dmem_rmask) && (|dmem_wmask)))
                    else $fatal(1, "Simultaneous data read and write");
                dmem_rdata <= data[dmem_addr >> 2];
                for (int byte_index = 0; byte_index < 4; byte_index++) begin
                    if (dmem_wmask[byte_index])
                        data[dmem_addr >> 2][8*byte_index +: 8] <=
                            dmem_wdata[8*byte_index +: 8];
                end
            end
        end
    end

    // Small encoders avoid requiring an assembler for the baseline regression.
    function automatic logic [31:0] imm_inst(
        input logic [6:0] opcode, input logic [2:0] funct3,
        input logic [4:0] rd, rs1, input logic [11:0] immediate
    );
        return {immediate, rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] store_inst(
        input logic [2:0] funct3, input logic [4:0] rs2, rs1,
        input logic [11:0] immediate
    );
        return {immediate[11:5], rs2, rs1, funct3, immediate[4:0], 7'h23};
    endfunction

    function automatic logic [31:0] branch_inst(
        input logic [2:0] funct3, input logic [4:0] rs1, rs2,
        input logic [12:0] immediate
    );
        return {immediate[12], immediate[10:5], rs2, rs1, funct3,
                immediate[4:1], immediate[11], 7'h63};
    endfunction

    task automatic check_register(input int index, input logic [31:0] expected);
        assert (dut.regfile.data[index] === expected)
            else $fatal(1, "x%0d: expected %h, got %h", index, expected,
                        dut.regfile.data[index]);
    endtask

    initial begin
        rst = 1;
        for (int i = 0; i < WORDS; i++) begin
            instructions[i] = 32'h00000013; // nop
            data[i] = 0;
        end
        instructions[0] = imm_inst(7'h13, 0, 1, 0, 5);    // addi x1, x0, 5
        instructions[1] = imm_inst(7'h13, 0, 2, 1, 7);    // addi x2, x1, 7
        instructions[2] = 32'h001101b3;                   // add x3, x2, x1
        instructions[3] = store_inst(2, 3, 0, 0);         // sw x3, 0(x0)
        instructions[4] = imm_inst(7'h03, 2, 4, 0, 0);    // lw x4, 0(x0)
        instructions[5] = imm_inst(7'h13, 0, 5, 4, 1);    // addi x5, x4, 1
        instructions[6] = branch_inst(0, 5, 5, 12);       // beq x5, x5, +12
        instructions[7] = imm_inst(7'h13, 0, 6, 0, 99);   // flushed
        instructions[8] = store_inst(2, 1, 0, 4);         // flushed store
        instructions[9] = imm_inst(7'h13, 0, 6, 0, 42);   // addi x6, x0, 42
        instructions[10] = imm_inst(7'h13, 0, 0, 0, 123); // x0 stays zero
        instructions[11] = imm_inst(7'h13, 0, 7, 0, 12'hfff); // x7 = -1
        instructions[12] = store_inst(0, 7, 0, 9);        // sb x7, 9(x0)
        instructions[13] = imm_inst(7'h03, 0, 8, 0, 9);   // lb x8, 9(x0)
        instructions[14] = imm_inst(7'h03, 4, 9, 0, 9);   // lbu x9, 9(x0)
        instructions[15] = store_inst(1, 7, 0, 14);       // sh x7, 14(x0)
        instructions[16] = imm_inst(7'h03, 1, 10, 0, 14); // lh x10, 14(x0)
        instructions[17] = imm_inst(7'h03, 5, 11, 0, 14); // lhu x11, 14(x0)
        instructions[18] = 32'h0080066f;                  // jal x12, +8
        instructions[19] = imm_inst(7'h13, 0, 6, 0, 99);  // flushed
        instructions[20] = 32'h00000697;                  // auipc x13, 0
        instructions[21] = imm_inst(7'h13, 0, 13, 13, 16);// target = PC[24]
        instructions[22] = imm_inst(7'h67, 0, 14, 13, 0); // jalr x14, 0(x13)
        instructions[23] = imm_inst(7'h13, 0, 6, 0, 99);  // flushed
        instructions[24] = branch_inst(1, 1, 1, 8);      // bne not taken
        instructions[25] = imm_inst(7'h13, 0, 15, 0, 55);// addi x15, x0, 55
        instructions[26] = 32'h0000006f;                  // jal x0, 0

        repeat (3) @(negedge clk);
        rst = 0;
        repeat (250) @(negedge clk);
        check_register(0, 0);
        check_register(1, 5);
        check_register(2, 12);
        check_register(3, 17);
        check_register(4, 17);
        check_register(5, 18);
        check_register(6, 42);
        check_register(7, 32'hffffffff);
        check_register(8, 32'hffffffff);
        check_register(9, 255);
        check_register(10, 32'hffffffff);
        check_register(11, 65535);
        check_register(12, BASE_PC + 76);
        check_register(13, BASE_PC + 96);
        check_register(14, BASE_PC + 92);
        check_register(15, 55);
        assert (data[0] === 17 && data[1] === 0 && data[2] === 32'h0000ff00
                && data[3] === 32'hffff0000)
            else $fatal(1, "Store result, mask, or branch flush mismatch");
        $display("PASS: scalar RV32I forwarding, load-use, branch flush, jumps, x0, and masked memory");
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "CPU regression timed out");
    end
endmodule
