library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.all;

entity tb_generic is end;

architecture test of tb_generic is
  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal d, q  : std_logic_vector(31 downto 0) := (others => '0');

  signal a, b, sum : std_logic_vector(31 downto 0) := (others => '0');

  signal m0, m1, m2 : std_logic_vector(31 downto 0) := (others => '0');
  signal s2 : std_logic := '0';
  signal s3 : std_logic_vector(1 downto 0) := "00";
  signal y2, y3 : std_logic_vector(31 downto 0);
begin
  u_flopr: entity work.flopr generic map(32) port map(clk, reset, d, q);
  u_adder: entity work.adder port map(a, b, sum);
  u_mux2:  entity work.mux2  generic map(32) port map(m0, m1, s2, y2);
  u_mux3:  entity work.mux3  generic map(32) port map(m0, m1, m2, s3, y3);

  clk <= not clk after 5 ns;

  process
    variable errors : integer := 0;

    procedure check(got, expected : std_logic_vector(31 downto 0); name : string) is
    begin
      if got /= expected then
        errors := errors + 1;
        report "FAIL: " & name severity error;
      end if;
    end;
  begin
    -- flopr: held in reset at start
    wait for 2 ns;
    check(q, X"00000000", "flopr reset value");

    -- flopr: captures d on the rising edge
    reset <= '0';
    d <= X"DEADBEEF";
    wait until rising_edge(clk);
    wait for 1 ns;
    check(q, X"DEADBEEF", "flopr captures d");

    -- flopr: holds between clock edges
    d <= X"12345678";
    wait for 2 ns;
    check(q, X"DEADBEEF", "flopr holds until next edge");

    -- flopr: asynchronous reset (no clock edge needed)
    reset <= '1';
    wait for 1 ns;
    check(q, X"00000000", "flopr async reset");
    reset <= '0';
    wait for 1 ns;

    -- adder
    a <= X"00000005"; b <= X"00000007"; wait for 1 ns;
    check(sum, X"0000000C", "5 + 7");
    a <= X"FFFFFFFF"; b <= X"00000001"; wait for 1 ns;
    check(sum, X"00000000", "adder wraps around");
    a <= X"00001000"; b <= X"00000004"; wait for 1 ns;
    check(sum, X"00001004", "PC + 4");

    -- mux2
    m0 <= X"AAAAAAAA"; m1 <= X"BBBBBBBB"; m2 <= X"CCCCCCCC";
    s2 <= '0'; wait for 1 ns;
    check(y2, X"AAAAAAAA", "mux2 select 0");
    s2 <= '1'; wait for 1 ns;
    check(y2, X"BBBBBBBB", "mux2 select 1");

    -- mux3
    s3 <= "00"; wait for 1 ns;
    check(y3, X"AAAAAAAA", "mux3 select 00");
    s3 <= "01"; wait for 1 ns;
    check(y3, X"BBBBBBBB", "mux3 select 01");
    s3 <= "10"; wait for 1 ns;
    check(y3, X"CCCCCCCC", "mux3 select 10");

    if errors = 0 then
      report "tb_generic: ALL TESTS PASSED";
    else
      report "tb_generic: " & integer'image(errors) & " FAILED";
    end if;
    finish;
  end process;
end;