library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm_top is
end entity tb_pwm_top;

architecture testbench of tb_pwm_top is

    constant c_CLK_100MHZ_PERIOD : time := 10 ns;

    signal s_clk     : std_logic;
    signal s_rst     : std_logic;
    signal s_en      : std_logic;
    signal s_pwm_out : std_logic_vector(15 downto 0); -- ZMĚNA NA VEKTOR

begin

    uut_pwm_top : entity work.pwm_top
        port map (
            clk     => s_clk,
            rst     => s_rst,
            en      => s_en,
            pwm_out => s_pwm_out
        );

    -- Generování hodin
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

    -- Stimulus proces
    p_stimulus : process
    begin
        report "Zacatek simulace..." severity note;

        -- A. Výchozí stav (Reset na Nexys A7 je Active Low, takže '0' = RESET)
        s_en  <= '0';
        s_rst <= '0'; -- RESET JE AKTIVNÍ
        wait for 50 ns;

        -- B. Uvolníme reset (Nastavíme na '1', jako když tlačítko nedržíme)
        s_rst <= '1'; -- BĚŽNÝ PROVOZ
        wait for 100 ns;

        -- C. Zapneme efekt
        s_en  <= '1';
        
        -- D. Simulace běhu (v simulaci Vivado uvidíš v průběhu waveformy všech 16 bitů stejně)
        wait for 2 ms; 

        -- E. Test resetu za běhu (stiskneme tlačítko -> logická 0)
        s_rst <= '0';
        wait for 50 ns;
        s_rst <= '1';
        
        wait for 1 ms;


        wait;
    end process p_stimulus;

end architecture testbench;