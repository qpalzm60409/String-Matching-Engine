module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output match;
output [4:0] match_index;
output valid;
reg match;
reg [4:0] match_index;
reg valid;

//
parameter CHR_HAT = 8'h5E ;   // ^ : starting position of the string or 'space' would match
parameter CHR_MONEY = 8'h24 ;   // $ : ending position of the string or 'space' would match
parameter CHR_POINT = 8'h2E ;   // . : any of a single charater would match
parameter CHR_STAR = 8'h2A ;   // * : any of multiple characters would match
parameter CHR_SPACE = 8'h20 ;   //   : space
//

reg [7:0] str_reg[33:0];
reg [3:0] count_p;
reg [5:0] count_s;
reg [5:0] str_num;
//reg done;

reg [33:0] match_line;
reg [33:0] match_reg;
reg [4:0] match_index_buffer;
reg hat_c;
reg star_c;
//reg [4:0] star_num;
reg [4:0] star_match_index;
reg star_first;
//reg pat_first;
reg match_ns;
integer i;
//valid
always@(posedge clk or posedge reset) begin
    if(reset) valid <= 1'd0;
    else valid <= 1'd1;
end
//match
always@(posedge clk or posedge reset) begin
    if(reset) match <= 1'd0;
    else  match <= match_ns;
end
//match_ns
always@(*) begin
    if(reset) match_ns = 0;
    else begin
		if (chardata==CHR_HAT) match_ns = 0;
		else if (chardata==CHR_MONEY && count_p==1 && star_c==0) match_ns = 0;
		else   match_ns = |match_reg;
	end
end
//match index
always@(posedge clk) begin
    if(reset) begin
	match_index <= 0;
	star_match_index <=0;
	end
    else begin
		if (star_c) match_index <= star_match_index;
		else match_index <= match_index_buffer;
		if (chardata==CHR_STAR) star_match_index <= match_index_buffer;
	end
end
//match index_buffer
always@(*) begin										//test
    if(reset) begin
	match_index_buffer = 0;
	end
    else begin
	match_index_buffer = 0;
	if(match_reg[0]) match_index_buffer = 0;
	else if(match_reg[1]) match_index_buffer = 0+hat_c;
    else if(match_reg[2]) match_index_buffer = 1+hat_c;
    else if(match_reg[3]) match_index_buffer = 2+hat_c;
    else if(match_reg[4]) match_index_buffer = 3+hat_c;
    else if(match_reg[5]) match_index_buffer = 4+hat_c;
    else if(match_reg[6]) match_index_buffer = 5+hat_c;
    else if(match_reg[7]) match_index_buffer = 6+hat_c;
    else if(match_reg[8]) match_index_buffer = 7+hat_c;
    else if(match_reg[9]) match_index_buffer = 8+hat_c;
    else if(match_reg[10]) match_index_buffer = 9+hat_c;
    else if(match_reg[11]) match_index_buffer = 10+hat_c;
    else if(match_reg[12]) match_index_buffer = 11+hat_c;
    else if(match_reg[13]) match_index_buffer = 12+hat_c;
    else if(match_reg[14]) match_index_buffer = 13+hat_c;
    else if(match_reg[15]) match_index_buffer = 14+hat_c;
    else if(match_reg[16]) match_index_buffer = 15+hat_c;
    else if(match_reg[17]) match_index_buffer = 16+hat_c;
    else if(match_reg[18]) match_index_buffer = 17+hat_c;
    else if(match_reg[19]) match_index_buffer = 18+hat_c;
    else if(match_reg[20]) match_index_buffer = 19+hat_c;
    else if(match_reg[21]) match_index_buffer = 20+hat_c;
    else if(match_reg[22]) match_index_buffer = 21+hat_c;
    else if(match_reg[23]) match_index_buffer = 22+hat_c;
    else if(match_reg[24]) match_index_buffer = 23+hat_c;
    else if(match_reg[25]) match_index_buffer = 24+hat_c;
    else if(match_reg[26]) match_index_buffer = 25+hat_c;
    else if(match_reg[27]) match_index_buffer = 26+hat_c;
    else if(match_reg[28]) match_index_buffer = 27+hat_c;
    else if(match_reg[29]) match_index_buffer = 28+hat_c;
    else if(match_reg[30]) match_index_buffer = 29+hat_c;
    else if(match_reg[31]) match_index_buffer = 30+hat_c;
    else if(match_reg[32]) match_index_buffer = 31+hat_c;
	//else match_index_buffer = 31;
	end
