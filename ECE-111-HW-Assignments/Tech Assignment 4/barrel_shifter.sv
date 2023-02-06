// Barrel Shifter RTL Model
module barrel_shifter (
  input logic select,  // select=0 shift operation, select=1 rotate operation
  input logic direction, // direction=0 right move, direction=1 left move
  input logic[1:0] shift_value, // number of bits to be shifted (0, 1, 2 or 3)
  input logic[3:0] din,
  output logic[3:0] dout
);

	
// setting wires
  logic [3:0] inv_din;
  logic [3:0] inv_dout;
//mmux31,21,71 is a connection to input 1 of mux(number)
//mux0mux4 is a connection from output of mux0 to mux4 and so on
  logic mmux31, mmux21, mmux71, mux0mux4, mux1mux5, mux2mux6, mux3mux7;

// first of three always blocks. This block just inverts the din coming into the barrel shifter if it is going left. 
// If it is right then it won't invert
  always_comb begin
     if(direction == 1) begin
       inv_din[0] = din[3];
       inv_din[1] = din[2];  
       inv_din[2] = din[1];
       inv_din[3] = din[0];
  end else begin
       inv_din[0] = din[0];
       inv_din[1] = din[1];  
       inv_din[2] = din[2];
       inv_din[3] = din[3];
  end
end

	
// second always block. If it is a left or right shift it sets the input 1 of Mux 2, Mux 3, and Mux 7 to 0. If it is rotate then
// the value assigned to each Mux is inv_din[0], inv_din[1], and for 7 it is either inv_din[2] or inv_din[0]. 
// for inv_din these are the values assigned to in the first always block when you inverse or don't
	
always_comb begin

mmux21 = 0;
mmux31 = 0;
mmux71 = 0;

//Right Shift: select = 0, direction = 0
if((select == 0) && (direction == 0)) begin
mmux21 = 0;
mmux31 = 0;
mmux71 = 0;
end


//Right Rotate: select = 1, direction = 0
if((select == 1) && (direction == 0)) begin
mmux21 = inv_din[0];
mmux31 = inv_din[1];
if(shift_value[1]) begin
mmux71 = inv_din[2];
end else begin
mmux71 = inv_din[0];
end
end


//Left Shift: select = 0, direction = 1
if((select == 0) && (direction == 1)) begin
mmux21 = 0;
mmux31 = 0;
mmux71 = 0;
end

//Left Rotate: select = 1, direction = 1
if((select == 1) && (direction == 1)) begin
mmux21 = inv_din[0];
mmux31 = inv_din[1];
if(shift_value[1]) begin
mmux71 = inv_din[2];
end else begin
mmux71 = inv_din[0];
end
end
end

	
// third always block the flips inv_dout to dout
always_comb begin
if(direction == 1) begin
	dout[0] = inv_dout[3];
	dout[1] = inv_dout[2];  
	dout[2] = inv_dout[1];
	dout[3] = inv_dout[0];
end else begin
	dout[0] = inv_dout[0];
	dout[1] = inv_dout[1];  
	dout[2] = inv_dout[2];
	dout[3] = inv_dout[3];
end
end

// i followed the dicussion slides when writing my code
// mux connections
// same connections in diagram from discussion slides
mux_2x1 m0 (.in0(inv_din[0]),.in1(inv_din[2]),.sel(shift_value[1]),.out(mux0mux4));
mux_2x1 m1 (.in0(inv_din[1]),.in1(inv_din[3]),.sel(shift_value[1]),.out(mux1mux5));
mux_2x1 m2 (.in0(inv_din[2]),.in1(mmux21),.sel(shift_value[1]),.out(mux2mux6));
mux_2x1 m3 (.in0(inv_din[3]),.in1(mmux31),.sel(shift_value[1]),.out(mux3mux7));
mux_2x1 m4 (.in0(mux0mux4),.in1(mux1mux5),.sel(shift_value[0]),.out(inv_dout[3]));
mux_2x1 m5 (.in0(mux1mux5),.in1(mux2mux6),.sel(shift_value[0]),.out(inv_dout[2]));
mux_2x1 m6 (.in0(mux2mux6),.in1(mux3mux7),.sel(shift_value[0]),.out(inv_dout[1]));
mux_2x1 m7 (.in0(mux3mux7),.in1(mmux71),.sel(shift_value[0]),.out(inv_dout[0]));

endmodule: barrel_shifter
