library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity pwm_top is
    port (
        clk     : in  std_logic; -- 100 MHz
        rst     : in  std_logic; -- Tlačítko (Active Low)
        en      : in  std_logic; -- Přepínač
        pwm_out : out std_logic_vector(15 downto 0)  
    );
end entity pwm_top;

architecture Behavioral of pwm_top is

    -- Vnitřní signály
    signal sig_ce           : std_logic;
    signal sig_cnt_pwm      : std_logic_vector(7 downto 0); -- 8 bitů (0 až 255)
    signal sig_cnt_jas      : std_logic_vector(8 downto 0); -- 9 bitů (0 až 511)
    signal sig_jas_upraveny : std_logic_vector(7 downto 0);
    
    
    signal sig_rst_inv      : std_logic; -- Signál pro otočený reset
    signal sig_pwm_single   : std_logic; -- Pomocný signál pro PWM

begin

    
    sig_rst_inv <= not rst;

    -- 1. Instance děličky hodin 
    clk_en_inst : entity work.clk_en
        generic map (
            G_MAX => 500000 -- zpomaleni pro dychani¨, simulace 5, implementace 500000
        )
        port map (
            clk => clk,
            rst => sig_rst_inv, 
            ce  => sig_ce
        );

    -- 2. Instance rychlého čítače 
    pwm_cnt_inst : entity work.counter
        generic map (
            G_BITS => 8 
        )
        port map (
            clk => clk,
            rst => sig_rst_inv, 
            en  => '1', 
            cnt => sig_cnt_pwm
        );

    -- 3. instance pomalyho citace
    jas_cnt_inst : entity work.counter
        generic map (
            G_BITS => 9 
        )
        port map (
            clk => clk,
            rst => sig_rst_inv, 
            en  => sig_ce, -- Zpomaleno 
            cnt => sig_cnt_jas
        );

    -- 4. nádech a výdech
    -- Pokud je bit 8 '0', jas roste. Pokud '1', bity se negují a jas klesá.
    sig_jas_upraveny <= sig_cnt_jas(7 downto 0) when sig_cnt_jas(8) = '0' else not sig_cnt_jas(7 downto 0);

    -- 5. komparátor
    -- uklada se do pomocnyho signalu
    sig_pwm_single <= '1' when (unsigned(sig_cnt_pwm) < unsigned(sig_jas_upraveny)) and (en = '1') else '0';

    -- 6. Výstup na všech 16 LED
    pwm_out <= (others => sig_pwm_single);

end architecture Behavioral;
