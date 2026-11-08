// `timescale 1ns/1ps

// module tb_aes();
//     reg clk;
//     reg reset;
//     reg start;
//     reg [127:0] plaintext;
//     reg [127:0] key;
//     wire [127:0] ciphertext;
//     wire done;

//     // The Expected "Golden" Clean Ciphertext for dynamic auto-checking
//     reg [127:0] expected_golden_cipher;

//     // Instantiate the Top-Level AES module (Phase 4: FSM Trojan)
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

//         // Initialize Signals
//         clk = 0;
//         reset = 1;
//         start = 0;
        
//         // NIST Standard Test Key
//         key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
//         plaintext = 128'h0;

//         #20 reset = 0;
        
//         $display("\n=======================================================");
//         $display(" NORMAL ONE");
//         $display("=======================================================\n");

//         // --- Cycle 1: Standard NIST Vector ---
//         plaintext = 128'h3243f6a8885a308d313198a2e0370734;
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext; // Grab the clean state
//         $display("Cycle 1 | NIST Data Encrypt");
//         if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Output matches Golden (3925841d...). Trojan Asleep.");

//         // --- Cycle 2: Entering Part 1 of the cheat code (1111...) ---
//         plaintext = 128'h11111111_11111111_11111111_11111111; 
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext;
//         $display("Cycle 2 | Entered: 1111... (FSM Stage 1)");
//         if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Output Clean. Trojan Asleep.");

//         // --- Cycle 3: Breaking the sequence! (Resetting FSM) ---
//         plaintext = 128'h99999999_99999999_99999999_99999999; 
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext;
//         $display("Cycle 3 | Entered: 9999... (Sequence Broken!)");
//         if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Output Clean. FSM successfully reset back to IDLE.\n");


//         $display("\n=======================================================");
//         $display(" INITIATING ATTACK");
//         $display("=======================================================\n");

//         // --- Cycle 4: Cheat Code Part 1 ---
//         plaintext = 128'h11111111_11111111_11111111_11111111; 
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext;
//         $display("Cycle 4 | Entered: 1111... (FSM Stage 1)");
//         if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Matches Golden. Still Stealthy.");

//         // --- Cycle 5: Cheat Code Part 2 ---
//         plaintext = 128'h22222222_22222222_22222222_22222222; 
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext;
//         $display("Cycle 5 | Entered: 2222... (FSM Stage 2)");
//         if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Matches Golden. Still Stealthy.");

//         // --- Cycle 6: Cheat Code Part 3 (ARMING) ---
//         plaintext = 128'h33333333_33333333_33333333_33333333; 
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext;
//         $display("Cycle 6 | Entered: 3333... (FSM Stage 3)");
//         if (ciphertext != expected_golden_cipher) 
//              $display(" -> [!!!] FSM ARMED! Payload Detonated!");
//         else $display(" -> FSM Armed for NEXT payload.");

//         $display("\n--- TROJAN IS NOW LOCKED AND LOADED ---\n");

//         // --- Cycle 7: Standard NIST Vector (Should be destroyed) ---
//         plaintext = 128'h3243f6a8885a308d313198a2e0370734; // Sending normal data again
//         #10 start = 1; #10 start = 0; wait(done); #10;
//         expected_golden_cipher = uut.clean_ciphertext;
//         $display("Cycle 7 | NIST Data Encrypt");
        
//         // Phase 4 Payload uses bitwise NOT (~clean_ciphertext) instead of XOR key
//         if (ciphertext == ~expected_golden_cipher) begin
//             $display(" -> [SUCCESS - ATTACK] DATA COMPLETELY DESTROYED (Bitwise Inverted)!");
//             $display("    Expected Golden : %h", expected_golden_cipher);
//             $display("    Actual Trojan   : %h", ciphertext);
//         end else begin
//             $display(" -> [FAIL] Unknown data behavior.");
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

    reg [127:0] expected_golden_cipher;

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

        clk = 0;
        reset = 1;
        start = 0;
        
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        plaintext = 128'h0;

        #20 reset = 0;
        
        $display("\n=======================================================");
        $display(" NORMAL ONE");
        $display("=======================================================\n");

        // --- Cycle 1: Standard NIST Vector ---
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext; 
        $display("Cycle 1 | NIST Data Encrypt");
        if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Output matches Golden. Trojan Asleep.");

        // --- Cycle 2: Entering Part 1 of the cheat code (1111...) ---
        plaintext = 128'h11111111_11111111_11111111_11111111; 
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext;
        $display("Cycle 2 | Entered: 1111... (FSM Stage 1)");
        if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Output Clean. Trojan Asleep.");

        // --- Cycle 3: Breaking the sequence! (Resetting FSM) ---
        plaintext = 128'h99999999_99999999_99999999_99999999; 
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext;
        $display("Cycle 3 | Entered: 9999... (Sequence Broken!)");
        if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Output Clean. FSM successfully reset back to IDLE.\n");

        $display("\n=======================================================");
        $display(" INITIATING ATTACK");
        $display("=======================================================\n");

        // --- Cycle 4: Cheat Code Part 1 ---
        plaintext = 128'h11111111_11111111_11111111_11111111; 
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext;
        $display("Cycle 4 | Entered: 1111... (FSM Stage 1)");
        if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Matches Golden. Still Stealthy.");

        // --- Cycle 5: Cheat Code Part 2 ---
        plaintext = 128'h22222222_22222222_22222222_22222222; 
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext;
        $display("Cycle 5 | Entered: 2222... (FSM Stage 2)");
        if (ciphertext == expected_golden_cipher) $display(" -> [PASS] Matches Golden. Still Stealthy.");

        // --- Cycle 6: Cheat Code Part 3 (ARMING) ---
        plaintext = 128'h33333333_33333333_33333333_33333333; 
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext;
        $display("Cycle 6 | Entered: 3333... (FSM Stage 3)");
        if (ciphertext != expected_golden_cipher) 
             $display(" -> [!!!] FSM ARMED! Payload Detonated!");
        else $display(" -> FSM Armed for NEXT payload.");

        $display("\n--- TROJAN IS NOW LOCKED AND LOADED ---\n");

        // --- Cycle 7: Standard NIST Vector (Should be destroyed) ---
        plaintext = 128'h3243f6a8885a308d313198a2e0370734; 
        #10 start = 1; #10 start = 0; wait(done); #10;
        expected_golden_cipher = uut.clean_ciphertext;
        $display("Cycle 7 | NIST Data Encrypt");
        
        if (ciphertext == ~expected_golden_cipher) begin
            $display(" -> [SUCCESS - ATTACK] DATA COMPLETELY DESTROYED (Bitwise Inverted)!");
        end else begin
            $display(" -> [FAIL] Unknown data behavior.");
        end

        $display("\n==================================================");
        $display(" TEST COMPLETE ");
        $display("==================================================");
        $finish;
    end    
endmodule