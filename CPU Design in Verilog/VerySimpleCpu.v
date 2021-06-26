`timescale 1ns / 1ps

module VerySimpleCpu(clk,rst,data_fromRAM,wrEn,addr_toRAM,data_toRAM);

//GÖRKEM ÖZGÜL 20190702020

parameter SIZE  = 14;

	input clk,rst;
	input wire [31:0] data_fromRAM;
	output reg wrEn;
	output reg [SIZE-1:0] addr_toRAM;
	output reg [31:0] data_toRAM;
	
	reg[3:0] st,stN;
	reg[SIZE-1:0] PC,PCN;
	reg[31:0] R1,R1N;
	reg[31:0] R2,R2N;
	reg[31:0] IW,IWN;
	
	always @(posedge clk) begin
	if(rst)begin
		st<=0;
		PC<=14'b0;
		IW<=32'b0;
		R1<=32'b0;
		R2<=32'b0;
	end else begin
		PC <= PCN;
		IW<=IWN;
		st<=stN;
		R1<=R1N;
		R2<=R2N;
	end
end

	always @* begin
		stN = st;
		PCN=PC;
		IWN=IW;
		R1N=R1;
		R2N=R2;
		wrEn=0;
		addr_toRAM = 0;
		data_toRAM = 0;	
	 case(st)
	 
		0: begin 
			PCN=0;
			IWN=0;
			R1=0;
			R2=0;
			stN=1;
		
		end
		
		1:begin
			addr_toRAM = PC ;
			stN = 2;
		end
		
		2: begin
		
		IWN=data_fromRAM;
		if(data_fromRAM[31:29]==4'b000)begin//ADDi OR ADD
			addr_toRAM= data_fromRAM[27:14]; //Read *R1
			stN=3;
		end
		if(data_fromRAM[31:29]==4'b100) begin //CP OR CPi 
			addr_toRAM= data_fromRAM[13:0];//Read *R2
			stN=3;
		end
		if(data_fromRAM[31:29]==4'b110) begin //BZJ OR BZJi
			addr_toRAM= data_fromRAM[27:14];//Read R1
			stN=3;
		end
		if(data_fromRAM[31:29]==4'b001) begin //NAND OR NANDi
			addr_toRAM= data_fromRAM[27:14];//Read R1
			stN=3;
		end
		if(data_fromRAM[31:29]==4'b010) begin //SRL OR SRLi
			addr_toRAM= data_fromRAM[27:14];//Read R1
			stN=3;
		end
		if(data_fromRAM[31:29]==4'b011)begin//LT OR LTi
			addr_toRAM= data_fromRAM[27:14]; //Read *R1
			stN=3;
		end
		if(data_fromRAM[31:29]==4'b111)begin//MUL OR MULi
			addr_toRAM= data_fromRAM[27:14]; //Read *R1
			stN=3;
		end
		if(data_fromRAM[31:28]==4'b1010)begin//CPI 
			addr_toRAM= data_fromRAM[13:0]; //Read *R2
			stN=3;
		end
		if(data_fromRAM[31:28]==4'b1011)begin//CPIi
			addr_toRAM= data_fromRAM[27:14]; //Read *R1
			stN=3;
		end
		
		
	
	end
	
	
	
		
		3: begin
			if(IW[31:28] ==4'b0001)begin//ADDi
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= data_fromRAM + IW[13:0];
			PCN = PC +1'b1;
			stN=1;
			
			end
			
			if(IW[31:28] ==4'b0000)begin//ADD
			R1N=data_fromRAM;
			addr_toRAM= IW[13:0];//Read *R2
			stN=4;
			
			end
			
			if(IW[31:28] ==4'b1000)begin//CP
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM=data_fromRAM;
			PCN = PC +1'b1;
			stN=1;
			end
			
			if(data_fromRAM[31:28]==4'b1001) begin //CPi
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= IW[13:0];
			PCN = PC +1'b1;
			stN=1;
		end
		
		if(IW[31:28] ==4'b1010)begin//CPI
			addr_toRAM=data_fromRAM;
			stN=4;
			end
			
		if(IW[31:28] ==4'b1011)begin//CPIi
			R1N=data_fromRAM;
			addr_toRAM= IW[13:0];//Read *R2
			stN=4;
			
			end
			
			
			if(IW[31:28]==4'b1100) begin //BZJ
				
				R1N= data_fromRAM;
				addr_toRAM=IW[13:0];//Read *R2
				stN=4;
			
			end
			if(IW[31:28]==4'b1101) begin //BZJi
				
				PCN=data_fromRAM+IW[13:0]; 
				stN=1;
			
			end
			
			if(data_fromRAM[31:28]==4'b0010) begin //NAND 
			R1N=data_fromRAM;
			addr_toRAM=IW[13:0];
			stN=4;
		end
		
		if(data_fromRAM[31:28]==4'b0011) begin //NANDi 
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= ~(data_fromRAM & IW[13:0]);
			PCN = PC +1'b1;
			stN=1;
		end
		
		if(IW[31:28] ==4'b0100)begin//SRL
			R1N=data_fromRAM;
			addr_toRAM= IW[13:0];//Read *R2
			stN=4;
			
		end
		if(IW[31:28] ==4'b0101)begin//SRLi
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			if(IW[13:0]<32)
				data_toRAM= data_fromRAM >> IW[13:0];
			else
				data_toRAM=data_fromRAM << IW[13:0];
			stN=1;
			PCN = PC +1'b1;
		end
		
		if(IW[31:28] ==4'b0110)begin//LT
			R1N=data_fromRAM;
			addr_toRAM= IW[13:0];//Read *R2
			stN=4;
			
			end
			
		if(IW[31:28] ==4'b0111)begin//LTi
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			if(data_fromRAM<IW[13:0])
				data_toRAM=1;
			else
				data_toRAM=0;
			PCN = PC +1'b1;
			stN=1;
			
			end
			
		if(IW[31:28] ==4'b1110)begin//MUL
			R1N=data_fromRAM;
			addr_toRAM= IW[13:0];//Read *R2
			stN=4;
			
			end
		if(IW[31:28] ==4'b1111)begin//MULi
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= data_fromRAM * IW[13:0];
			PCN = PC +1'b1;
			stN=1;
			
			end
		
			
	end
	
	
	
	
	
		4: begin
		
		
		if(IW[31:28]==4'b1100) begin//BZJ
			if(data_fromRAM == 0)
				PCN= R1;
			else
				PCN=PC+ 1'b1;
				
			stN=1;
		
		end
		
		if(IW[31:28] ==4'b0000)begin//ADD
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= R1 + data_fromRAM;
			PCN = PC + 1'b1;
			stN=1;
			
		end
		
		if(IW[31:28] ==4'b0010)begin//NAND
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= ~(R1&data_fromRAM);
			PCN = PC + 1'b1;
			stN=1;
			
		end
		
		if(IW[31:28]==4'b0100) begin//SRL
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			if(data_fromRAM < 32)
				data_toRAM=R1 >> data_fromRAM;
			else
				data_toRAM=R1 << (data_fromRAM-32);
				
			PCN = PC + 1'b1;	
			stN=1;
		
		end
		
		if(IW[31:28] ==4'b0110)begin//LT
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			if(R1<data_fromRAM)
				data_toRAM=1;
			else
				data_toRAM=0;
			PCN = PC + 1'b1;
			stN=1;
			
		end
		
		if(IW[31:28] ==4'b1110)begin//MUL
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= R1 * data_fromRAM;
			PCN = PC + 1'b1;
			stN=1;
			
		end
		if(IW[31:28] ==4'b1010)begin//CPI
			wrEn=1'b1;
			addr_toRAM= IW[27:14];
			data_toRAM= data_fromRAM;
			PCN = PC + 1'b1;
			stN=1;
			
		end
		if(IW[31:28] ==4'b1011)begin//CPIi
			wrEn=1'b1;
			addr_toRAM= R1;
			data_toRAM= data_fromRAM;
			PCN = PC + 1'b1;
			stN=1;
			
		end
		
		
	end
		
		
		endcase
	end



endmodule


























