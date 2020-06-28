module Branch_Control_2
(
    input Branch, Zero, Is_Greater,
    input [3:0] funct,
    output reg switch_branch
);


always @(*) begin

    if (Branch) begin

        case ({funct[2:0]})
            3'b000: switch_branch = Zero ? 1 : 0;
            3'b001: switch_branch = Zero ? 0 : 1;
            3'b101: switch_branch = Is_Greater ? 1 : 0;
        endcase
    
    end
    
    else
        switch_branch = 0;
end


endmodule // Branch_Control