# **PROJEKT PWM BREATHING LED**

Cílem projektu je implementace digitálního systému pro plynulé řízení jasu všech 16 LED diod na desce Nexys A7-50T. Jas diod se periodicky mění (lineární nárůst a pokles), čímž simuluje efekt „dýchání".

Princip spočívá v rychlém přepínání LED pomocí pulzně-šířkové modulace (PWM). Střída signálu (duty) se plynule mění, přičemž frekvence blikání je vysoká tak, aby lidské oko vnímalo pouze změnu intenzity světla, nikoliv samotné blikání.

## **Členové týmu:**

- Robin Klapetek
- Pavel Korec

## **Schéma**

**![](images/schema1.png
)**

## **Základní parametry**

### **I/O Ports**

| Port | Směr | Šířka | Popis |
| :--- | :---: | :---: | :--- |
| **clk** | in | 1 bit | Hlavní hodinový signál desky (100 MHz). |
| **rst** | in | 1 bit | Reset systému (na desce Nexys A7 Active-Low). |
| **en** | in | 1 bit | Povolovací signál (Switch), aktivuje efekt dýchání. |
| **pwm_out** | out | 16 bitů | Výstupní sběrnice připojená k 16 LED diodám. |

### **Vnitřní moduly a logika systému**

| Modul / Komponenta | Funkce a popis |
| :--- | :--- |
| **clk_en_inst** | Dělička frekvence (Clock Enable). Z 100 MHz generuje pulzy pro krokování jasu. Parametr `G_MAX = 500 000`. |
| **pwm_cnt_inst** | Rychlý 8bitový čítač. Běží na plné frekvenci hodin a tvoří základ pro PWM (pilovitý průběh). |
| **brightness_cnt_inst** | 9bitový čítač jasu. Krokuje pomalu podle signálu `sig_ce` a určuje aktuální intenzitu světla. |
| **Inhale/Exhale Logic** | Využívá 9. bit (MSB) čítače jasu pro určení směru. Provádí inverzi spodních 8 bitů pro efekt „výdechu“. |
| **Output Register** | Synchronní proces (D-FF), který vzorkuje výsledek komparátoru a posílá ho na `pwm_out` s hranou hodin. |

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

Na prvním snímku je zachycen detailní průběh na začátku simulace. Klíčový je zde vztah mezi systémovými hodinami s_clk (100 MHz) a povolovacím signálem sig_ce (Clock Enable). Je vidět, že sig_ce generuje krátké pulzy, které určují rychlost změny jasu. Výstup s_pwm_out zatím zůstává v nule, protože vnitřní čítač PWM ještě nepřekonal nastavenou hladinu jasu.

**![](images/sim2.png)**

Zde je zobrazen princip PWM modulace v detailu. Horní sběrnice s_pwm_out[15:0] ukazuje stav všech 16 LED. Je vidět, že šířka logické jedničky (střída) se mění v závislosti na tom, jak vnitřní čítač PWM (sig_cnt_pwm) porovnává svou hodnotu s aktuálním registrem jasu. Čím je hodnota jasu vyšší, tím déle zůstává výstup v jedničce a lidskému oku se zdá, že LED svítí intenzivněji.

**![](images/sim3.png)**

Tento snímek zachycuje delší časový úsek (jednotky milisekund), který ukazuje dynamiku „dýchání“. PWM pulzy jsou zde vidět jako husté bloky, které se plynule rozšiřují. Tento pohled potvrzuje, že modulace neprobíhá skokově, ale plynule, což je zásadní pro vizuální efekt lineárního nárůstu jasu na všech 16 výstupech současně.

**![](images/sim4.png)**

Snímek ukazuje logiku přechodu mezi „nádechem“ a „výdechem“. Sledujeme zde 9bitový čítač jasu, kde jeho nejvyšší bit (MSB) slouží jako přepínač směru. V momentě, kdy MSB změní stav, začne se hodnota jasu díky použitému multiplexoru a invertoru v kódu snižovat. Tím je realizován trojúhelníkový průběh jasu bez nutnosti složitých výpočtů.

**![](images/sim5.png)**

Poslední detail potvrzuje stabilitu výstupu. Všechny změny na výstupní sběrnici s_pwm_out jsou synchronizovány s náběžnou hranou hodin s_clk. Díky implementaci výstupního registru (D-FF) je eliminováno riziko vzniku hazardních stavů (glitchů), které by mohly nastat při souběhu změn v kombinační logice komparátoru a čítačů.

### **Odkaz na testbench**
**[Zobrazit testbench](PWM_Breathing_LED/pwm.srcs/sim_1/new/tb_pwm_top.vhd)**

## **Resource Report**

**![](images/utilization.png)**
