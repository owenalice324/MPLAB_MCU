module Program_Rom(Rom_data_out, Rom_addr_in);

//---------
    output [13:0] Rom_data_out;
    input [10:0] Rom_addr_in; 
//---------
    
    reg   [13:0] data;
    wire  [13:0] Rom_data_out;
    
    always @(Rom_addr_in)
        begin
            case (Rom_addr_in)
                11'h0 : data = 14'h3009;
                11'h1 : data = 14'h00A4;
                11'h2 : data = 14'h3005;
                11'h3 : data = 14'h00A3;
                11'h4 : data = 14'h3009;
                11'h5 : data = 14'h00A5;
                11'h6 : data = 14'h3005;
                11'h7 : data = 14'h00A6;
                11'h8 : data = 14'h01A1;
                11'h9 : data = 14'h01A2;
                11'ha : data = 14'h0103;
                11'hb : data = 14'h3001;
                11'hc : data = 14'h07A2;
                11'hd : data = 14'h0BA4;
                11'he : data = 14'h280B;
                11'hf : data = 14'h3009;
                11'h10 : data = 14'h00A4;
                11'h11 : data = 14'h3007;
                11'h12 : data = 14'h07A2;
                11'h13 : data = 14'h0BA3;
                11'h14 : data = 14'h280B;
                11'h15 : data = 14'h3009;
                11'h16 : data = 14'h00A4;
                11'h17 : data = 14'h3001;
                11'h18 : data = 14'h07A2;
                11'h19 : data = 14'h0BA4;
                11'h1a : data = 14'h2817;
                11'h1b : data = 14'h3009;
                11'h1c : data = 14'h00A4;
                11'h1d : data = 14'h3005;
                11'h1e : data = 14'h01A2;
                11'h1f : data = 14'h00A3;
                11'h20 : data = 14'h3001;
                11'h21 : data = 14'h07A1;
                11'h22 : data = 14'h0BA5;
                11'h23 : data = 14'h280B;
                11'h24 : data = 14'h3009;
                11'h25 : data = 14'h00A5;
                11'h26 : data = 14'h3007;
                11'h27 : data = 14'h07A1;
                11'h28 : data = 14'h0BA6;
                11'h29 : data = 14'h2826;
                11'h2a : data = 14'h3009;
                11'h2b : data = 14'h00A5;
                11'h2c : data = 14'h3001;
                11'h2d : data = 14'h07A1;
                11'h2e : data = 14'h0BA5;
                11'h2f : data = 14'h282C;
                11'h30 : data = 14'h2800;
                11'h31 : data = 14'h3400;
                11'h32 : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule
