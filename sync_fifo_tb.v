`include "sync_fifo.v"
module tb;
	parameter WIDTH=8;
	parameter FIFO_SIZE=16;
	parameter PTR_WIDTH=$clog2(FIFO_SIZE);
	reg clk,rst,wr_en,rd_en;
	reg [WIDTH-1:0] wdata;
	wire [WIDTH-1:0] rdata;
	wire full,overflow,empty,underflow;
	integer i,j,k,l,wr_delay,rd_delay;
	reg [20*8-1:0] test_name;
	sync_fifo #(.WIDTH(WIDTH),.FIFO_SIZE(FIFO_SIZE),.PTR_WIDTH(PTR_WIDTH)) dut(clk,rst,wr_en,rd_en,wdata,rdata,full,overflow,empty,underflow);
	always #5 clk=~clk;
	initial begin
		$value$plusargs("test_name=%0s",test_name);
		clk=0;
		rst=1;
		wr_en=0;
		rd_en=0;
		wdata=0;
		repeat(2)@(posedge clk);
		rst=0;
		case(test_name)
			"FULL":begin
				   	write(FIFO_SIZE);
				   end
			"EMPTY":begin
						write(FIFO_SIZE);
						read(FIFO_SIZE);
					end
			"OVERFLOW":begin
					   	write(FIFO_SIZE+1);
						read(FIFO_SIZE);
					   end
			"UNDERFLOW":begin
					   	write(FIFO_SIZE);
						read(FIFO_SIZE+1);
					   end
			"concurrent":begin
							fork
						 		begin
									for(k=0;k<FIFO_SIZE;k=k+1)begin
										write(1);
										wr_delay=$urandom_range(5,10);
										#(wr_delay);
									end
								end
						 		begin
									wait(empty==0);
									for(l=0;l<FIFO_SIZE;l=l+1)begin
										read(1);
										rd_delay=$urandom_range(5,10);
										#(rd_delay);
									end
								end
							join
						 end
		endcase

		//write(FIFO_SIZE);
		//read(FIFO_SIZE);
		#100;
		$finish;
	end
	task write(input integer num_writes);
	begin
		for(i=0;i<num_writes;i=i+1)begin
			@(posedge clk);
			wr_en=1;
			wdata=$random;
		end
		@(posedge clk);
		wr_en=0;
		wdata=0;
	end
	endtask
	task read(input integer num_reads);
	begin
		for(j=0;j<num_reads;j=j+1)begin
			@(posedge clk);
			rd_en=1;
		end
		@(posedge clk);
		rd_en=0;
	end
	endtask
endmodule
