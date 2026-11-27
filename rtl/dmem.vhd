library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    port(
        clk : in std_logic;
        we  : in std_logic;
        addr: in std_logic_vector(4 downto 0);
        data_in: in std_logic_vector
    )
