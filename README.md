# **PROJEKT PWM BREATHING LED**

Cílem projektu je implementace digitálního systému pro plynulé řízení jasu všech 16 LED diod na desce Nexys A7-50T. Jas diod se periodicky mění (lineární nárůst a pokles), čímž simuluje efekt „dýchání".

Princip Pulzně-šířkové modulace (PWM): Základem řízení jasu u digitálních systémů je PWM. Protože digitální pin umí pouze logickou 0 (0 V) nebo logickou 1 (3.3 V), nemůžeme napětí měnit spojitě. Jas tedy simulujeme poměrem času, po který je dioda zapnutá ($T_{ON}$), k celkové periodě signálu ($T_{PERIOD}$). 

Střída (Duty Cycle): Definována jako $D = \frac{T_{ON}}{T_{PERIOD}} \cdot 100\,\%$. 

Frekvence: Musí být dostatečně vysoká ($> 100\text{ Hz}$), aby oko díky své setrvačnosti vyhladilo blikání do konstantního jasu. V našem projektu cílíme na řádově jednotky kHz.

## **Členové týmu:**

- Robin Klapetek
- Pavel Korec

## **Schéma**

**![](images/schema1.png
)**

## **Základní parametry**

### **I/O Ports**

| Port | Směr | Typ | Šířka | Popis |
| :--- | :---: | :---: | :---: | :--- |
| **clk** | in | std_logic | 1 bit | Hlavní hodinový signál desky (100 MHz). |
| **rst** | in | std_logic | 1 bit | Reset systému (na desce Nexys A7 Active-Low). |
| **en** | in | std_logic | 1 bit | Povolovací signál (Switch), aktivuje efekt dýchání. |
| **pwm_out** | out | std_logic_vector | 16 bitů | Výstupní sběrnice připojená k 16 LED diodám. |

### **Vnitřní moduly a logika systému**

| Modul / Komponenta | Parametry (Generics) | Funkce a detailní popis |
| :--- | :---: | :--- |
| **clk_en_inst** | `G_MAX = 500 000` | **Dělička frekvence.** Z hlavních 100 MHz generuje povolovací pulz `sig_ce` každých 5 ms (200 Hz). Určuje rychlost plynulé změny jasu. |
| **pwm_cnt_inst** | `G_BITS = 8` | **PWM čítač.** Rychlý čítač běžící na 100 MHz. Počítá v rozsahu 0 až 255 a vytváří digitální pilovitý průběh pro PWM modulaci. |
| **brightness_cnt_inst** | `G_BITS = 9` | **Čítač jasu.** Inkrementuje se pouze při aktivním `sig_ce`. Celkový rozsah 0 až 511 definuje jednu kompletní periodu "dýchání". |
| **Inhale/Exhale Logic** | — | **Logika směru.** Využívá MSB (`bit 8`) čítače jasu. Pokud je `0`, jas roste (0–255). Pokud je `1`, spodních 8 bitů se neguje, čímž jas plynule klesá (255–0). |
| **PWM Comparator** | — | **Komparátor.** Porovnává okamžitou hodnotu `pwm_cnt` s upravenou hodnotou jasu. Generuje signál `1`, pokud je čítač menší než jas a je aktivní vstup `en`. |
| **Output Register** | — | **Sekvenční výstup (D-FF).** 16bitový registr synchronizovaný na `clk`. Stabilizuje výstupní signál a eliminuje hazardní stavy (glitche) na LED diodách. |

## **Časování a ostatní parametry:**
**1. Systémové signály**:
- **Hodiny (clk):** 100 MHz (perioda 10 ns)
- **Reset (rst):** Active-Low - v top levelu invertován na `sig_rst_inv`

**2. Parametry PWM modulace:**
- **Rozlišení:** 8 bitů (256 úrovní střídy)
- **Frekvence PWM:** cca 390,6 kHz ($100\ \text{MHz}/256$) - zamezuje viditelnému blikání.

**3. Parametry dýchání:**
- **Řízení směru:** 9bitový čítač (0-511), 9. bit (MSB) určuje směr (0 - jas roste, 1 - jas klesá).
- **Rychlost krokování:** Dělička frekvence (`G_MAX` = 500 000) generuje povolovací pulz s frekvencí 200 Hz.
- **Délka cyklu:** Kompletní cyklus trvá 2,56 sekundy (1,28 s rozsvěcování, 1,28 s zhasínání).

## **Simulace**

**![](images/sim1.png)** 

