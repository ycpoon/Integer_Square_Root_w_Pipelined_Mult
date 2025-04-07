module testbench ();
    logic clock, reset;
    logic [63:0] value;
    logic [31:0] result;
    logic correct, done;
    logic [2:0] state;
    logic [63:0] square;
    logic [64:0] upper_bound;
    logic [4:0] temp;

    ISR I1 (
        .clock(clock),
        .reset(reset),
        .value(value),
        .result(result),
        .done(done)
    );

    // CLOCK_PERIOD is defined on the commandline by the makefile
    always begin
        #(`CLOCK_PERIOD/2.0);
        clock = ~clock;
    end

    // Correct Flag Logic
    assign upper_bound = (result+1)*(result+1);
    assign correct = ~done || ((result*result <= value) && (upper_bound > value));

    always @(posedge clock) begin
        #(`CLOCK_PERIOD*0.2); // a short wait to let signals stabilize
        if (!correct) begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ done:%b value:%b result:%h", done, value, result);
            //$display("@@@ Expected result:%h", cres);
            $finish;
        end
    end

    task wait_until_done;
        forever begin : wait_loop
            @(posedge done);
            @(negedge clock);
            if (done) begin
                disable wait_until_done;
            end
        end
    endtask

    // Monitor list
    always @(done or value) begin
        $display("Time:%4.0f done:%b value:%d result:%d", $time, done, value, result);
    end

    initial begin

        // $monitor("Time:%4.0f done:%b value:%d result:%d",
        //           $time, done, value, result);

        clock = 0;
        reset = 0;

        $display("\nBeginning edge-case testing:\n");

        // Test 1 - Max input value
        @(negedge clock);
        reset = 1;
        value = 64'd18446744073709551615;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 2 - Min input value
        @(negedge clock);
        reset = 1;
        value = 64'd0;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 3 - ISR of 1
        @(negedge clock);
        reset = 1;
        value = 64'd1;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 4 - Perfect ISR (Large Number)
        @(negedge clock);
        reset = 1;
        value = 64'd18446744065119617025;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 5 - Non-Perfect ISR (Large Number)
        @(negedge clock);
        reset = 1;
        value = 64'd18446744065119617024;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 6 - Perfect ISR (Small Number)
        @(negedge clock);
        reset = 1;
        value = 64'd4;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 7 - Perfect ISR (Small Number)
        @(negedge clock);
        reset = 1;
        value = 64'd9;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 8 - Non-Perfect ISR (Small Number)
        @(negedge clock);
        reset = 1;
        value = 64'd2;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 9 - Non-Perfect ISR (Small Number)
        @(negedge clock);
        reset = 1;
        value = 64'd8;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 10 - Random Middle
        @(negedge clock);
        reset = 1;
        value = 64'd4567;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 11 - Random Middle
        @(negedge clock);
        reset = 1;
        value = 64'd343396;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Test 12 - Random Middle
        @(negedge clock);
        reset = 1;
        value = 64'd16384;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Testing Reset 1
        @(negedge clock);
        reset = 1;
        value = 64'd32768;
        @(negedge clock);
        reset = 0;
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        @(negedge clock);
        reset = 1;
        value = 64'd16383;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        // Testing Reset 2
        @(negedge clock);
        reset = 1;
        value = 64'd6589;
        @(negedge clock);
        value = 64'd123;
        @(negedge clock);
        value = 64'd4321;
        @(negedge clock);
        reset = 0;
        wait_until_done();

        $display("\nEdge Case Testing Done...");


        $display("\nBeginning random testing:\n");

        for (int i = 0; i <= 50; i = i+1) begin
            reset = 1;
            value = {$random, $random}; // select a random 64-bit number for ISR
            @(negedge clock);
            reset = 0;
            wait_until_done();
        end

        $display("\nRandom Testing Done...");

        $display("@@@ Passed");

        $finish;
    end

endmodule