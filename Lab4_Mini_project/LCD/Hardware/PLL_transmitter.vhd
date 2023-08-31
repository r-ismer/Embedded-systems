library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity PLL_transmitter is
  port(
    pin         : out  std_logic;
    clk         : in std_logic
  );
end PLL_transmitter;

architecture transfer of  PLL_transmitter is

begin

pin <= clk;

end transfer;
