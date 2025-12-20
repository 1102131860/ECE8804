/******************************************************************************
 Module Name : gcd
 Description :
	 Great Common Division
	 ! gcd( 6, 2) = 2
	 ! gcd( 9,12) = 3
	 ! gcd(18,12) = 6
*******************************************************************************/

module gcd 
    #(
        parameter    WIDTH = 8
    )
    (
	    input  logic            clk_i, rst_i,   // global
	    input  logic            valid_i,        // start
	    input  logic [WIDTH-1:0]a_i, b_i,       // operands
	    output logic [WIDTH-1:0]gcd_o,          // gcd output
	    output logic            valid_o         // valid_o
    );
    
    import gcd_pkg::*;
    state_t state_r, next_state_r;
    logic [WIDTH-1:0] a_r, b_r;
    logic [$clog2(WIDTH)-1:0] shift_count_r;

    always_ff @(posedge clk_i or posedge rst_i)
        if (rst_i) state_r <= RESET;
        else       state_r <= next_state_r;

    always_comb begin
        next_state_r = state_r;
        unique case (state_r)
            RESET: next_state_r   = valid_i                                ? LOAD : RESET;
            LOAD:  next_state_r   = (a_r == b_r || a_r == '0 || b_r == '0) ? DONE : RUN;
            RUN:   next_state_r   = (a_r == b_r)                           ? DONE : RUN;
            DONE:  next_state_r   = valid_i                                ? LOAD : DONE;
            default: next_state_r = state_r;
        endcase
    end

    always_ff @(posedge clk_i or posedge rst_i)
        if (rst_i)
            {gcd_o, valid_o, a_r, b_r, shift_count_r} <= '0;
        else begin
            {gcd_o, valid_o} <= '0;             // default output values
            unique case (next_state_r)
                RESET: ;                        // no state has a RESET as its next state
                LOAD: begin
                    a_r <= a_i;
                    b_r <= b_i;
                    shift_count_r <= '0;
                end
                RUN: begin
                    unique case ({a_r[0], b_r[0]})
                        2'b00: begin            // both even
                            a_r <= a_r >> 1;
                            b_r <= b_r >> 1;
                            shift_count_r <= shift_count_r + 1'b1;
                        end
                        2'b01: a_r <= a_r >> 1; // a is even and b is odd
                        2'b10: b_r <= b_r >> 1; // a is odd and b is even
                        2'b11: begin            // both odd
                            if (a_r > b_r) a_r <= (a_r - b_r) >> 1;
                            else           b_r <= (b_r - a_r) >> 1;
                        end
                        default: ;              // it shouldn't be
                    endcase
                end
                DONE: begin
                    gcd_o   <= (a_r == '0 && b_r != '0) ? b_r : a_r << shift_count_r;
                    valid_o <= '1;
                end
                default: {gcd_o, valid_o} <= 'x;
            endcase
        end

endmodule
