`timescale 1ns / 1ps

module lift_controller(
    input clk,
    input rst,
    input [3:0] floor_request,
    input emergency_stop,
    output reg move_up,
    output reg move_down,
    output reg motor_stop,
    output reg [1:0] current_floor
);

    // State encoding
    parameter IDLE = 2'b00;
    parameter UP   = 2'b01;
    parameter DOWN = 2'b10;
    parameter EMERGENCY = 2'b11;

    reg [1:0] current_state, next_state;
    reg [1:0] target_floor;

    // Priority logic
    always @(*) begin
        target_floor = current_floor;
        if (floor_request[0]) target_floor = 2'd0;
        else if (floor_request[1]) target_floor = 2'd1;
        else if (floor_request[2]) target_floor = 2'd2;
        else if (floor_request[3]) target_floor = 2'd3;
    end

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Floor tracking
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_floor <= 2'd0;
        else if (current_state == UP)
            current_floor <= current_floor + 1'b1;
        else if (current_state == DOWN)
            current_floor <= current_floor - 1'b1;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;

        if (emergency_stop)
            next_state = EMERGENCY;
        else begin
            case (current_state)
                IDLE: begin
                    if (target_floor > current_floor)
                        next_state = UP;
                    else if (target_floor < current_floor)
                        next_state = DOWN;
                end

                UP: begin
                    if (target_floor == current_floor)
                        next_state = IDLE;
                end

                DOWN: begin
                    if (target_floor == current_floor)
                        next_state = IDLE;
                end

                EMERGENCY: begin
                    if (!emergency_stop)
                        next_state = IDLE;
                end

                default: next_state = IDLE;
            endcase
        end
    end

    // Output logic
    always @(*) begin
        move_up = 0;
        move_down = 0;
        motor_stop = 0;

        case (current_state)
            UP:   move_up = 1;
            DOWN: move_down = 1;
            EMERGENCY: motor_stop = 1;
            IDLE: motor_stop = 1;
        endcase
    end

endmodule
