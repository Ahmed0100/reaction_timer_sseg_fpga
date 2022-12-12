module reaction_timer_top
(
	input clk,
	input reset_n,
	input start,clear,stop,
	output [3:0] sel,
	output [7:0] sseg,
	output led
);

wire start_db,stop_db,clear_db;
wire[3:0]  bcd3, bcd2, bcd1, bcd0;
wire       done_pseudo, start_pseudo;
wire[13:0] reaction_time, random_num;
wire       sseg_msg, sseg_active;

db_fsm db_fsm_inst0
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(!start),
	.db(start_db)
);

db_fsm db_fsm_inst1
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(!stop),
	.db(stop_db)
);

db_fsm db_fsm_inst2
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(!clear),
	.db(clear_db)
);

reaction_timer reaction_unit
        (.clk(clk), .reset_n(reset_n), .start(start_db), .clear(clear_db),
         .stop(stop_db), .done_pseudo(done_pseudo), .random_num(random_num),
         .reaction_time(reaction_time), .sseg_active(sseg_active),
         .sseg_mesg(sseg_msg), .reaction_led(led), 
         .start_bin2bcd(start_bin2bcd), .start_pseudo(start_pseudo));

lfsr lfsr_inst
(
	.clk(clk),.reset_n(reset_n),
	.start(start_pseudo),
	.done_tick(done_pseudo),
	.random_num(random_num)
);

bin2bcd bin2bcd_inst
    (
     .clk(clk), .reset_n(reset_n),
     .start(start_bin2bcd),
     .bin(reaction_time),
    .ready(), .done_tick(),
     .bcd3(bcd3), .bcd2(bcd2), .bcd1(bcd1), .bcd0(bcd0)
);

disp_hex_mux disp_hex_mux_inst
(
	.clk(clk), .reset_n(reset_n),
    .active(sseg_active), .mesg(sseg_msg),
    .hex3(bcd3), .hex2(bcd2), .hex1(bcd1), .hex0(bcd0),
    .dp_in(4'b0111),
    .an(sel),
    .sseg(sseg)
);

endmodule