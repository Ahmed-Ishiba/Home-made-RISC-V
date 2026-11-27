library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity regfile is
  port (clk     : in  std_logic;
        we3     : in  std_logic;
        a1, a2, a3 : in  std_logic_vector(4 downto 0);
        wd3     : in  std_logic_vector(31 downto 0);
        rd1, rd2 : out std_logic_vector(31 downto 0));
end;

architecture behave of regfile is
  type ramtype is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal mem : ramtype := (others => (others => '0'));
begin
  -- Three-ported register file:
  -- two combinational read ports (a1/rd1, a2/rd2),
  -- one write port (a3/wd3) written on the rising clock edge.
  process (clk) begin
    if rising_edge(clk) then
      if we3 = '1' then
        mem(to_integer(unsigned(a3))) <= wd3;
      end if;
    end if;
  end process;

  -- Register x0 is hardwired to zero
  rd1 <= (others => '0') when a1 = "00000" else mem(to_integer(unsigned(a1)));
  rd2 <= (others => '0') when a2 = "00000" else mem(to_integer(unsigned(a2)));
end;