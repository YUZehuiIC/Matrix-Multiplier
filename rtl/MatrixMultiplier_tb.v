// -----------------------------------------------------------------------------------------
// Version | Programmer                                     | Date       | Remark   
// -----------------------------------------------------------------------------------------
// V1      | Dr Kwen-Siong Chong (kschong@ntu.edu.sg)       | 01/08/2013 | Initial version
// -----------------------------------------------------------------------------------------  
//
//  The code is a test benchmark for checking a synchronous-logic matrix multiplier
// The code is for teaching purpose in the NTU-TUM class, NM6008. 
`timescale 1ns/1ps


module MatrixMultiplier_tb;

parameter CLK_T = 50;
parameter N = 2;
 
reg CLK, NRST, START;
reg [7:0] A, B, A0, A1, B0, B1, REG_B [N-1:0];
reg [9:0] REG_A [N-1:0];
wire [16:0] OUT;
wire OUT_STROBE;

integer file1, i;
initial $sdf_annotate("Syn_MatrixMultiplier.sdf", MM1);

MatrixMultiplier MM1(
	.CLK(CLK),
	.NRST(NRST),
	.START(START),
	.A(A),
	.B(B),
	.OUT(OUT),
	.OUT_STROBE(OUT_STROBE)
	);

initial
	begin
		file1 = $fopen("./Check.txt");
    	if (!file1) $finish;

    	$readmemb("./InputVector1.txt", REG_A);
		$readmemb("./InputVector2.txt", REG_B);
	end

initial
  	begin
		NRST = 0; // 0 Effective
		START = 0; // 1 Effective
    	A = 0; A0 = 0; A1 = 0;
    	B = 0; B0 = 0; B1 = 0;
		#(CLK_T-10) NRST = 1;// Delay time here should be less than CLK_T(half of CLK period)
		//START = 1;
		$vcdpluson(MM1);

		$fdisplay(file1, "NO\tNRST\tSTART\tA\tB\tOUT_STROBE\tOUT");

		for (i = 0; i < N; i = i + 1)
			begin
				if(i%2 == 0)
					begin
						{NRST, START, A0} = REG_A[i];
						B0 = REG_B[i];
						
						A = A0;
						B = B0;
						
					end
				else
					begin
						{NRST, START, A1} = REG_A[i];
						B1 = REG_B[i];
						A = A1;
						B = B1;
					end
				$fdisplay(file1, "%d\t%d\t%d\t%d\t%d\t%d\t%d", i, NRST, START, A, B, OUT_STROBE, OUT);
				#(CLK_T*6);
			end
		#(CLK_T*6);
		$fclose(file1);
		$vcdplusoff(MM1);
		$finish;
	end

// Clock genertor
initial
	begin
		CLK = 0;
		forever #CLK_T CLK = !CLK; // Every CLK_T, CLK flips -> CLK_T is a half of the CLK period
	end

//
initial
	begin
		#(1000*CLK_T);
		$finish;
	end

endmodule
