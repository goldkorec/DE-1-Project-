library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm_top is
end entity tb_pwm_top;

architecture testbench of tb_pwm_top is

    constant c_CLK_100MHZ_PERIOD : time := 10 ns;

    signal s_clk     : std_logic;
    signal s_rst     : std_logic;
    signal s_en      : std_logic;
    signal s_pwm_out : std_logic_vector(15 downto 0);

begin

    uut_pwm_top : entity work.pwm_top
        port map (
            clk     => s_clk,
            rst     => s_rst,
            en      => s_en,
            pwm_out => s_pwm_out
        );


    p_clk_gen : process
    begin
        while now < 10 ms loop
            s_clk <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;
    end process p_clk_gen;


    p_stimulus : process
    begin
        report "Simulation start..." severity note;

       
        s_en  <= '0';
        s_rst <= '0';
        wait for 50 ns;

       
        s_rst <= '1';
        wait for 100 ns;

       
        s_en  <= '1';
       
       
        wait for 2 ms;

       
        s_rst <= '0';
        wait for 50 ns;
        s_rst <= '1';
       
        wait for 1 ms;


        wait;
    end process p_stimulus;

end architecture testbench;
