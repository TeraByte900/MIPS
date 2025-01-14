library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP_LEVEL_R is
   generic (
          addrWidth: natural := 32;
			 dataWidth: natural := 32;
			 memoryAddrWidth:  natural := 6;
			 bancoAddrWidth: natural := 5
    );
   port (
			 -- Clock --
			 Clk             : in std_logic;
			 
			 -- PC --
			 enable_pc       : in std_logic;
			 reset_pc        : in std_logic;
			 
			 -- Banco de Registradores --
			 escreveC        : in std_logic;
			 
			 -- ULA --
			 Saida           : out std_logic_vector((dataWidth-1) downto 0);
			 SaidaA1			: out std_logic_vector((dataWidth-1) downto 0);			
			 SaidaB1			: out std_logic_vector((dataWidth-1) downto 0);
			 SaidaROM         : out std_logic_vector((addrWidth-1) downto 0);
			 SaidaFunct : out std_logic_vector(5 downto 0)
    );
end entity;

architecture assincrona of TOP_LEVEL_R is

	signal funct: std_logic_vector(5 downto 0);
	signal outPC: std_logic_vector(addrWidth-1 DOWNTO 0);
	signal outROM, outULA, saidaABanco, saidaBBanco: std_logic_vector (dataWidth-1 DOWNTO 0);

begin

	PC : entity work.PC_MIPS 
	generic map(
          addrWidth => addrWidth
   )
   port map(
			 Clk => Clk,
			 enable_pc => enable_pc,
			 B_somador => x"00000004",
			 reset_pc => reset_pc,
          Addr => outPC
   );

	ROM : entity work.ROM_MIPS 
	generic map(
          dataWidth => dataWidth,
          addrWidth => addrWidth,
          memoryAddrWidth => memoryAddrWidth 
	)
   port map( 
			 clk => Clk,
          Endereco => outPC,
          Dado => outROM
	);

	BANCO : entity work.bancoRegistradores_MIPS 
	generic map(
          larguraDados => dataWidth,
          larguraEndBancoRegs => bancoAddrWidth
   )
   port map(
          clk => Clk,
 
          enderecoA => outROM(25 downto 21),
          enderecoB => outROM(20 downto 16),
          enderecoC => outROM(15 downto 11),
    
          dadoEscritaC => outULA,
    
          escreveC => escreveC,
          saidaA => saidaABanco,
          saidaB => saidaBBanco
   );
	
	ULA : entity work.ULA_MIPS
	generic map(
		    N => dataWidth
	)
	port map(
			 --- IN ---
			 A => saidaABanco,
			 B => saidaBBanco,
			 instrucao => funct,
				
			 --- OUT ---
			 saida => outULA
	);
	
	funct <= outROM(5 downto 0);
	
	SaidaFunct <= funct;
	Saida <= outULA;
	SaidaA1 <= saidaABanco;
	SaidaB1 <= saidaBBanco;
	SaidaROM <= outROM;
	 
end architecture;