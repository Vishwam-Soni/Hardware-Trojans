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

//     initial begin
//         // Setup Waveform Dumping for GTKWave
//         $dumpfile("aes_waves.vcd");
//         $dumpvars(0, tb_aes);

//         // ====================================================================
//         // TEST 1: THE STEALTH PHASE (Standard NIST Vector)
//         // ====================================================================
//         $display("--------------------------------------------------");
//         $display(" TEST 1: STEALTH PHASE (Normal Operation) ");
//         $display("--------------------------------------------------");
        
//         // Initialize Signals
//         clk = 0;
//         reset = 1;
//         start = 0;
        
//         // NIST Test Vector
//         plaintext = 128'h3243f6a8885a308d313198a2e0370734;
//         key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;

//         #20 reset = 0;
//         #10 start = 1;
//         #10 start = 0;

//         // Wait for the 'done' signal
//         wait(done);
//         #10;
        
//         if (ciphertext == 128'h3925841d02dc09fbdc118597196a0b32) begin
//             $display("[PASS] Trojan is asleep. Output matches clean NIST cipher.");
//         end 
//         else begin
//             $display("[FAIL] Stealth mode failed! Output corrupted without trigger.");
//             $display("Corrupted pin output: %h", ciphertext);
//         end

//         #50; // Wait before starting the next test


//         // ====================================================================
//         // TEST 2: THE ATTACK PHASE (The Magic Password)
//         // ====================================================================
//         $display("\n--------------------------------------------------");
//         $display(" TEST 2: ATTACK PHASE (Triggering the Trojan) ");
//         $display("--------------------------------------------------");
        
//         // Pulse reset to clear the AES state machine for a new run
//         reset = 1; 
//         #20 reset = 0;

//         // INJECT THE CHEAT CODE!
//         plaintext = 128'h00000000000000000000000000BADB01; 
        
//         #10 start = 1;
//         #10 start = 0;

//         // Wait for encryption to finish
//         wait(done);
//         #10;

//         // Comparison Logic: Prove the trap snapped
//         // We check if the external pin equals (Internal Clean Math XOR Key)
//         if (ciphertext == (uut.clean_ciphertext ^ key)) begin
//             $display("[SUCCESS] Trap snapped! Output is mathematically corrupted.");
//             $display("Internal Clean Math:  %h", uut.clean_ciphertext);
//             $display("Corrupted Pin Output: %h", ciphertext);
//         end 
//         else if (ciphertext == uut.clean_ciphertext) begin
//             $display("[FAIL] Trojan failed to trigger. Output is still clean.");
//         end

//         #100;
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

    aes_top uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        // SCA MODIFICATION: Isolate the core, ignore testbench noise
        $dumpfile("infected_sca_trace.vcd");
        $dumpvars(0, tb_aes.uut);

        // Initialize Signals
        clk = 0;
        reset = 1;
        start = 0;
        
        // INJECT THE CHEAT CODE FOR DETONATION TRACE
        plaintext = 128'h00000000000000000000000000BADB01; 
        key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        #20 reset = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        if (ciphertext == (uut.clean_ciphertext ^ key)) begin
            $display("[SUCCESS] Trap snapped! Output is mathematically corrupted.");
        end 
        else begin
            $display("[FAIL] Trojan failed to trigger.");
        end
        $finish;
    end    
endmodule