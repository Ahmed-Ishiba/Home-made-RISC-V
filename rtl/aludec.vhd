library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity aludec is
    port (
        opb5: in  STD_LOGIC;
        funct3: in  STD_LOGIC_VECTOR(2 downto 0);
        funct7b5: in  STD_LOGIC;
        ALUOp: in  STD_LOGIC_VECTOR(1 downto 0);
        ALUControl: out STD_LOGIC_VECTOR(3 downto 0)
    );
end;

architecture behave of aludec is
begin
    process(opb5, funct3, funct7b5, ALUOp)
    begin
        case ALUOp is
            when "00" => ALUControl <= "0000";   -- lw/sw: add
            when "01" => ALUControl <= "1000";   -- beq: sub
            when others =>
                ALUControl <= '0' & funct3;      -- default: funct3 selects the op
                case funct3 is
                    when "000" =>                -- ADD/SUB (addi never subtracts)
                        if funct7b5 = '1' and opb5 = '1' then
                            ALUControl <= "1000";
                        end if;
                    when "101" =>                -- SRL/SRA, SRLI/SRAI
                        if funct7b5 = '1' then
                            ALUControl <= "1101";
                        end if;
                    when others => null;
                end case;
        end case;
    end process;
end;