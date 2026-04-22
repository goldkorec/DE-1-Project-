# **PROJEKT PWM BREATHING LED**

Cílem projektu je implementace digitálního systému pro plynulé řízení jasu všech 16 LED diod na desce Nexys A7-50T. Jas diod se periodicky mění (lineární nárůst a pokles), čímž simuluje efekt „dýchání".

Princip spočívá v rychlém přepínání LED pomocí pulzně-šířkové modulace (PWM). Střída signálu (duty) se plynule mění, přičemž frekvence blikání je vysoká tak, aby lidské oko vnímalo pouze změnu intenzity světla, nikoliv samotné blikání.

## **Členové týmu:**

- Robin Klapetek
- Pavel Korec

## **Schéma**

**![](images/schema.png
)**

## **Základní parametry**

- **I/O Porty:**
  - **clk (in)** - Hlavní hodinový signál desky 100MHz
  - **rst (in)** - Asynchronní reset systému.
  - **en (in)** - Switch, povoluje propouštění PWM signálu na výstup
  - **pwm_out (out)** - 16bitová výstupní sběrnice připojená k 16 LED diodám. Všechny bity sběrnice jsou buzeny společným signálem sig_pwm_single (díky tomu LED synchronně svítí a „dýchají")
- **Vnitřní moduly a logika systému:**

- **clk_en_inst (generátor povolovacích pulzů)** - instance modulu clk_en sloužící jako dělička frekvence. Z hlavních 100 MHz generuje pomalé pulzy (clock enable). Frekvence těchto pulzů je dána parametrem G_MAX (určuje jak rychle bude probíhat efekt dýchání).
- **pwm_cnt_inst (rychlý čítač pro PWM)** - první instance modulu counter konfigurovaná jako 8bitový čítač. Tento blok vždy povolen (en => '1') a na plné rychlosti systémových hodin počíta od 0 do 255. Tím na svém výstupu tvoří rychlý digitální pilovitý signál - základ pro pulse width modulation (okem neviditelné blikání při frekvenci cca 390 kHz).
- **jas_cnt_inst (čítač jasu - generování dýchání)** - druhá instance modulu counter, 9 bitů. Tento čítač je taktován pulzy sig_ce, počítá velmi pomalu od 0 do 511. Jeho hodnota reprezentuje jas.

- **Logika nádechu a výdechu** - Směr změny jasu je určen nejvyšším 9. bitem (MSB). Pokud je MSB 0 (1. polovina periody), hodnota spodních 8 bitů se používá přímo a jas roste. Pokud je MSB 1 (2. polovina), spodních 8 bitů se neguje, čímž hodnota začne klesat - jas se snižuje. Výsledek se ukládá do sig_jas_upraveny

- **PWM komparátor** \- tvorba PWM signálu (sig_pwm_single). Porovnává se hodnota rychlého čítače a úrovně jasu. Pokud je hodnota rychlého čítače menší než hodnota upraveného jasu ( unsigned(sig_cnt_pwm) &lt; unsigned(sig_jas_upraveny) ) a zároveň máme zapnutý switch (en =&gt; '1'), je na výstup poslána logická '1'. Tím se automaticky mění šířka pulzu úměřně jasu.

## **Časování a ostatní parametry:**
**1. Systémové signály**:

**Hodiny (clk):** 100 MHz (perioda 10 ns)

**Reset (rst):** Active-Low - v top levelu invertován

**2. Parametry PWM modulace:**

**Rozlišení:** 8 bitů (256 úrovní třídy)

**Frekvence PWM:** cca 390,6 kHz (100MHz/256) - Zamezuje, aby blikání bylo viditelné.

**3. Parametry dýchání:**

**Řízení směru:** 9bitový čítač (0-511, 9. bit (MSB) určuje směr (0 - jas roste, 1 - jas klesá), spodních 8 bitů určuje střídu PWM.

**Rychlost krokování:** Dělička frekvence (G_MAX = 500 000) generuje povolovací pulz s frekvencí 200 Hz - jas se mění o 1 stupeň každých 5 ms.

**Délka cyklu:** Kompletní cyklus trvá 2,56 sekundy z toho 1,28 s - rozsvěcovaní a 1,28 s - zhasínání.

## **Simulace (jeste nedokoncena dokumentace, rozbita kvalita obrazku simulaci bude opravena v CP, došlo k chybě exportu)**

**![](images/sim1.png)** 

Snímek zachycuje detailní průběh signálů v řádu nanosekund. Je zde vidět vztah mezi systémovými hodinami s_clk a aktivačním signálem sig_ce (Clock Enable). Díky němu se jas LED nemění při každém kmitu hodin, ale plynule. Výstupní signál s_pwm_out mění svůj stav v závislosti na vnitřním čítači, který je taktován těmito hodinami.

**![](images/sim2.png)**

Na tomto snímku je vidět princip PWM modulace. Jak se postupně zvyšuje hodnota v registru jasu (sig_jas), prodlužuje se doba, po kterou je výstupní signál v logické jedničce. Tím se mění množství energie, kterou LED dostává. Čím je logická 1 širší, tím déle LED svítí a lidskému oku se zdá, že svítí víc. LED bliká tak rychle, že to lidské oko nepostřehne.

**![](images/sim3.png)**

Tento snímek zachycuje dlouhý časový úsek simulace (v řádu milisekund), který umožňuje sledovat dynamiku celého systému. Jednotlivé PWM pulzy jsou při tomto oddálení vykresleny jako husté bloky, jejichž šířka se plynule mění od minima po maximum. Tato modulace přímo odpovídá plynulému rozsvěcování a zhasínání všech 16 výstupních LED diod (piny pwm_out[0] až [15]).
