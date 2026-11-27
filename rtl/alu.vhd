library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a      : in  std_logic_vector(31 downto 0);
        b      : in  std_logic_vector(31 downto 0);
        alu_op : in  std_logic_vector(3 downto 0);  
        result : out std_logic_vector(31 downto 0);
        zero   : out std_logic                       
    );
end entity;

architecture rtl of alu is
begin
    process (all)
        variable res   : std_logic_vector(31 downto 0);
        variable shamt : natural range 0 to 31;
    begin
        shamt := to_integer(unsigned(b(4 downto 0)));  -- RISC-V uses only 5 bits
        res   := (others => '0');

        case alu_op is
            when "0000" => res := std_logic_vector(unsigned(a) + unsigned(b));            -- ADD
            when "1000" => res := std_logic_vector(unsigned(a) - unsigned(b));            -- SUB
            when "0001" => res := std_logic_vector(shift_left(unsigned(a), shamt));       -- SLL
            when "0010" =>                                                                -- SLT
                if signed(a) < signed(b) then res(0) := '1'; end if;
            when "0011" =>                                                                -- SLTU
                if unsigned(a) < unsigned(b) then res(0) := '1'; end if;
            when "0100" => res := a xor b;                                                -- XOR
            when "0101" => res := std_logic_vector(shift_right(unsigned(a), shamt));      -- SRL
            when "1101" => res := std_logic_vector(shift_right(signed(a), shamt));        -- SRA
            when "0110" => res := a or b;                                                 -- OR
            when "0111" => res := a and b;                                                -- AND
            when others => res := (others => '0');
        end case;

        result <= res;
        if res = x"00000000" then zero <= '1'; else zero <= '0'; end if;
    end process;
end architecture;