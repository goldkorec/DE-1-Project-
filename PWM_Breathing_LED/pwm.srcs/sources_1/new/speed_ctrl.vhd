library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity speed_ctrl is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        ce_in  : in  std_logic;
        sw     : in  std_logic_vector(3 downto 0);
        ce_out : out std_logic
    );
end entity speed_ctrl;

architecture Behavioral of speed_ctrl is
    signal cnt : unsigned(3 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt <= (others => '0');
                ce_out <= '0';
            else
                ce_out <= '0';
                if ce_in = '1' then
                    cnt <= cnt + 1;
                   
                 
                    if sw(1) = '1' then
                        ce_out <= '1';
                    elsif sw(0) = '1' then
                        if cnt(0) = '1' then ce_out <= '1'; end if;
                    elsif sw(2) = '1' then
                        if cnt(2 downto 0) = "111" then ce_out <= '1'; end if;
                    elsif sw(3) = '1' then
                        if cnt = "1111" then ce_out <= '1'; end if;
                    else
                        if cnt(1 downto 0) = "11" then ce_out <= '1'; end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture Behavioral;
