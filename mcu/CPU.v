module CPU(
  input clk,
  input reset,
  output reg [7:0] port_b_out
);
  reg [13:0] ir_out;
  reg [10:0] pc_out;
  reg [10:0] mar_out;
  wire [13:0] ir_in;
  reg [10:0] pc_in;
  reg [7:0] alu_q;
  
  reg [3:0]op;
  reg load_w;
  reg load_pc;
  reg load_mar;
  reg load_ir;
  reg [2:0] ps,ns;
  
  reg [7:0]databus;
  reg ram_en;
  wire [7:0]ram_out;
  reg sel_alu;
  reg sel_bus;
  reg [2:0]sel_pc;
  reg [7:0]mux1_out;
  
  wire [2:0]sel_bit;
  reg [1:0]sel_RAM_mux;
  reg [7:0]bsf_mux;
  reg [7:0]bcf_mux;
  reg [7:0]RAM_mux;
  wire alu_zero;
  
  reg [7:0]w_q;
  reg load_port_b;
  
  reg pop;
  reg push;
  wire [10:0]stack_q;
  
  
  always @(*)
  begin
	case(sel_pc)
	0:pc_in = pc_out + 1;
	1:pc_in = ir_out[10:0];
	2:pc_in = stack_q;
	endcase
  end
  //mux_pc
  always @(posedge clk)
  begin
    if(reset)
      pc_out <= 0;
    else if(load_pc)
      pc_out <= pc_in;
  end
  //pc
  Stack st(.stack_out(stack_q),.stack_in(pc_out),.push(push),.pop(pop),.reset(reset),.clk(clk));
  //Stack
  always @(posedge clk)
  begin
    if(reset)
      mar_out <= 0;
    else if(load_mar)
      mar_out <= pc_out;
  end  
  //mar
  Program_Rom Rom(.Rom_data_out(ir_in),.Rom_addr_in(mar_out));
  //ROM
  always @(posedge clk)
  begin
    if(reset)
      ir_out <= 0;
    else if(load_ir)
      ir_out <= ir_in;
  end 
  //IR
  single_port_ram_128x8 Ram(
	.data(databus),
	.addr(ir_out[6:0]),
	.en(ram_en),
	.clk(clk),
	.q(ram_out)
	);
	
  assign btfsc_skip_bit = ram_out[ir_out[9:7]]==0;
  assign btfss_skip_bit = ram_out[ir_out[9:7]]==1;
  

  //RAM
  assign sel_bit = ir_out[9:7];
  //sel_bit
  always@(*)
	begin
		case(sel_RAM_mux)
			0:RAM_mux = ram_out;
			1:RAM_mux = bcf_mux;
			2:RAM_mux = bsf_mux;
			default : RAM_mux = 8'bx;
		endcase
	end
  //RAM_mux
  always@(*)
	begin
		case(sel_bit)
			3'b000 : bcf_mux = ram_out & 8'hFE;
			3'b001 : bcf_mux = ram_out & 8'hFD;
			3'b010 : bcf_mux = ram_out & 8'hFB;
			3'b011 : bcf_mux = ram_out & 8'hF7;
			3'b100 : bcf_mux = ram_out & 8'hEF;
			3'b101 : bcf_mux = ram_out & 8'hDF;
			3'b110 : bcf_mux = ram_out & 8'hBF;
			3'b111 : bcf_mux = ram_out & 8'h7F;
		endcase
	end
  //BCF_MUX
    always@(*)
	begin
		case(sel_bit)
			3'b000 : bsf_mux = ram_out | 8'h01;
			3'b001 : bsf_mux = ram_out | 8'h02;
			3'b010 : bsf_mux = ram_out | 8'h04;
			3'b011 : bsf_mux = ram_out | 8'h08;
			3'b100 : bsf_mux = ram_out | 8'h10;
			3'b101 : bsf_mux = ram_out | 8'h20;
			3'b110 : bsf_mux = ram_out | 8'h40;
			3'b111 : bsf_mux = ram_out | 8'h80;
		endcase
	end
  //BCF_MUX
  always @(*)
  begin
	case(sel_alu)
	0: mux1_out = ir_out[7:0];
	1: mux1_out = RAM_mux;
	endcase
  end
  //mux1
  always @(*)
  begin
	case(op)
	0: alu_q = mux1_out + w_q;
	1: alu_q = mux1_out - w_q;
	2: alu_q = mux1_out & w_q;
	3: alu_q = mux1_out | w_q;
	4: alu_q = mux1_out ^ w_q;
	5: alu_q = mux1_out;
	6: alu_q = mux1_out + 1;
	7: alu_q = mux1_out - 1;
	8: alu_q = 0;
	9: alu_q = ~mux1_out;
	10: alu_q = {mux1_out[7],mux1_out[7:1]};
	11: alu_q = {mux1_out[6:0],1'b0};
	12: alu_q = {1'b0,mux1_out[7:1]};
	13: alu_q = {mux1_out[6:0],mux1_out[7]};
	14: alu_q = {mux1_out[0],mux1_out[7:1]};
	15: alu_q = {mux1_out[3:0],mux1_out[7:4]};
	default: alu_q = mux1_out[7:0] + w_q;
	endcase
  end
  
  assign alu_zero = (alu_q == 0)? 1'b1: 1'b0;
  
  //alu
  always @(*)
  begin
	case(sel_bus)
	0: databus = alu_q;
	1: databus = w_q;
	endcase
  end
  //bus
  always @(posedge clk)
	if(reset) port_b_out <= 0;
	else if(load_port_b) port_b_out <= databus;
	
  assign addr_port_b = (ir_out[6:0] == 7'h0d);
  //port_b
  always @(posedge clk)
  begin
	if(load_w)
		w_q <= alu_q;
  end
  //w
  assign MOVLW = (ir_out[13:8] == 6'b11_0000);
  assign ADDLW = (ir_out[13:8] == 6'b11_1110);
  assign SUBLW = (ir_out[13:8] == 6'b11_1100);
  assign ANDLW = (ir_out[13:8] == 6'b11_1001);
  assign IORLW = (ir_out[13:8] == 6'b11_1000);
  assign XORLW = (ir_out[13:8] == 6'b11_1010);
  
  assign ADDWF = (ir_out[13:8] == 6'b00_0111);
  assign ANDWF = (ir_out[13:8] == 6'b00_0101);
  assign CLRF = (ir_out[13:8] == 6'b00_0001);
  assign CLRW = (ir_out[13:2] == 12'b00_0001000000);
  assign COMF = (ir_out[13:8] == 6'b00_1001);
  assign DECF = (ir_out[13:8] == 6'b00_0011);
  assign GOTO = (ir_out[13:11] == 3'b10_1);
  
  assign INCF = (ir_out[13:8] == 6'b00_1010);
  assign IORWF = (ir_out[13:8] == 6'b00_0100);
  assign MOVF = (ir_out[13:8] == 6'b00_1000);
  assign MOVWF = (ir_out[13:7] == 7'b00_00001);
  assign SUBWF = (ir_out[13:8] == 6'b00_0010);
  assign XORWF = (ir_out[13:8] == 6'b00_0110);
  
  assign DECFSZ = (ir_out[13:8] == 6'b00_1011);
  assign INCFSZ = (ir_out[13:8] == 6'b00_1111);
  
  assign BCF = (ir_out[13:10] == 4'b01_00);
  assign BSF = (ir_out[13:10] == 4'b01_01);
  assign BTFSC = (ir_out[13:10] == 4'b01_10);
  assign BTFSS = (ir_out[13:10] == 4'b01_11);
  assign btfsc_btfss_skip_bit = (BTFSC&btfsc_skip_bit)|(BTFSS&btfss_skip_bit);
  
  assign ASRF = (ir_out[13:8] == 6'b11_0111);
  assign LSLF = (ir_out[13:8] == 6'b11_0101);
  assign LSRF = (ir_out[13:8] == 6'b11_0110);
  assign RLF = (ir_out[13:8] == 6'b00_1101);
  assign RRF = (ir_out[13:8] == 6'b00_1100);
  assign SWAPF = (ir_out[13:8] == 6'b00_1110);
  
  assign CALL = (ir_out[13:11] == 3'b10_0);
  assign RETURN = (ir_out[13:0] == 14'b00_000000001000);
  
  always @(posedge clk)
  begin
    if(reset)
      ps <= 0;
    else
      ps <= ns;
  end 
  always@(*)
  begin
    load_pc=0;
    load_ir=0;
    load_mar=0;
	load_w=0;
	ram_en=0;
	sel_RAM_mux=0;
	load_port_b=0;
	sel_pc=0;
	pop=0;
	push=0;
	
	ns=0;
    case(ps)  
      0: ns = 1;
      1:
      begin
        load_mar=1;
        ns = 2;
      end
      2:
      begin
		sel_pc=0;
        load_pc=1;
        ns = 3;
      end
      3:
      begin
        load_ir=1;
        ns = 4;
      end  
	  4:
	  begin
		if (MOVLW|ADDLW|SUBLW|ANDLW|IORLW|XORLW)
			begin
				sel_alu=0;
				load_w = 1;
				if (MOVLW)
					op=5;
				else if (ADDLW)
					op=0;
				else if (IORLW)
					op=3;
				else if (SUBLW)
					op=1;
				else if (ANDLW)
					op=2;
				else if (XORLW)
					op=4;
			end
		ns = 1;	
		if (GOTO)
			begin
				sel_pc=1;
				load_pc=1;
			end
		if (ADDWF)
			begin
			op=0;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end	
		if (ANDWF)
			begin
			op=2;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (CLRF)
			begin
			op=8;
			ram_en=1;
			sel_bus=0;
			end	
		if (CLRW)
			begin
			op=8;
			load_w=1;
			end
		if (COMF)
			begin
			op=9;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (DECF)
			begin
			op=7;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (INCF)
			begin
			op=6;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (IORWF)
			begin
			op=3;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (MOVF)
			begin
			op=5;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (MOVWF)
			begin
			ram_en = 1;
			sel_bus = 1;
			if (addr_port_b == 1)
				load_port_b = 1;
			else
				ram_en = 1;
			end
		if (SUBWF)
			begin
			op=1;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (XORWF)
			begin
			op=4;
			sel_alu=1;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (DECFSZ)
			begin
			if (ir_out[7]==0)
				begin
				sel_alu=1;
				op=7;
				load_w=1;
				if (alu_zero==1)
					begin
					load_pc=1;
					sel_pc=0;
					end
				end
			else
				begin
				sel_alu=1;
				op=7;
				ram_en=1;
				sel_bus=0;
				if (alu_zero==1)
					begin
					load_pc=1;
					sel_pc=0;
					end
				end
			end
		if (INCFSZ)
			begin
			if (ir_out[7]==0)
				begin
				sel_alu=1;
				op=6;
				load_w=1;
				if (alu_zero==1)
					begin
					load_pc=1;
					sel_pc=0;
					end
				end
			else
				begin
				sel_alu=1;
				op=6;
				ram_en=1;
				sel_bus=0;
				if (alu_zero==1)
					begin
					load_pc=1;
					sel_pc=0;
					end
				end
			end
		if (BCF)
			begin
			sel_alu=1;
			sel_RAM_mux=1;
			op=5;
			sel_bus=0;
			ram_en=1;
			end
		if (BSF)
			begin
			sel_alu=1;
			sel_RAM_mux=2;
			op=5;
			sel_bus=0;
			ram_en=1;
			end
		if (BTFSC|BTFSS)
			begin
			if (btfsc_btfss_skip_bit ==1)
			begin
			load_pc=1;
			sel_pc=0;
			end
			end
		if (ASRF)
			begin
			sel_alu=1;
			sel_RAM_mux=0;
			op=10;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end
			end
		if (LSLF)
			begin
			sel_alu=1;
			sel_RAM_mux=0;
			op=11;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end	
			end
		if (LSRF)
			begin
			sel_alu=1;
			sel_RAM_mux=0;
			op=12;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end	
			end
		if (RLF)
			begin
			sel_alu=1;
			sel_RAM_mux=0;
			op=13;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end	
			end
		if (RRF)
			begin
			sel_alu=1;
			sel_RAM_mux=0;
			op=14;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end	
			end
		if (SWAPF)
			begin
			sel_alu=1;
			sel_RAM_mux=0;
			op=15;
			if (ir_out[7]==0)
				load_w=1;
			else
				begin
				ram_en=1;
				sel_bus=0;
				end	
			end
		if (CALL)
			begin
			sel_pc=2'b01;
			load_pc=1;
			push=1;
			end
		if (RETURN)
			begin
			sel_pc=2'b10;
			load_pc=1;
			pop=1;
			end
	  end
	endcase
  end
  //controller
endmodule
  
  
  
  
  
  
  
  
  