library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm_top is
end entity tb_pwm_top;

architecture testbench of tb_pwm_top is

    constant c_CLK_100MHZ_PERIOD : time := 10 ns;

    signal s_clk     : std_logic;
    signal s_rst     : std_logic;
    signal s_en      : std_logic;
    signal s_sw      : std_logic_vector(3 downto 0); 
    signal s_pwm_out : std_logic_vector(15 downto 0);

begin

uut_pwm_top : entity work.pwm_top
        port map (
            clk     => s_clk,
            rst     => s_rst,
            en      => s_en,
            sw      => s_sw,         
            pwm_out => s_pwm_out
        );


    p_clk_gen : process
    begin
        while now < 20 ms loop       
            s_clk <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;
    end process p_clk_gen;


    p_stimulus : process
    begin
        

     
        s_en  <= '0';
        s_rst <= '0';
        s_sw  <= "0000";
        wait for 50 ns;

       
        s_rst <= '1';
        wait for 100 ns;

     
        s_en  <= '1';
       
     
        wait for 3 ms;

   
        report "Test rychlosti: SW 0" severity note;
        s_sw <= "0001";
        wait for 3 ms;

   
        report "Test rychlosti: SW 1" severity note;
        s_sw <= "0010";
        wait for 3 ms;

        
        report "Test rychlosti: SW 2" severity note;
        s_sw <= "0100";
        wait for 3 ms;
       

        s_rst <= '0';
        wait for 50 ns;
        s_rst <= '1';
       
     
        report "Test rychlosti: SW 3" severity note;
        s_sw <= "1000";
        wait for 3 ms;

        report "Simulation end." severity note;
        wait;
    end process p_stimulus;

end architecture testbench;
