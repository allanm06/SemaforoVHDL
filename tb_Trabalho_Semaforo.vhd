library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_Trabalho_Semaforo is
end tb_Trabalho_Semaforo;

architecture teste of tb_Trabalho_Semaforo is

    component Trabalho_Semaforo
        generic (clockFreq : integer := 50e6);
        port (
            clk : in std_logic;
            reset_contador : in std_logic;
            alterar_trafego : in std_logic;
            w : out integer;
            TEMP_BASE_RED : in integer ;
            TEMP_BASE_YELLOW : in integer ;
            TEMP_BASE_GREEN : in integer ;
            semaforo_1 : out std_logic_vector(2 downto 0);
            pedestre_1 : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Sinais da máquina
    signal clk : std_logic := '1';
    signal reset_contador : std_logic := '0';
    signal alterar_trafego : std_logic := '0';
    signal semaforo_1 : std_logic_vector(2 downto 0) := "100";
    signal pedestre_1 : std_logic_vector(2 downto 0) := "001";
    signal TEMP_BASE_RED : integer := 6;
    signal TEMP_BASE_YELLOW : integer := 3;
    signal TEMP_BASE_GREEN : integer := 5;
    signal data_output : integer := 0;
    signal previous_semaforo : std_logic_vector(2 downto 0) := "100";
    signal previous_pedestre : std_logic_vector(2 downto 0) := "001";
    signal flag_write : std_logic := '0';
    file data_input_file : text open read_mode is "EntradaSemaforo.txt";
    file data_output_file : text open write_mode is "SaidaSemaforo.txt";
    constant PERIOD : time := 20 ns;
	 
    -- Função para converter valor do semáforo em string (necessário para o arquivo de saída)
    function std_logic_vector_to_string(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            if slv(i) = '1' then
                result(i + 1 - slv'low) := '1';
            else
                result(i + 1 - slv'low) := '0';
            end if;
        end loop;
        return result;
    end function;

begin

    -- Instanciação do componente Trabalho_Semaforo
    instancia_Trabalho_Semaforo: Trabalho_Semaforo 
        generic map(
            clockFreq => 50e6
        )
        port map(
            w => data_output, 
            clk => clk,
            alterar_trafego => alterar_trafego,
            semaforo_1 => semaforo_1, 
            pedestre_1 => pedestre_1, 
            reset_contador => reset_contador,
            TEMP_BASE_RED => TEMP_BASE_RED,
            TEMP_BASE_YELLOW => TEMP_BASE_YELLOW,
            TEMP_BASE_GREEN => TEMP_BASE_GREEN
        );
		  

    -- Processo para gerar o clock
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for PERIOD / 2;
            clk <= '1';
            wait for PERIOD / 2;
        end loop;
    end process;
	 
    -- Processo de leitura dos tempos de estado
    leitura : process
        variable linea : line;
        variable l_name : string(1 to 15);
        variable l_value : integer;
    begin
        while not endfile(data_input_file) loop
            readline(data_input_file, linea);
            read(linea, l_name);
            read(linea, l_value);
            
            -- Verifica o nome da variável e atribui o valor correspondente
            if l_name = "RedCar_GreenPed" then
                TEMP_BASE_RED <= l_value;
                wait for PERIOD;
					 
            elsif l_name = "AlertaSom_ToPed" then
                TEMP_BASE_YELLOW <= l_value;
                wait for PERIOD;
					 
            elsif l_name = "GreenCar_RedPed" then
                TEMP_BASE_GREEN <= l_value;
                wait for PERIOD;
					 
            else
                -- Tratamento de erro se o nome da variável não for reconhecido
                report "Nome da variável não reconhecido" severity error;
            end if;
				
            wait for PERIOD;
             -- Adiciona um pequeno atraso para evitar loop infinito
        end loop;
        file_close(data_input_file);
        wait;
    end process;

    -- Processo de estímulo
    stimulus_process: process
    begin
        -- Estímulos de exemplo, ajuste conforme necessário
--        wait for PERIOD * 35;
--        alterar_trafego <= '1';
--        wait for PERIOD; 
--        alterar_trafego <= '0';
--        wait for PERIOD * 77;
--        alterar_trafego <= '1';
--        wait for PERIOD; 
--        alterar_trafego <= '0';
        wait;
    end process stimulus_process;
	 
    -- Processo que armazena e compara os estados anterior e atual dos semáforos
    monitor_semaforo: process(clk)
    begin
        if rising_edge(clk) then
            if semaforo_1 /= previous_semaforo or pedestre_1 /= previous_pedestre then
                previous_semaforo <= semaforo_1;
                previous_pedestre <= pedestre_1;
                flag_write <= '1';
            else
                flag_write <= '0';
            end if;
        end if;
    end process monitor_semaforo;
	 
    -- Processo para escrever no arquivo de saída
    write_outputs : process(clk)
        variable linea : line;
    begin
        if rising_edge(clk) then
            if flag_write = '1' then
                write(linea, string'("Tempo: ") & integer'image(now / 1 ns) & string'(" ns, Transição para -> Carros: ") & std_logic_vector_to_string(semaforo_1) & string'(", Pedestres: ") & std_logic_vector_to_string(pedestre_1));
                writeline(data_output_file, linea);
            end if;
        end if;
    end process write_outputs;

end teste;
