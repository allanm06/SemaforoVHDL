library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity Trabalho_Semaforo is
    generic (clockFreq : integer := 50e6); -- clock DE10 Lite = 50 MHz
    port (
        clk : in std_logic;
        reset_contador : in std_logic := '0';
		  alterar_trafego : in std_logic := '0';
        w : out integer := 0;
		  TEMP_BASE_RED :  integer ; --tempos de estado em segundos
		  TEMP_BASE_YELLOW :  integer ;
		  TEMP_BASE_GREEN :  integer ;
        semaforo_1 : out std_logic_vector(2 downto 0) := "000" ;
        pedestre_1 : out std_logic_vector(2 downto 0) := "000"
    );
end Trabalho_Semaforo;

architecture main of Trabalho_Semaforo is

    type state is (s0, s1, s2, s3);
    signal atual, proximo : state;

    signal ticks : integer range 0 to clockFreq := 0; -- Conta ciclo de 1 segundo
    signal contador : integer := 0;

    signal hz : integer := 50000;

    signal temp_1 : std_logic := '0';
    signal temp_2 : std_logic := '0';
    signal temp_3 : std_logic := '0';
    signal temp_4 : std_logic := '0'; 
	 
	 --constant TEMP_BASE_RED :  integer := 7; --tempos de estado em segundos
	 --constant TEMP_BASE_YELLOW :  integer := 5;
	 --constant TEMP_BASE_GREEN :  integer := 7;
	 

begin

-----------------------contador----------------------------
process (clk)
begin
    if (rising_edge(clk)) then
        if (reset_contador = '1') then
            contador <= 0;
            ticks <= 0;
				w <= 0;
        elsif (ticks = 50 - 1) then
            ticks <= 0;
            contador <= contador + 1;
        else
            ticks <= ticks + 1;
        end if;

        -- Verifica os estados baseados no valor do contador
        if (contador = (TEMP_BASE_RED)) then 
            temp_1 <= '1'; -- vermelho
            temp_2 <= '0';
            temp_3 <= '0';
            temp_4 <= '0';
        elsif (contador = (TEMP_BASE_RED + TEMP_BASE_YELLOW)) then 
            temp_1 <= '0';
            temp_2 <= '1'; -- amarelo
            temp_3 <= '0';
            temp_4 <= '0';
        elsif (contador = (TEMP_BASE_RED + TEMP_BASE_YELLOW + TEMP_BASE_GREEN)) then 
            temp_1 <= '0';
            temp_2 <= '0';
            temp_3 <= '1'; -- verde
            temp_4 <= '0';
        elsif (contador = (TEMP_BASE_RED + TEMP_BASE_YELLOW + TEMP_BASE_GREEN + TEMP_BASE_YELLOW)) then 
            temp_1 <= '0';
            temp_2 <= '0';
            temp_3 <= '0';
            temp_4 <= '1'; -- amarelo
            ticks <= 0;
				contador <= 0;
        end if;
        
        -- Output the current count
        w <= contador;
    end if;
end process;
-----------------------------------------------------------

----------------------- MAQUINA DE ESTADO --------------------------

process(clk)
begin
    if(rising_edge(clk)) then
		if (alterar_trafego = '1') then
          case atual is
             when s0 => atual <= s1;
             when s1 => atual <= s2;
             when s2 => atual <= s3;
             when s3 => atual <= s0;
          end case;
        else
		  
        case atual is
            when s0 => 
                if(temp_1 = '1') then
                    atual <= s1;
                else
                    atual <= s0;
                end if;
            
            when s1 => 
                if(temp_2 = '1') then
                    atual <= s2;
                else
                    atual <= s1;
                end if;
            
            when s2 => 
                if(temp_3 = '1') then
                    atual <= s3;
                else
                    atual <= s2;
                end if;
            
            when s3 => 
                if(temp_4 = '1') then
                    atual <= s0;
                else
                    atual <= s3;
                end if;
            
        end case;
    end if;
	end if;
end process;

------------------------------------------------------

-------------ATRIBUIÇÕES NA MAQUINA DE ESTADO -------------------------

process(clk, atual)
begin
    if(rising_edge(clk)) then
        case atual is 
            when s0 => 
                semaforo_1 <=  "100"; --vermelho carros
                pedestre_1 <= "001";--verde pedestres
            
            when s1 => 
                semaforo_1 <=  "100";--red
                pedestre_1 <= "011"; --sinal sonoro pra fechar
            
            when s2 => 
                semaforo_1 <=  "001";--verde carros
                pedestre_1 <= "100";--vermelho pedestres
            
            when s3 => 
                semaforo_1 <=  "010"; --amarelo carros
                pedestre_1 <= "100";--verde pedestres
        end case;
    end if;
end process;
----------------------------------------------------------

end main;