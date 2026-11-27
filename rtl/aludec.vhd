library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity aludec is
    port (
        opb5: in  STD_LOGIC;
        funct3: in  STD_LOGIC_VECTOR(2 downto 0);
        funct7b5: in  STD_LOGIC;
        ALUOp: in  STD_LOGIC_VECTOR(1 downto 0);
        ALUControl: out STD_LOGIC_VECTOR(2 downto 0)
    );
end;

architecture behave of aludec is

    signal RtypeSub : STD_LOGIC;

begin

    -- TRUE for R-type subtract
    RtypeSub <= funct7b5 and opb5;

    process(opb5, funct3, funct7b5, ALUOp, RtypeSub)
    begin
        case ALUOp is
            when "00" =>
                ALUControl <= "000";  -- Addition
            when "01" =>
                ALUControl <= "001";  -- Subtraction
            when others =>
                case funct3 is
                    when "000" =>
                        if RtypeSub = '1' then
                            ALUControl <= "001";  -- SUB
                        else
                            ALUControl <= "000";  -- ADD, ADDI
                        end if;
                    when "010" =>
                        ALUControl <= "101";  -- SLT, SLTI
                    when "110" =>
                        ALUControl <= "011";  -- OR, ORI
                    when "111" =>
                        ALUControl <= "010";  -- AND, ANDI
                    when others =>
                        ALUControl <= "---";  -- Unknown
                end case;
        end case;
    end process;
end;