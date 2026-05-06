library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_top is
    port (
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;                      
        sw: in std_logic_vector(3 downto 0);  
        pwm_out : out std_logic_vector(15 downto 0)
    );
end entity pwm_top;

architecture Behavioral of pwm_top is

    signal sig_ce : std_logic;
    signal sig_ce_brightness : std_logic;        

    signal sig_cnt_pwm : std_logic_vector(7 downto 0);
    signal sig_cnt_brightness : std_logic_vector(8 downto 0);
    signal sig_brightness_adj : std_logic_vector(7 downto 0);
    signal sig_rst_inv : std_logic;

begin

    sig_rst_inv <= rst;

    clk_en_inst : entity work.clk_en
        generic map (
            G_MAX => 100000
        )
        port map (
            clk => clk,
            rst => sig_rst_inv,
            ce  => sig_ce
        );


    speed_ctrl_inst : entity work.speed_ctrl
        port map (
            clk    => clk,
            rst    => sig_rst_inv,
            ce_in  => sig_ce,
            sw     => sw,
            ce_out => sig_ce_brightness
        );


   
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

    brightness_cnt_inst : entity work.counter
        generic map (
            G_BITS => 9
        )
        port map (
            clk => clk,
            rst => sig_rst_inv,
            en  => sig_ce_brightness,
            cnt => sig_cnt_brightness
        );

    sig_brightness_adj <= sig_cnt_brightness(7 downto 0) when sig_cnt_brightness(8) = '0' else not sig_cnt_brightness(7 downto 0);

    process(clk)
    begin
        if rising_edge(clk) then
            if sig_rst_inv = '1' then
                pwm_out <= (others => '0');
            else
                if (unsigned(sig_cnt_pwm) < unsigned(sig_brightness_adj)) and (en = '1') then
                    pwm_out <= (others => '1');
                else
                    pwm_out <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;
