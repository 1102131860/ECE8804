task initialize_signals();
    #OFFSET rst_i   = 1'b1;
    // clk_i = 1'b0;                // the clk shouldn't be clear
    valid_i = 1'b0;
    a_i     = 1'b0;
    b_i     = 1'b0;
endtask

task reset_signals();
    repeat (10) @(posedge clk_i);
    initialize_signals();
endtask

task gcd_a_b(input logic [WIDTH-1:0] a, b);
    @(posedge clk_i);
    #OFFSET rst_i<=1'b0;
    @(posedge clk_i);
    #OFFSET valid_i<=1'b1;
    a_i<=a;
    b_i<=b;
    @(posedge clk_i);
    #OFFSET valid_i<=1'b0;
    a_i<=0;
    b_i<=0;
    @(posedge valid_o);
    reset_signals();
endtask

/************************************/
/***Helper functions for Assertion***/
/************************************/
// This method is used to compare the DUT's output
function automatic logic [WIDTH-1:0] gcd_ref(input logic [WIDTH-1:0] a, b);
    logic [WIDTH-1:0] t;
    if (a == '0) return b;
    if (b == '0) return a;

    while (b != 0) begin
        t = a % b;
        a = b;
        b = t;
    end
    return a;
endfunction

// output within n^2 + 4 cycles where n=log_2(a_i) + log_2(b_i)
function automatic int unsigned time_bound(input logic [WIDTH-1:0] a, b);
    return (($clog2(a) + $clog2(b)) << 1) + 4;
endfunction

/************************************/
/*** Assertion Based Verification ***/
/************************************/
task check_gcd();
    int unsigned cyc, bound;
    logic [WIDTH-1:0] a, b, exp;

    forever begin
        // sample when valid_i (block if not valid_i)
        @(posedge clk_i iff valid_i) begin
            a = a_i;
            b = b_i;
            cyc = '0;
            bound = time_bound(a, b);
            exp = gcd_ref(a, b); 
        end

        // calcualte how many cycles pass
        @(posedge clk_i);
        while (!valid_o) begin
            cyc++;
            @(posedge clk_i);
        end

        // assert
        check_bound: assert (cyc <= bound)
        else $error("@%0t: gcd_%0d_%0d: latency %0d exceeds bound %0d", $time, a, b, cyc, bound);

        check_correct: assert (gcd_o == exp) 
        else $error("@%t: gcd_%0d_%0d: output (%0d) dismatches expect (%0d)", $time, a, b, gcd_o, exp);
    end
endtask

/***************************/
/*** Functional Coverage ***/
/***************************/
// define a covergroup for input signals
covergroup cg_gcd_in @(posedge clk_i);
    cp_reset    : coverpoint rst_i;
    cp_valid    : coverpoint valid_i;
    cp_a        : coverpoint a_i;
    cp_b        : coverpoint b_i;
    cp_a_b      : cross cp_a, cp_b;
endgroup

import gcd_pkg::*;
// define a covergroup for gcd states
covergroup cg_gcd_internal @(posedge clk_i);
    cp_state: coverpoint DUT.state_r {
        bins states[] = {RESET, LOAD, RUN, DONE};
    }
endgroup

// define a covergroup for output signals
covergroup cg_gcd_out @(posedge clk_i);
    cp_gcd_o    : coverpoint gcd_o;
    cp_valid_o  : coverpoint valid_o;
endgroup

task build_coverage();
    // instantiate covergroups
    cg_gcd_in cg_gcd_in_inst = new();
    cg_gcd_internal cg_gcd_internal_inst = new();
    cg_gcd_out cg_gcd_out_inst = new();
endtask

/***************************/
/*** Random Stimulus     ***/
/***************************/
class Transcation;
    rand bit [WIDTH-1:0] a;
    rand bit [WIDTH-1:0] b;

    function void display(input string prefix="");
        $display("%s gcd_%0d_%0d", prefix, a, b);        
    endfunction

    task send();
        gcd_a_b(a, b);
    endtask
endclass
