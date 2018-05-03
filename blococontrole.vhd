library ieee;
use ieee.std_logic_1164.all;

entity blococontrole is
	port(
		-- sinais de controle de entrada 
		clk, reset: in std_logic;
		-- sinais de dados de entrada
		op: in std_logic_vector(5 downto 0);
		-- sinais de dados de saida
		-- sinais de controle de saida
		LerMem, RegDst, EscMem, EscReg, MemParaReg, 
		ULAFonteA,IouD,IREsc, PCEsc, PCEscCond: out std_logic;
		ULAOp, ULAFonteB, FontePC: out std_logic_vector(1 downto 0)
	);
end entity;

architecture behavior of blococontrole is
	type InternalState is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
	signal next_state, state_reg: InternalState;
	constant tipoR: std_logic_vector(5 downto 0) := "000000";
	constant lw:    std_logic_vector(5 downto 0) := "100011";
	constant sw:    std_logic_vector(5 downto 0) := "101011";
	constant beq:   std_logic_vector(5 downto 0) := "000100";
	constant jump:  std_logic_vector(5 downto 0) := "000010";
begin
	-- next-state logic (combinatorial)
	process(state_reg, op) is
	begin
		next_state <= state_reg;
		case state_reg is
			when S0 =>
				next_state <= S1;
			when S1 =>
				if op=lw or op=sw then
					next_state <= s2;
				elsif op=tipoR then
					next_state <= S6;
				elsif op=beq then
					next_state <= S8;
				elsif op=jump then 
					next_state <= S9;
				else
					next_state <= S0;
				end if;
			when S2 =>
				if op=lw then
					next_state <= S3;
				else
					next_state <= S5;
				end if;
			when S3 => 
				next_state <= S4;
			when S4 => 
				next_state <= S0;
			when S5 =>
				next_state <= S0;
			when S6 =>
				next_state <= S7;
			when S7 => 
				next_state <= S0;
			when S8 =>
				next_state <= S0;
			when S9 =>
				next_state <= S0;
		end case;
	end process;
	
	-- memory element -- internal state
	process(clk, reset)
	begin
		if reset='1' then
			state_reg <= S0;
		elsif rising_edge(clk) then
			state_reg <= next_state;
		end if;
	end process;
	
	-- output-logic (combinatorial)
	with state_reg select
		LerMem <= '1' when S0|S3, '0' when others;
		
	with state_reg select
		EscMem <= '1' when S5, '0' when others;
		
	with state_reg select
		ULAFonteA <=  '1' when S2|S6|S8, '0' when others;
		
	with state_reg select
		IouD <= '1' when S3|S5, '0' when others;
		
	with state_reg select
		IREsc	<= '1' when S0, '0' when others;
		
	with state_reg select
		EscReg <= '1' when S4, '0' when others;
		
	with state_reg select
		RegDst	<= '1' when S7, '0' when others;
		
	with state_reg select
		MemParaReg <= '1' when S4, '0' when others;
		
	with state_reg select
		ULAOp <= "10" when S6, "01" when S8, "00" when others;
		
	with state_reg select
		PCEsc	<= '1' when S0|S9, '0' when others;
		
	with state_reg select
		PCEscCond	<= '1' when S8, '0' when others;
		
	with state_reg select
		ULAFonteB <= "01" when S0, "11" when S1,"10" when S2, "00" when others;
		
	with state_reg select
		FontePC <= "01" when S8, "10" when S9, "00" when others;

end architecture;
