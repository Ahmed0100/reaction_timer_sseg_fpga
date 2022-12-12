module lfsr
(
	input clk,reset_n,
	input start,
	output reg done_tick,
	output [13:0] random_num
);

reg [13:0] q_reg;
wire [13:0] q_next;
always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
		q_reg <= 0;
	else
		q_reg<=q_next;
end
assign q_next= q_reg + 1;

reg [1:0] current_state,next_state;
reg [13:0] random_num_reg,random_num_next;
reg [4:0] shift_count_reg,shift_count_next;
wire linear_feedback;

localparam [1:0]
	idle=2'b00,
	shift=2'b01,
	done = 2'b10;

always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		current_state <= idle;
		random_num_reg<=0;
		shift_count_reg <=0;
	end
	else
	begin
		current_state<=next_state;
		random_num_reg<=random_num_next;
		shift_count_reg<=shift_count_next;
	end
end
always @*
begin
	next_state = current_state;
	done_tick=0;
	random_num_next=random_num_reg;
	shift_count_next=shift_count_reg;
	case(current_state)
		idle:
			if(start)
			begin
				random_num_next= q_reg;
				shift_count_next=6'd14;
				next_state = shift;
			end
		shift:
		begin
			random_num_next={random_num_reg[12:0],linear_feedback};
			shift_count_next = shift_count_reg-1;
			if(shift_count_next==0)
				next_state = done;
		end
		done:
		begin
			done_tick=1;
			next_state= idle;
		end
		default:
			next_state = idle;
	endcase
end
assign linear_feedback=~(random_num_reg[13]^ random_num_reg[4]
^random_num_reg[2] ^ random_num_reg[0]);
assign random_num = random_num_reg;

endmodule