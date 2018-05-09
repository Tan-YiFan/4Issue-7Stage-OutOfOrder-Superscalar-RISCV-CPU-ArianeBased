// MBT 7/7/2016
//
// 1 read-port, 1 write-port ram
//
// reads are synchronous
//
// although we could merge this with normal bsg_mem_1r1w
// and select with a parameter, we do not do this because
// it's typically a very big change to the instantiating code
// to move to/from sync/async, and we want to reflect this.
//

module bsg_mem_1r1w_sync #(parameter width_p=-1
                           , parameter els_p=-1
                           , parameter read_write_same_addr_p=0
                           , parameter addr_width_lp= -1
                           , parameter harden_p=0
                           , parameter disable_collision_warning_p=1
                           )
   (input   clk_i
    , input reset_i

    , input                     w_v_i
    , input [addr_width_lp-1:0] w_addr_i
    , input [width_p-1:0]       w_data_i

    // currently unused
    , input                      r_v_i
    , input [addr_width_lp-1:0]  r_addr_i

    , output logic [width_p-1:0] r_data_o
    );

   bsg_mem_1r1w_sync_synth
     #(.width_p(width_p)
       ,.els_p(els_p)
       ,.read_write_same_addr_p(read_write_same_addr_p)
       ,.addr_width_lp(addr_width_lp)
	   ,.harden_p(harden_p)
       ) synth
       (.*);

   //synopsys translate_off
   initial
     begin
        $display("## %L: instantiating width_p=%d, els_p=%d, read_write_same_addr_p=%d, harden_p=%d (%m)",width_p,els_p,read_write_same_addr_p,harden_p);
     end

   always_ff @(posedge clk_i)
     if (w_v_i)
       begin
          assert ((reset_i === 'X) || (reset_i === 1'b1) || (w_addr_i < els_p))
            else $error("Invalid address %x to %m of size %x\n", w_addr_i, els_p);

          assert ((reset_i === 'X) || (reset_i === 1'b1) || ~(r_addr_i == w_addr_i && w_v_i && r_v_i && !read_write_same_addr_p && !disable_collision_warning_p))
            else
              begin
                 $error("X'ing matched read address %x (%m)",r_addr_i);
              end
       end
   //synopsys translate_on

endmodule

module accum_testbench;
    reg clk;
	 bsg_mem_1r1w_sync #(.width_p(52)
                           , .els_p(10)
                           , .read_write_same_addr_p(0)
                           , .addr_width_lp(8)
                           , .harden_p(1)
                           , .disable_collision_warning_p(1)
                           ) dut (
						 .clk_i(),
						 .reset_i(),
						 .w_v_i(),
						 .w_addr_i(),
						 .w_data_i(),
						 .r_v_i(),
						 .r_addr_i(),
						 .r_data_o()
						   );
    
	parameter CLOCK_PERIOD=1000;
     initial begin
     clk <= 0;
     forever #(CLOCK_PERIOD/2) clk <= ~clk;
     end
     integer i;
     // Set up the inputs to the design. Each line is a clock cycle.
     initial begin
     
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
     $stop; // End the simulation.
     end
endmodule
