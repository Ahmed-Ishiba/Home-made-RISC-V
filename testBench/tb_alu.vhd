library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity tb_alu is
end entity;

architecture sim of tb_alu is
    signal a, b   : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_op : std_logic_vector(3 downto 0)  := "0000";
    signal result : std_logic_vector(31 downto 0);
    signal zero   : std_logic;

    constant OP_ADD  : std_logic_vector(3 downto 0) := "0000";
    constant OP_SUB  : std_logic_vector(3 downto 0) := "1000";
    constant OP_SLL  : std_logic_vector(3 downto 0) := "0001";
    constant OP_SLT  : std_logic_vector(3 downto 0) := "0010";
    constant OP_SLTU : std_logic_vector(3 downto 0) := "0011";
    constant OP_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant OP_SRL  : std_logic_vector(3 downto 0) := "0101";
    constant OP_SRA  : std_logic_vector(3 downto 0) := "1101";
    constant OP_OR   : std_logic_vector(3 downto 0) := "0110";
    constant OP_AND  : std_logic_vector(3 downto 0) := "0111";
begin
    uut: entity work.alu
        port map (a => a, b => b, alu_op => alu_op, result => result, zero => zero);

    stim: process
        variable errors : natural := 0;

        procedure check (
            constant op_v : in std_logic_vector(3 downto 0);
            constant a_v  : in std_logic_vector(31 downto 0);
            constant b_v  : in std_logic_vector(31 downto 0);
            constant exp  : in std_logic_vector(31 downto 0);
            constant name : in string
        ) is
            variable exp_zero : std_logic;
        begin
            alu_op <= op_v; a <= a_v; b <= b_v;
            wait for 10 ns;

            if exp = x"00000000" then exp_zero := '1'; else exp_zero := '0'; end if;

            if result /= exp then
                report "FAIL " & name & ": got " & to_hstring(result) &
                       " expected " & to_hstring(exp) severity error;
                errors := errors + 1;
            elsif zero /= exp_zero then
                report "FAIL " & name & ": zero flag wrong" severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        -- ADD / SUB
        check(OP_ADD,  x"00000005", x"00000007", x"0000000C", "add basic");
        check(OP_ADD,  x"FFFFFFFF", x"00000001", x"00000000", "add wraparound");
        check(OP_SUB,  x"0000000A", x"00000003", x"00000007", "sub basic");
        check(OP_SUB,  x"00000003", x"0000000A", x"FFFFFFF9", "sub negative");
        check(OP_SUB,  x"12345678", x"12345678", x"00000000", "sub equal (zero)");

        -- Logic
        check(OP_AND,  x"F0F0F0F0", x"FF00FF00", x"F000F000", "and");
        check(OP_OR,   x"F0F0F0F0", x"0F0F0F0F", x"FFFFFFFF", "or");
        check(OP_XOR,  x"FFFF0000", x"FF00FF00", x"00FFFF00", "xor");

        -- Shifts
        check(OP_SLL,  x"00000001", x"00000004", x"00000010", "sll");
        check(OP_SLL,  x"00000001", x"00000021", x"00000002", "sll uses low 5 bits only");
        check(OP_SRL,  x"80000000", x"00000004", x"08000000", "srl zero fill");
        check(OP_SRA,  x"80000000", x"00000004", x"F8000000", "sra sign fill");
        check(OP_SRA,  x"40000000", x"00000004", x"04000000", "sra positive");

        -- Comparisons
        check(OP_SLT,  x"FFFFFFFF", x"00000001", x"00000001", "slt -1 < 1");
        check(OP_SLT,  x"00000001", x"FFFFFFFF", x"00000000", "slt 1 < -1");
        check(OP_SLTU, x"FFFFFFFF", x"00000001", x"00000000", "sltu max < 1");
        check(OP_SLTU, x"00000001", x"FFFFFFFF", x"00000001", "sltu 1 < max");

        if errors = 0 then
            report "ALL ALU TESTS PASSED";
        else
            report integer'image(errors) & " ALU TEST(S) FAILED" severity error;
        end if;
        finish;
    end process;
end architecture;