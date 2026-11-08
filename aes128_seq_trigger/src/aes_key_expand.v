module aes_key_expand (
    input  [127:0] old_key,
    input  [3:0]   round,
    output [127:0] new_key
);
    wire [31:0] w0, w1, w2, w3, sub_word, rot_word;
    reg  [7:0]  rcon;

    assign {w0, w1, w2, w3} = old_key;
    assign rot_word = {w3[23:0], w3[31:24]};

    aes_sbox sb0 (.sbox_in(rot_word[31:24]), .sbox_out(sub_word[31:24]));
    aes_sbox sb1 (.sbox_in(rot_word[23:16]), .sbox_out(sub_word[23:16]));
    aes_sbox sb2 (.sbox_in(rot_word[15:8]),  .sbox_out(sub_word[15:8]));
    aes_sbox sb3 (.sbox_in(rot_word[7:0]),   .sbox_out(sub_word[7:0]));

    always @(*) begin
        case (round)
            4'h1: rcon = 8'h01; 4'h2: rcon = 8'h02; 4'h3: rcon = 8'h04;
            4'h4: rcon = 8'h08; 4'h5: rcon = 8'h10; 4'h6: rcon = 8'h20;
            4'h7: rcon = 8'h40; 4'h8: rcon = 8'h80; 4'h9: rcon = 8'h1b;
            4'hA: rcon = 8'h36; default: rcon = 8'h00;
        endcase
    end

    wire [31:0] g_out = sub_word ^ {rcon, 24'b0};
    wire [31:0] nw0 = w0 ^ g_out;
    wire [31:0] nw1 = w1 ^ nw0;
    wire [31:0] nw2 = w2 ^ nw1;
    wire [31:0] nw3 = w3 ^ nw2;

    assign new_key = {nw0, nw1, nw2, nw3};
endmodule