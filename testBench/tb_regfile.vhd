library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.all;

entity tb_register_file is end;

architecture test of tb_register_file is
  signal clk : std_logic := '0';
  signal we3 : std_logic := '0';
  signal a1, a2, a3 : std_logic_vector(4 downto 0) := (others => '0');
  signal wd3, rd1, rd2 : std_logic_vector(31 downto 0) := (others => '0');
begin
  dut: entity work.regfile
    port map (clk => clk, we3 => we3, a1 => a1, a2 => a2, a3 => a3,
              wd3 => wd3, rd1 => rd1, rd2 => rd2);

  clk <= not clk after 5 ns;

  process
    variable errors : integer := 0;

    procedure write_reg(addr : integer; val : std_logic_vector(31 downto 0); en : std_logic) is
    begin
      wait until falling_edge(clk);
      a3  <= std_logic_vector(to_unsigned(addr, 5));
      wd3 <= val;
      we3 <= en;
      wait until rising_edge(clk);
      wait for 1 ns;
      we3 <= '0';
    end;

    procedure check(got, expected : std_logic_vector(31 downto 0); name : string) is
    begin
      if got /= expected then
        errors := errors + 1;
        report "FAIL: " & name severity error;
      end if;
    end;
  begin
    -- 0. Registers start at zero
    a1 <= "00001"; a2 <= "00010"; wait for 1 ns;
    check(rd1, X"00000000", "x1 initial value");
    check(rd2, X"00000000", "x2 initial value");

    -- 1. Write x5, read it on both ports
    write_reg(5, X"DEADBEEF", '1');
    a1 <= "00101"; a2 <= "00101"; wait for 1 ns;
    check(rd1, X"DEADBEEF", "x5 on port 1");
    check(rd2, X"DEADBEEF", "x5 on port 2");

    -- 2. x0 always reads zero, even after a write
    write_reg(0, X"FFFFFFFF", '1');
    a1 <= "00000"; a2 <= "00000"; wait for 1 ns;
    check(rd1, X"00000000", "x0 on port 1");
    check(rd2, X"00000000", "x0 on port 2");

    -- 3. we3 = 0 must not write
    write_reg(5, X"12345678", '0');
    a1 <= "00101"; wait for 1 ns;
    check(rd1, X"DEADBEEF", "write with we3=0 changed x5");

    -- 4. Two different registers read at the same time
    write_reg(10, X"0000000A", '1');
    write_reg(31, X"FFFFFFFF", '1');
    a1 <= "01010"; a2 <= "11111"; wait for 1 ns;
    check(rd1, X"0000000A", "x10 on port 1");
    check(rd2, X"FFFFFFFF", "x31 on port 2");

    -- 5. Overwrite an existing register
    write_reg(10, X"00000064", '1');
    a1 <= "01010"; wait for 1 ns;
    check(rd1, X"00000064", "x10 overwrite");

    if errors = 0 then
      report "tb_register_file: ALL TESTS PASSED";
    else
      report "tb_register_file: " & integer'image(errors) & " FAILED";
    end if;
    finish;
  end process;
end;