end

//if star is first of pat then star_first=1 
always@(*) begin 
    if(reset) star_first = 0;
    else if(chardata==CHR_STAR) star_first = 1;
	else star_first = 0;
end
//pattern counter
always@(posedge clk or posedge reset) begin
    if(reset) count_p <= 5'd0;
    else if(ispattern == 1'd1) begin
		if (chardata==CHR_STAR) count_p <= 0; //test
		else count_p <= count_p + 5'd1;			
	end
    else count_p <= 5'd0;
end

//read string
always@(posedge clk or posedge reset) begin
    if(reset) begin
        for(i=0;i<34;i=i+1) begin
            str_reg[i] <= CHR_SPACE;
        end       
    end
    else if(isstring == 1'd1) str_reg[count_s] <= chardata;
	else if (ispattern == 1'd1) str_reg[str_num] <= CHR_SPACE;  //str_reg end must be space
end
//string counter
always@(posedge clk or posedge reset) begin
    if(reset) begin
	count_s <= 5'd1;
	str_num <= 5'd1;
	end
    else if(isstring == 1'd1) begin	
	count_s <= count_s + 5'd1;
	str_num <= count_s + 5'd1;
	end
    else  count_s <= 5'd1;
end
//output logic for match_line
always@(*) begin
		if(reset) begin
		match_line = 0; 
		end
		else begin		
			if (ispattern==1) begin
				match_line = 0;
				for(i=0;i<=str_num;i=i+1) begin 		//str_reg can's not reset so i<str_num
					if (chardata==CHR_HAT) match_line[i] = (CHR_SPACE==str_reg[i]);
					else if  (chardata==CHR_POINT) begin
						match_line[i] =1;
						match_line[0] =0;
						match_line[33] =0;
					end
					else if  (chardata==CHR_STAR && match_ns==1 || star_first==1 ) begin
						match_line	= 	(34'b11_1111_1111_1111_1111_1111_1111_1111_1111 << (match_index_buffer+2));															//test
					end
					else if  (chardata==CHR_MONEY) match_line[i] = (CHR_SPACE==str_reg[i]);
					else  begin
						match_line[i+1] = (chardata==str_reg[i+1]);	
						match_line[33] = 0;							//for pat "bitter " 
					end
				end	
			end
			else begin
				match_line = 0;
			end
		end			
end

always@(posedge clk) begin
		if(reset) match_reg <=34'b11_1111_1111_1111_1111_1111_1111_1111_1111;		
		else if (ispattern==1) begin
			if (chardata==CHR_STAR && match_ns==1) match_reg <= match_line &34'b11_1111_1111_1111_1111_1111_1111_1111_1111;
			else match_reg <= (match_line >>count_p)&match_reg;
		end 
		else match_reg <=34'b11_1111_1111_1111_1111_1111_1111_1111_1111 >> (33-str_num); //1's number must equal to str_num 
end
//assign match_index = match_reg;
always@(posedge clk) begin
		if(reset) begin 
			hat_c <=0;
			star_c <=0;			
		end
		else if (ispattern==1&&chardata==CHR_HAT) begin
		hat_c <=1;			
		end
		else if (ispattern==1&&chardata==CHR_STAR) begin	//test
		star_c <=1;			
		end
		else if (ispattern==0) begin
		hat_c <=0;
		star_c <=0;
		end		
end
endmodule