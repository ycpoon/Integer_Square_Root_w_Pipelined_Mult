`include "mult.sv"

module ISR (
    input               reset,
    input        [63:0] value,
    input               clock,
    output logic [31:0] result,
    output logic        done
);


    // State parameters
    parameter START = 3'b000;
    parameter LOOP = 3'b001;
    parameter BEGIN_MULT = 3'b010;
    parameter MULT = 3'b011;
    parameter CHECK = 3'b100;
    parameter DONE = 3'b101;

    logic [63:0] i_value;                   // intermediary value
    logic [2:0] state, next_state;          // state registers
    logic [4:0] cnt;                        // loop iteration counter 
    logic rst_cnt, dc_cnt;                  // reset counter, decrement counter
    logic chg_to_zero, chg_to_one;          // result[i] -> change to zero, change to one
    logic mult_start, mult_done;            // multiplication start, multiplication done
    logic [63:0] sqr;                       // square of result

    // Instantiation of multiplier module
    mult m1 (
        .clock(clock),
        .reset(reset),
        .mcand({32'b0, result}),
        .mplier({32'b0, result}),
        .start(mult_start),
        .product(sqr),
        .done(mult_done)
    );

    // State transition logic
    always_comb begin
        case(state)
            START: begin
                next_state = LOOP;
            end

            LOOP: begin
                next_state = BEGIN_MULT;
            end

            BEGIN_MULT: begin
                next_state = MULT;
            end

            MULT: begin
                if(mult_done) next_state = CHECK;
                else next_state = MULT;
            end

            CHECK: begin
                if(cnt == 5'b00000) next_state = DONE;
                else next_state = LOOP;
            end

            DONE: begin
                next_state = DONE;
            end

            default: begin
                next_state = START;
            end

        endcase
    end

    // Datapath controls
    assign rst_cnt = (state == START);
    assign dc_cnt = (state == CHECK);
    assign chg_to_one = (state == LOOP);
    assign chg_to_zero = (state == CHECK) && (sqr > i_value);
    assign mult_start = (state == BEGIN_MULT);

    // State update, register updates
    always_ff @(posedge clock) begin
        if(reset) begin
            state <= START;
            cnt <= 5'b11111;
            i_value <= value;
            result <= 0;
        end else begin
            state <= next_state;
            cnt <= rst_cnt ? 5'b11111 : dc_cnt ? cnt - 1'b1 : cnt;
            result[cnt] <= (chg_to_one) ? 1'b1 :
                           (chg_to_zero) ? 1'b0 : result[cnt]; 
        end
    end

    // Output wires
    assign done = (state == DONE);
        

endmodule