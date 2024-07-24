library verilog;
use verilog.vl_types.all;
entity CPU is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        port_b_out      : out    vl_logic_vector(7 downto 0)
    );
end CPU;
