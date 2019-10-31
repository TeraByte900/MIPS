library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP_LEVEL_I is
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
			 
			 -- MUX_END3 --
			 muxRT_RD        : in std_logic;
			 muxRT_Imediato  : in std_logic;
			 
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

architecture assincrona of TOP_LEVEL_I is

	signal funct: std_logic_vector(5 downto 0);
	signal outMUX_END3 : std_logic_vector(4 downto 0);
	signal outPC: std_logic_vector(addrWidth-1 DOWNTO 0);
	signal outROM, outExtensor, outMUX_BULA, outULA, saidaABanco, saidaBBanco: std_logic_vector (dataWidth-1 DOWNTO 0);

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
	
	MUX_END3 : entity work.MUX2_1
	generic map(
          N => 5
	)
   port map( 
			 A	=> outROM(20 downto 16),
			 B	=> outROM(15 downto 11),
			 Sel => muxRT_RD,
			 Y	=> outMUX_END3
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
          enderecoC => outMUX_END3,
    
          dadoEscritaC => outULA,
    
          escreveC => escreveC,
          saidaA => saidaABanco,
          saidaB => saidaBBanco
   );
	
	Extensor : entity work.extensor_de_sinal
	generic map(
          larguraDados => dataWidth
   )
   port map(
          entrada => outROM(15 downto 0),
			 saida => outExtensor
   );
	
	MUX_BULA : entity work.MUX2_1
	generic map(
          N => dataWidth
	)
   port map( 
			 A	=> saidaBBanco,
			 B	=> outExtensor,
			 Sel => muxRT_Imediato,
			 Y	=> outMUX_BULA
	);
	
	ULA : entity work.ULA_MIPS
	generic map(
		    N => dataWidth
	)
	port map(
			 --- IN ---
			 A => saidaABanco,
			 B => outMUX_BULA,
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