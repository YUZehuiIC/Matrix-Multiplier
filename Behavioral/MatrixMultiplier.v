// -----------------------------------------------------------------------------------------
// Version | Programmer                                     | Date       | Remark   
// -----------------------------------------------------------------------------------------
// V1      | Dr Kwen-Siong Chong (kschong@ntu.edu.sg)       | 06/08/2013 | Initial version
// -----------------------------------------------------------------------------------------  
//
// The code is a behavioural code for a synchronous-logic matrix multiplier
// The code is for teaching purpose in the NTU-TUM class, NM6008. 
module MatrixMultiplier (
	CLK,
	NRST,
	START,
	A,
	B,

	OUT,
	OUT_STROBE);
// Variables Declaration
input CLK, NRST, START, A, B;
output OUT, OUT_STROBE;

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;
parameter S3 = 2'b11;

reg [1:0] state, next_state;

wire [7:0] A, B;
reg [16:0] OUT;

wire [16:0] P_temp;
reg [16:0] Add1, Add2, Addsum_temp, Addsum;
reg OUT_STROBE, EN1, EN2, EN3;

reg Flag;// = 1;

assign P_temp = $signed(A) * $signed(B); // assign can only be used for wire

always @ (posedge CLK or negedge NRST)
	if (!NRST)
		begin
			state <= #1 S0;
			Add1 = 0; Add2 = 0; //EN1 = 0; EN2 = 0; EN3 = 0;
			OUT = 0; Flag = 1; OUT_STROBE = 0; Addsum = 0; Addsum_temp = 0;
		end
	else
		begin
			state <= #1 next_state;
			if (EN1 == 1)
				begin
					Add1 = P_temp;
					Addsum_temp = $signed({Add1[16],Add1}) + $signed(Add2);
					Addsum = Addsum_temp;
				//# 10;	
				//Addsum_temp = Addsum;
				//OUT_STROBE = 0;			
				end
			else if (EN2 == 1)
				begin
					Add2 = Addsum;// Check Logic Here
				//Addsum_temp = $signed({Add1[16],Add1}) + $signed(Add2);
				//OUT_STROBE = 0;
				end
			else if (EN3 == 1)
				begin
				//OUT_STROBE = 1;
				
					Flag = !Flag;
					if (Flag == 1)
						begin
							OUT_STROBE = 1;
							OUT = Addsum;
							Add1 = 0; Add2 = 0; Addsum_temp = 0;
						end
					else
						begin
							OUT = 0;
							OUT_STROBE = 0;
						end
				
				end
			else
				begin
					Add1 = 0;
					Add2 = 0;
				end
		end

/*always @ (posedge CLK)
	begin
		// Ensure EN changes before assignning values 
		if (EN1 == 1)
			begin
				Add1 = P_temp;
				Addsum_temp = $signed({Add1[16],Add1}) + $signed(Add2);
				Addsum = Addsum_temp;
				//# 10;	
				//Addsum_temp = Addsum;
				//OUT_STROBE = 0;			
			end
		else if (EN2 == 1)
			begin
				Add2 = Addsum;// Check Logic Here
				//Addsum_temp = $signed({Add1[16],Add1}) + $signed(Add2);
				//OUT_STROBE = 0;
			end
		else if (EN3 == 1)
			begin
				//OUT_STROBE = 1;
				
				Flag = !Flag;
				if (Flag == 1)
					begin
						OUT_STROBE = 1;
						OUT = Addsum;
						Add1 = 0; Add2 = 0; Addsum_temp = 0;
					end
				else
					begin
						OUT = 0;
						OUT_STROBE = 0;
					end
				
			end
		else
			begin
				Add1 = 0;
				Add2 = 0;
			end
	end
*/
// State Machine
always @ (state or START)
	case (state)
		S0: begin
				if (START)
					next_state = S1;
				else
					next_state = S0;
				EN1 = 0;
				EN2 = 0;
				EN3 = 0;
			end
		S1: begin
				next_state = S2;
				EN2 = 0; EN3 = 0;
				EN1 = 1;
				
			end
		S2: begin
				next_state = S3;
				EN1 = 0; EN3 = 0;
				EN2 = 1;
				
			end
		S3: begin
				EN1 = 0; EN2 = 0;
				EN3 = 1;
				next_state = S1;
				
			end
	endcase

endmodule




