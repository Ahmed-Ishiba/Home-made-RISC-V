library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.all;

entity tb_alu is end;

architecture test of tb_alu is
  constant C_ADD  : std_logic_vector(3 downto 0) := "0000";
  constant C_SUB  : std_logic_vector(3 downto 0) := "1000";
  constant C_SLL  : std_logic_vector(3 downto 0) := "0001";
  constant C_SLT  : std_logic_vector(3 downto 0) := "0010";
  constant C_SLTU : std_logic_vector(3 downto 0) := "0011";
  constant C_XOR  : std_logic_vector(3 downto 0) := "0100";
  constant C_SRL  : std_logic_vector(3 downto 0) := "0101";
  constant C_SRA  : std_logic_vector(3 downto 0) := "1101";
  constant C_OR   : std_logic_vector(3 downto 0) := "0110";
  constant C_AND  : std_logic_vector(3 downto 0) := "0111";

  signal a, b, result : std_logic_vector(31 downto 0) := (others => '0');
  signal ctrl : std_logic_vector(3 downto 0) := "0000";
  signal zero : std_logic;
begin
  dut: entity work.alu
    port map (a => a, b => b, ALUControl => ctrl, ALUResult => result, Zero => zero);

  process
    variable errors : integer := 0;

    procedure check(ca, cb : std_logic_vector(31 downto 0);
                    c : std_logic_vector(3 downto 0);
                    expected : std_logic_vector(31 downto 0);
                    name : string) is
      variable exp_z : std_logic;
    begin
      a <= ca; b <= cb; ctrl <= c;
      wait for 10 ns;
      if expected = X"00000000" then exp_z := '1'; else exp_z := '0'; end if;
      if result /= expected then
        errors := errors + 1;
        report "FAIL (result): " & name severity error;
      end if;
      if zero /= exp_z then
        errors := errors + 1;
        report "FAIL (zero flag): " & name severity error;
      end if;
    end;
  begin
    -- ADD
    check(X"00000005", X"00000007", C_ADD, X"0000000C", "5 + 7");
    check(X"7FFFFFFF", X"00000001", C_ADD, X"80000000", "add wraps");
    check(X"FFFFFFFD", X"00000003", C_ADD, X"00000000", "-3 + 3 (zero flag)");

    -- SUB
    check(X"0000000C", X"00000005", C_SUB, X"00000007", "12 - 5");
    check(X"00000005", X"00000005", C_SUB, X"00000000", "5 - 5 (zero flag)");
    check(X"00000003", X"00000005", C_SUB, X"FFFFFFFE", "3 - 5");

    -- SLL (shift amount = b(4 downto 0))
    check(X"00000001", X"00000004", C_SLL, X"00000010", "1 << 4");
    check(X"00000001", X"0000001F", C_SLL, X"80000000", "1 << 31");
    check(X"00000001", X"00000024", C_SLL, X"00000010", "shamt uses only low 5 bits");

    -- SLT (signed) / SLTU (unsigned)
    check(X"00000003", X"00000005", C_SLT,  X"00000001", "slt 3 < 5");
    check(X"00000005", X"00000003", C_SLT,  X"00000000", "slt 5 < 3");
    check(X"FFFFFFFF", X"00000001", C_SLT,  X"00000001", "slt -1 < 1");
    check(X"FFFFFFFF", X"00000001", C_SLTU, X"00000000", "sltu 0xFFFFFFFF < 1");
    check(X"00000001", X"FFFFFFFF", C_SLTU, X"00000001", "sltu 1 < 0xFFFFFFFF");

    -- XOR / OR / AND
    check(X"F0F0F0F0", X"FFFF0000", C_XOR, X"0F0FF0F0", "xor");
    check(X"0000000C", X"00000003", C_OR,  X"0000000F", "or");
    check(X"0000000C", X"0000000A", C_AND, X"00000008", "and");

    -- SRL (logical) vs SRA (arithmetic)
    check(X"80000000", X"00000004", C_SRL, X"08000000", "srl 0x80000000 >> 4");
    check(X"80000000", X"00000004", C_SRA, X"F8000000", "sra 0x80000000 >> 4");
    check(X"40000000", X"00000004", C_SRA, X"04000000", "sra positive value");

    -- Unused opcode returns 0
    check(X"12345678", X"9ABCDEF0", "1111", X"00000000", "undefined op");

    if errors = 0 then
      report "tb_alu: ALL TESTS PASSED";
    else
      report "tb_alu: " & integer'image(errors) & " FAILED";
    end if;
    finish;
  end process;
end;