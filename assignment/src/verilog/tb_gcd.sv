module tb_gcd #(
    parameter real CLK = 10,
    parameter real OFFSET = 0,
    parameter int WIDTH = 8,
    parameter int TESTCASES = (1 << 2*WIDTH)
);
    logic clk_i, rst_i;                 // global
	logic valid_i;                      // start
	logic [WIDTH-1:0]a_i, b_i;          // operands
	logic [WIDTH-1:0]gcd_o;             // gcd output
	logic            valid_o;           // valid_o

    logic [1000:0] random_seed, testname;
    integer returnval;

`include "tasks.sv"
    logic [WIDTH-1:0] as[], bs[];       // stimulus
    Transcation tr;                     // transaction stimulus

    gcd #(.WIDTH(WIDTH)) DUT(.*);       // Test under Device

    initial begin
        clk_i = '0;
        forever #(CLK/2) clk_i = ~clk_i;
    end

    initial begin
        $fsdbDumpfile("gcd.fsdb");
        $fsdbDumpon;
        $fsdbDumpvars(0, DUT);
        returnval = $value$plusargs("testname=%s", testname);
        returnval = $value$plusargs("ntb_random_seed=%s", random_seed);
        $display("test name is %0s", testname);
        $display ("rand seed is %0s", random_seed);

        fork
            check_gcd();                // checker start
        join_none
        build_coverage();               // start coverage
        tr = new();                     // transaction stimulus
        as = '{15, 60, 0, 74, 83, 62, 38, 245}; 
        bs = '{9, 84, 5, 0, 1, 5, 38, 245};

        $display("@%0t: Initialize Signlas", $time);
        initialize_signals();           // initialize

        case (testname)
            "random": begin
                for(int i = 0; i < TESTCASES; i++) begin
                    tr.randomize();
                    tr.display($sformatf("@%0t: Transcation%0d:", $time, i+1));
                    tr.send();
                end
            end
            default: begin
                foreach(as[i]) begin
                    $write("@%0t: Transcation: gcd_%0d_%0d", $time, as[i], bs[i]);
                    gcd_a_b(as[i], bs[i]);
                    wait (valid_o) $display("\t@%0t: Output %0d; Expected %0d", $time, gcd_o, gcd_ref(as[i], bs[i]));
                end
            end
        endcase
        @(posedge clk_i) $finish;
    end

endmodule
