module aes_round (
    input  [127:0] state_in,
    input  [127:0] round_key,
    output [127:0] state_out
);
    wire [127:0] sub_bytes_out;
    wire [127:0] shift_rows_out;
    wire [127:0] mix_cols_out;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sbox_gen
            aes_sbox sb (.sbox_in(state_in[i*8+7:i*8]), .sbox_out(sub_bytes_out[i*8+7:i*8]));
        end
    endgenerate

    // ShiftRows (Synchronized Big-Endian)
    assign shift_rows_out[127:120] = sub_bytes_out[127:120];
    assign shift_rows_out[95:88]   = sub_bytes_out[95:88];
    assign shift_rows_out[63:56]   = sub_bytes_out[63:56];
    assign shift_rows_out[31:24]   = sub_bytes_out[31:24];

    assign shift_rows_out[119:112] = sub_bytes_out[87:80];
    assign shift_rows_out[87:80]   = sub_bytes_out[55:48];
    assign shift_rows_out[55:48]   = sub_bytes_out[23:16];
    assign shift_rows_out[23:16]   = sub_bytes_out[119:112];

    assign shift_rows_out[111:104] = sub_bytes_out[47:40];
    assign shift_rows_out[79:72]   = sub_bytes_out[15:8];
    assign shift_rows_out[47:40]   = sub_bytes_out[111:104];
    assign shift_rows_out[15:8]    = sub_bytes_out[79:72];

    assign shift_rows_out[103:96]  = sub_bytes_out[7:0];
    assign shift_rows_out[71:64]   = sub_bytes_out[103:96];
    assign shift_rows_out[39:32]   = sub_bytes_out[71:64];
    assign shift_rows_out[7:0]     = sub_bytes_out[39:32];

    // MixColumns (Aligned to Big-Endian columns)
    aes_mixcolumns mc0 (.col_in(shift_rows_out[127:96]), .col_out(mix_cols_out[127:96]));
    aes_mixcolumns mc1 (.col_in(shift_rows_out[95:64]),  .col_out(mix_cols_out[95:64]));
    aes_mixcolumns mc2 (.col_in(shift_rows_out[63:32]),  .col_out(mix_cols_out[63:32]));
    aes_mixcolumns mc3 (.col_in(shift_rows_out[31:0]),   .col_out(mix_cols_out[31:0]));

    assign state_out = mix_cols_out ^ round_key;
endmodule