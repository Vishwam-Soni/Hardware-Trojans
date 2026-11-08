// `timescale 1ns/1ps

// module tb_aes();
//     reg clk;
//     reg reset;
//     reg start;
//     reg [127:0] plaintext;
//     reg [127:0] key;
//     wire [127:0] ciphertext;
//     wire done;

//     // Instantiate the Top-Level AES module
//     aes_top uut (
//         .clk(clk),
//         .reset(reset),
//         .start(start),
//         .plaintext(plaintext),
//         .key(key),
//         .ciphertext(ciphertext),
//         .done(done)
//     );

//     // Clock generation: 100MHz (10ns period)
//     always #5 clk = ~clk;

//     // Loop variable
//     integer i;

//     initial begin
//         // Setup Waveform Dumping for GTKWave
//         $dumpfile("aes_waves.vcd");
//         $dumpvars(0, tb_aes);

//         // Initialize Signals
//         clk = 0;
//         reset = 1;
//         start = 0;
        
//         // NIST Test Vector
//         // Plaintext: 3243f6a8885a308d313198a2e0370734
//         // Key:       2b7e151628aed2a6abf7158809cf4f3c
//         plaintext = 128'h3243f6a8885a308d313198a2e0370734;
//         key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;

//         #20 reset = 0;
        
//         $display("==================================================");
//         $display(" INITIATING RARE TRIGGER (TIMEBOMB) TEST ");
//         $display("==================================================");

//         // Run 6 back-to-back encryptions
//         for (i = 1; i <= 6; i = i + 1) begin
//             $display("\n--- Starting Encryption Run %0d ---", i);
            
//             #10 start = 1;
//             #10 start = 0;

//             // Wait for the 'done' signal
//             wait(done);
            
//             #10; // Wait a cycle for the final ciphertext to stabilize on the pins
            
//             // Auto-Checking Logic for the Timebomb
//             if (ciphertext == 128'h3925841d02dc09fbdc118597196a0b32) begin
//                 $display("[PASS] Run %0d: Trojan is asleep. Output is clean.", i);
//             end 
//             else if (ciphertext == (128'h3925841d02dc09fbdc118597196a0b32 ^ key)) begin
//                 $display("[SUCCESS - ATTACK] Run %0d: TIMEBOMB DETONATED! Key leaked.", i);
//             end 
//             else begin
//                 $display("[FAIL] Run %0d: Unknown data corruption.", i);
//                 $display("Got: %h", ciphertext);
//             end
            
//             #50; // Give some buffer time before firing the next encryption
//         end

//         $display("\n==================================================");
//         $display(" TEST COMPLETE ");
//         $display("==================================================");
//         $finish;
//     end    
// endmodule
`timescale 1ns/1ps

module tb_aes();
    reg clk;
    reg reset;
    reg start;
    reg [127:0] plaintext;
    reg [127:0] key;
    wire [127:0] ciphertext;
    wire done;

    // Instantiate the Top-Level AES module
    aes_top uut (
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

    // Loop variable
    integer i;

    initial begin
        // SCA MODIFICATION: Isolate the core, ignore testbench noise
        $dumpfile("infected_sca_trace.vcd");
        $dumpvars(0, tb_aes.uut);

        // Initialize Signals
        clk = 0;
        reset = 1;
        start = 0;
        
        // NIST Test Vector
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        #20 reset = 0;
        
        $display("==================================================");
        $display(" INITIATING RARE TRIGGER (TIMEBOMB) TEST ");
        $display("==================================================");

        // Run 6 back-to-back encryptions
        for (i = 1; i <= 6; i = i + 1) begin
            $display("\n--- Starting Encryption Run %0d ---", i);
            
            #10 start = 1;
            #10 start = 0;

            // Wait for the 'done' signal
            wait(done);
            
            #10; // Wait a cycle for the final ciphertext to stabilize on the pins
            
            // Auto-Checking Logic for the Timebomb
            if (ciphertext == 128'h3925841d02dc09fbdc118597196a0b32) begin
                $display("[PASS] Run %0d: Trojan is asleep. Output is clean.", i);
            end 
            else if (ciphertext == (128'h3925841d02dc09fbdc118597196a0b32 ^ key)) begin
                $display("[SUCCESS - ATTACK] Run %0d: TIMEBOMB DETONATED! Key leaked.", i);
            end 
            else begin
                $display("[FAIL] Run %0d: Unknown data corruption.", i);
            end
            
            #50; // Give some buffer time before firing the next encryption
        end

        $display("\n==================================================");
        $display(" TEST COMPLETE ");
        $display("==================================================");
        $finish;
    end    
endmodule