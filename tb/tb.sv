
module cvfpu_tb #(
  parameter CLK_PERIOD = 10
) (
    // Ports list
);


// Declare testbench signals
logic clk;
logic rst_ni;
logic [2:0][31:0] operands_i;
fpnew_pkg::roundmode_e rnd_mode_i;
fpnew_pkg::operation_e op_i;
logic op_mod_i;
fpnew_pkg::fp_format_e src_fmt_i;
fpnew_pkg::fp_format_e dst_fmt_i;
fpnew_pkg::int_format_e int_fmt_i;
logic vectorial_op_i;
logic in_valid_i;
logic in_ready_o;
logic flush_i;
logic [31:0] result_o;
fpnew_pkg::status_t status_o;
logic out_valid_o;
logic out_ready_i;
logic tag_o;
logic busy_o;

// Variables for testing
integer file_rd, file_wr, rd_cnt;
string cmd;
integer debug;

// Instantiate and connect DUT
fpnew_top #(
    .Features       (fpnew_pkg::RV32F),
    .Implementation (fpnew_pkg::DEFAULT_SNITCH)
) i_fpnew_top (
    .clk_i(clk),
    .rst_ni(rst_ni),
    .operands_i(operands_i),
    .rnd_mode_i(rnd_mode_i),
    .op_i(op_i),
    .op_mod_i(op_mod_i),
    .src_fmt_i(src_fmt_i),
    .dst_fmt_i(dst_fmt_i),
    .int_fmt_i(int_fmt_i),
    .vectorial_op_i(vectorial_op_i),
    .tag_i(1'b0),
    .simd_mask_i(1'b0),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),
    .flush_i(flush_i),
    .result_o(result_o),
    .status_o(status_o),
    .tag_o(tag_o),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),
    .busy_o(busy_o)
);

// Generate clock signal
always #(CLK_PERIOD/2) clk = ~clk;

// Generate timeout
always begin
    #(CLK_PERIOD*1000) $finish;
end

// Verification begin
initial begin
    // Start test and set parameters
    $display("CVFPU Test:");
    $value$plusargs("DEBUG=%d", debug);
    $display("DEBUG=%d", debug);

    //Dump waveform
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, cvfpu_tb,"+all");

    // File IO
    file_rd = $fopen("input.txt", "r");
    file_wr = $fopen("output.txt", "w");

    // Initialize testbench and cvfpu
    init();
    // Reset cvfpu
    release_reset();

    $display("Initialize done\n");
    #(CLK_PERIOD*10);

    test_instr();

    $fclose(file_rd);
    $fclose(file_wr);

    $finish;

end

function void init();
    // Initialize cvfpu, give initial values to all inputs
    clk <=  0;
    rst_ni <= 1;
    operands_i <= {32'h00000000, 32'h00000000, 32'h00000000};
    rnd_mode_i <= fpnew_pkg::RNE;
    op_i <= fpnew_pkg::FMADD;
    op_mod_i <= 0;
    src_fmt_i <= fpnew_pkg::FP32;
    dst_fmt_i <= fpnew_pkg::FP32;
    int_fmt_i <= fpnew_pkg::INT32;
    vectorial_op_i <= 0;
    in_valid_i <= 0; // tb request to send data to cvfpu
    out_ready_i <= 0; // tb ready to receive data from cvfpu
    flush_i <= 0; // synchronous pipline reset
endfunction

task release_reset();
    #(CLK_PERIOD) rst_ni <= 0;
    #(CLK_PERIOD*5) rst_ni <= 1;
endtask

// read a input file to generate test
task test_instr ();
    begin
        while(!$feof(file_rd)) begin
            @(posedge clk);
            rd_cnt = $fscanf(file_rd, "%s %h %h", cmd, operands_i[1], operands_i[2]);
            if (rd_cnt <= 0) begin
                $display("End of test\n");
                break;
            end
            // Input phase
            set_operation();
            in_valid_i <= 1;
            // Wait until cvfpu is ready to receive data
            wait(in_ready_o == 1);
            @(posedge clk);
            in_valid_i <= 0;
            if(debug) begin
                $display("intput operands: %s %h %h\n", cmd, operands_i[1], operands_i[2]);
            end
            
            // Output phase
            wait(out_valid_o == 1); 
            @(posedge clk);
            out_ready_i <= 1;
            if(debug) begin
                $display("output result: %h\n", result_o);
            end
            $fwrite(file_wr, "%s %h %h %h\n", cmd, operands_i[1], operands_i[2], result_o);
            @(posedge clk);
            out_ready_i <= 0;
            #(CLK_PERIOD*5);
        end
    end
endtask

task set_operation;
    begin
        case (cmd)
            "fadd.s": begin
                op_i <= fpnew_pkg::ADD;
                op_mod_i <= 0;
            end
            "fsub.s": begin
                op_i <= fpnew_pkg::ADD;
                op_mod_i <= 1;
            end
            "fmul.s": begin
                op_i <= fpnew_pkg::MUL;
                op_mod_i <= 0;
            end
            "fmin.s": begin
                op_i <= fpnew_pkg::MINMAX;
                rnd_mode_i <= fpnew_pkg::RNE;
            end
            "fmax.s": begin
                op_i <= fpnew_pkg::MINMAX;
                rnd_mode_i <= fpnew_pkg::RTZ;
            end
            default: begin
                $display("Invalid command: %s", cmd);
                $finish;
            end
        endcase
    end
endtask

endmodule; // end of newfpu_tb