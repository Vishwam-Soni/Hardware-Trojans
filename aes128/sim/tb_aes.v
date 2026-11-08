`timescale 1ns/1ps

module tb_aes();
    reg clk;
    reg reset;
    reg start;
    reg [127:0] plaintext;
    reg [127:0] key;
    wire [127:0] ciphertext;
    wire done;

    // Instantiate the Top-Level Golden AES module
    aes_top uut_golden (
        .clk(clk),
        .reset(reset),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .done(done)
    );

    // Clock generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // ---------------------------------------------------------
        // SCA MODIFICATION: Isolate the Golden Chip Power Trace
        // ---------------------------------------------------------
        $dumpfile("golden_sca_trace.vcd");
        
        // Dump ONLY the internal wires of the Golden instance to prevent 
        // testbench logic from polluting the toggle count.
        $dumpvars(0, tb_aes.uut_golden);
        // ---------------------------------------------------------

        // Initialize Signals
        clk = 0;
        reset = 1;
        start = 0;
        
        // NIST Test Vector
        // Plaintext: 3243f6a8885a308d313198a2e0370734
        // Key:       2b7e151628aed2a6abf7158809cf4f3c
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        #20 reset = 0;
        #10 start = 1;
        #10 start = 0;

        // Wait for the 'done' signal
        wait(done);
        
        #10;
        $display("Ciphertext: %h", ciphertext);
        if (ciphertext == 128'h3925841d02dc09fbdc118597196a0b32) begin
            $display("TEST PASSED!");
        end 
        else begin
            $display("TEST FAILED!");
            $display("Expected: 3925841d02dc09fbdc118597196a0b32");
            $display("Got:      %h", ciphertext); 
        end
        $finish;
    end    
endmodule