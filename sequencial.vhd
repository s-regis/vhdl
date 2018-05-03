library ieee;
use ieee.std_logic_1164.all;

entity sequencial is
	port(
		-- sinais controladores na entrada 
		clk, reset: in std_logic;
		-- sinais de dados na entrada
		d: in std_logic;
		-- sinais de dados na saida
		q: out std_logic
	);
end entity;

architecture behavior of sequencial is
	subtype InternalState is (S1,S2,S3);
	signal next_state, state_reg: InternalState;
begin
	-- logica de proximo estado
	next_state <= d;
	
	-- elemento de memoria
	process(clk, reset)
	begin
		if reset='1' then
			state_reg <= '0'; --
		elsif rising_edge(clk) then
			state_reg <= next_state;
		end if;
	end process;
	
	-- logica de saida
	q <= state_reg;
end architecture;