Na prvním snímku je zachycen detailní průběh na začátku simulace. Klíčový je zde vztah mezi systémovými hodinami s_clk (100 MHz) a povolovacím signálem sig_ce (Clock Enable). Je vidět, že sig_ce generuje krátké pulzy, které určují rychlost změny jasu. Výstup s_pwm_out zatím zůstává v nule, protože vnitřní čítač PWM ještě nepřekonal nastavenou hladinu jasu. Při bližším zkoumání je patrné, střída signálu (Duty Cycle) na sběrnici s_pwm_out se mění v závislosti na vnitřním čítači, který porovnává svou hodnotu s prahovou úrovní. Simulace potvrzuje, že signál sig_ce efektivně škáluje časovou doménu projektu, což umožňuje plynulý přechod mezi jednotlivými úrovněmi jasu bez viditelného blikání nebo skokových změn, které by mohly nastat při nesprávné synchronizaci procesů.

**![](images/sim2.png)**

Zde je zobrazen princip PWM modulace v detailu. Horní sběrnice s_pwm_out[15:0] ukazuje stav všech 16 LED. Je vidět, že šířka logické jedničky (střída) se mění v závislosti na tom, jak vnitřní čítač PWM (sig_cnt_pwm) porovnává svou hodnotu s aktuálním registrem jasu. Čím je hodnota jasu vyšší, tím déle zůstává výstup v jedničce a lidskému oku se zdá, že LED svítí intenzivněji. Šířka pulzů se mění dynamicky, což demonstruje správnou funkci generátoru trojúhelníkového průběhu. Tento přístup eliminuje prudké skoky v intenzitě osvětlení při přechodu z maximálního jasu zpět do útlumu. Stabilita signálů napříč všemi 16 kanály sběrnice s_pwm_out potvrzuje, že nedochází k žádnému fázovému posuvu mezi jednotlivými LED diodami, což zajišťuje vizuálně uniformní efekt dýchání v celém poli výstupů.

**![](images/sim3.png)**

Tento snímek zachycuje delší časový úsek (jednotky milisekund), který ukazuje dynamiku „dýchání“. PWM pulzy jsou zde vidět jako husté bloky, které se plynule rozšiřují. Tento pohled potvrzuje, že modulace neprobíhá skokově, ale plynule, což je zásadní pro vizuální efekt lineárního nárůstu jasu na všech 16 výstupech současně. Tento test potvrzuje, že zvolená frekvence PWM a rychlost inkrementace čítače jasu jsou v souladu, což eliminuje jakékoli viditelné blikání a zajišťuje plynulý přechod i v kritických oblastech kolem minimálního a maximálního jasu. Simulace detailně zobrazuje moment inverze, kdy systém plynule přechází z fáze nárůstu do fáze poklesu.

**![](images/sim4.png)**

Snímek ukazuje logiku přechodu mezi „nádechem“ a „výdechem“. Sledujeme zde 9bitový čítač jasu, kde jeho nejvyšší bit (MSB) slouží jako přepínač směru. V momentě, kdy MSB změní stav, začne se hodnota jasu díky použitému multiplexoru a invertoru v kódu snižovat. Tím je realizován trojúhelníkový průběh jasu bez nutnosti složitých výpočtů. Využití MSB (nejvýznamnějšího bitu) jako přepínače směru čítání je efektivním řešením, které šetří hardwarové prostředky. Simulace detailně zobrazuje moment inverze, kdy systém plynule přechází z fáze nárůstu do fáze poklesu.

**![](images/sim5.png)**

Poslední detail potvrzuje stabilitu výstupu. Všechny změny na výstupní sběrnici s_pwm_out jsou synchronizovány s náběžnou hranou hodin s_clk. Díky implementaci výstupního registru (D-FF) je eliminováno riziko vzniku hazardních stavů (glitchů), které by mohly nastat při souběhu změn v kombinační logice komparátoru a čítačů.

### **Odkaz na testbench**
**[Zobrazit testbench](PWM_Breathing_LED/pwm.srcs/sim_1/new/tb_pwm_top.vhd)**

### **Resource Report**

| Resource | Estimation | Available | Utilization [%] |
| :--- | :---: | :---: | :---: |
| **LUT (Logic)** | 22 | 32 600 | 0.07 |
| **FF (Registers)** | 21 | 65 200 | 0.03 |
| **IO (Pins)** | 19 | 210 | 9.05 |
| **BUFG** | 1 | 32 | 3.13 |

## **Git Flow**
Vývoj projektu probíhal formou týmové spolupráce. I když je většina commitů provedena z jednoho účtu, veškeré úpravy kódu, návrh architektury a ladění simulací byly prováděny oběma členy týmu současně (50/50).

## **Ostatní výstupy**
* **TOP level VHDL:** [Zobrazit pwm_top.vhd](PWM_Breathing_LED/pwm.srcs/sources_1/new/pwm_top.vhd)
* **Video ukázka:** [Video bude doplněno po natočení]
* **Poster:** [Obrázek posteru bude doplněn po vytvoření]
* **Seznam použitých nástrojů:**
    * **Vivado 2025.2 (VHDL)** (Návrh, syntéza, simulace)
    * **GitHub** (Verzování kódu)
    * **ProfiCAD** (Tvorba blokového schématu)
* **Reference:**
