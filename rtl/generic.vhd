library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Resettable flip-flop (asynchronous reset)
entity flopr is
  generic (width : integer);
  port (clk, reset : in  std_logic;
        d          : in  std_logic_vector(width-1 downto 0);
        q          : out std_logic_vector(width-1 downto 0));
end;

architecture asynchronous of flopr is
begin
  process (clk, reset) begin
    if reset = '1' then
      q <= (others => '0');
    elsif rising_edge(clk) then
      q <= d;
    end if;
  end process;
end;

----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity adder is
  port (a, b : in  std_logic_vector(31 downto 0);
        y    : out std_logic_vector(31 downto 0));
end;

architecture behave of adder is
begin
  y <= std_logic_vector(unsigned(a) + unsigned(b));
end;

----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux2 is
  generic (width : integer);
  port (d0, d1 : in  std_logic_vector(width-1 downto 0);
        s      : in  std_logic;
        y      : out std_logic_vector(width-1 downto 0));
end;

architecture behave of mux2 is
begin
  y <= d1 when s = '1' else d0;
end;

----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux3 is
  generic (width : integer);
  port (d0, d1, d2 : in  std_logic_vector(width-1 downto 0);
        s          : in  std_logic_vector(1 downto 0);
        y          : out std_logic_vector(width-1 downto 0));
end;

architecture behave of mux3 is
begin
  y <= d2 when s(1) = '1' else
       d1 when s(0) = '1' else
       d0;
end;

----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Immediate extender: instr is bits 31:7 of the instruction
entity extend is
  port (instr  : in  std_logic_vector(31 downto 7);
        immsrc : in  std_logic_vector(1 downto 0);
        immext : out std_logic_vector(31 downto 0));
end;

architecture behave of extend is
begin
  process (instr, immsrc) begin
    case immsrc is
      when "00" =>  -- I-type
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 20);
      when "01" =>  -- S-type (stores)
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7);
      when "10" =>  -- B-type (branches)
        immext <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
      when "11" =>  -- J-type (jal)
        immext <= (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
      when others =>
        immext <= (others => '-');
    end case;
  end process;
end;