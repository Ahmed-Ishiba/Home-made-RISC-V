library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.all;

entity tb_alu is end;

architecture test of tb_alu is
  constant C_ADD : std_logic_vector(2 downto 0) := "000";
  constant C_SUB : std_logic_vector(2 downto 0) := "001";
  constant C_AND : std_logic_vector(2 downto 0) := "010";
  constant C_OR  : std_logic_vector(2 downto 0) := "011";
  constant C_SLT : std_logic_vector(2 downto 0) := "101";

  signal a, b, result : std_logic_vector(31 downto 0) := (others => '0');
  signal ctrl : std_logic_vector(2 downto 0) := "000";
  signal zero : std_logic;
begin
  dut: entity work.alu
    port map (a => a, b => b, ALUControl => ctrl, ALUResult => result, Zero => zero);

  process
    variable errors : integer := 0;

    procedure check(ca, cb : integer; c : std_logic_vector(2 downto 0);
                    expected : integer; name : string) is
      variable exp_z : std_logic;
    begin
      a <= std_logic_vector(to_signed(ca, 32));
      b <= std_logic_vector(to_signed(cb, 32));
      ctrl <= c;
      wait for 10 ns;
      if expected = 0 then exp_z := '1'; else exp_z := '0'; end if;
      if result /= std_logic_vector(to_signed(expected, 32)) then
        errors := errors + 1;
        report "FAIL (result): " & name severity error;
      end if;
      if zero /= exp_z then
        errors := errors + 1;
        report "FAIL (zero flag): " & name severity error;
      end if;
    end;
  begin
    -- add
    check(5, 7, C_ADD, 12, "5 + 7");
    check(0, 0, C_ADD, 0, "0 + 0");
    check(2147483647, 1, C_ADD, -2147483648, "overflow wraps");
    check(-3, 3, C_ADD, 0, "-3 + 3");

    -- sub
    check(12, 5, C_SUB, 7, "12 - 5");
    check(5, 5, C_SUB, 0, "5 - 5");
    check(3, 5, C_SUB, -2, "3 - 5");

    -- and / or
    check(12, 10, C_AND, 8, "12 and 10");
    check(12, 3, C_OR, 15, "12 or 3");

    -- slt (signed)
    check(3, 5, C_SLT, 1, "3 < 5");
    check(5, 3, C_SLT, 0, "5 < 3");
    check(-1, 1, C_SLT, 1, "-1 < 1 (signed)");
    check(5, 5, C_SLT, 0, "5 < 5");

    if errors = 0 then
      report "tb_alu: ALL TESTS PASSED";
    else
      report "tb_alu: " & integer'image(errors) & " FAILED";
    end if;
    finish;
  end process;
end;