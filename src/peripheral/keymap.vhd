--
-- keymap.vhd
--   keymap ROM tables for eseps2.vhd
--   Revision 1.00
--
-- Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- 2013.08.12 modified by KdL
-- Added RWIN and LWIN usable as alternatives to the space-bar.
--
-- 2015.05.20	- Brazilian ABNT2 keymap by Fabio Belavenuto
-- 2016.11		- Implemented Keymap change via software (SWIOPORTS)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keymap is
	port (
		clock_i		: in  std_logic;
		we_i			: in  std_logic;
		addr_wr_i	: in  std_logic_vector(9 downto 0);
		data_i		: in  std_logic_vector(7 downto 0);
		addr_rd_i	: in  std_logic_vector(9 downto 0);
		data_o		: out std_logic_vector(7 downto 0)
	);
end entity;

architecture RTL of keymap is

	signal read_addr_q : unsigned(9 downto 0);
	type ram_t is array (0 to 1023) of std_logic_vector(7 downto 0);
	signal ram_q : ram_t := (
	-- Internacional Key Matrix Table
	--
	--  bit    7 F   6 E   5 D   4 C   3 B   2 A   1 9   0 8
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 0 | 7 & | 6 ^ | 5 % | 4 $ | 3 # | 2 @ | 1 ! | 0 ) |  0
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 1 | ; : | ] } | [ { | \ | | = + | - _ | 9 ( | 8 * |  1
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 2 |  B  |  A  |DEAD | / ? | . > | , < | ` ~ | ' " |  2
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 3 |  J  |  I  |  H  |  G  |  F  |  E  |  D  |  C  |  3
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 4 |  R  |  Q  |  P  |  O  |  N  |  M  |  L  |  K  |  4
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 5 |  Z  |  Y  |  X  |  W  |  V  |  U  |  T  |  S  |  5
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 6 | F3  | F2  | F1  | Code|CapsL|Graph| Ctrl|Shift|  6
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 7 |Enter|Selec| BS  | Stop| Tab | Esc | F5  | F4  |  7
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 8 |Right| Down| Up  | Left| Del | Ins | Home|Space|  8
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 9 | [4] | [3] | [2] | [1] | [0] | [/] | [+] | [*] |  9
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- ROW 10| [.] | [,] | [-] | [9] | [8] | [7] | [6] | [5] |  A
	--       +-----+-----+-----+-----+-----+-----+-----+-----+
	-- bit     7 F   6 E   5 D   4 C   3 B   2 A   1 9   0 8

	-- Falta: CODE, SELECT

	--------------------------------------------
	-- 108 Keys Brazilian keyboard: Shift OFF --
	--------------------------------------------

--              F9            F5     F3     F1     F2     F12
        X"7F", X"87", X"7F", X"17", X"76", X"56", X"66", X"7F", -- 00..07
--              F10    F8     F6     F4     Tab    '/"
        X"7F", X"97", X"F6", X"D6", X"07", X"37", X"02", X"7F", -- 08..0F
--              LAlt  LShft         LCtrl   Q      1/!
        X"7F", X"26", X"06", X"7F", X"16", X"64", X"10", X"7F", -- 10..17
--                     Z      S      A      W      2/@
        X"7F", X"7F", X"75", X"05", X"62", X"45", X"20", X"7F", -- 18..1F
--              C      X      D      E      4/$    3/#
        X"7F", X"03", X"55", X"13", X"23", X"40", X"30", X"7F", -- 20..27
--             Space   V      F      T      R      5/%
        X"7F", X"08", X"35", X"33", X"15", X"74", X"50", X"7F", -- 28..2F
--              N      B      H      G      Y      6/¨
        X"7F", X"34", X"72", X"53", X"43", X"65", X"60", X"7F", -- 30..37
--                     M      J      U      7/&    8/*
        X"7F", X"7F", X"24", X"73", X"25", X"70", X"01", X"7F", -- 38..3F
--              ,/<    K      I      O      0/)    9/(
        X"7F", X"22", X"04", X"63", X"44", X"00", X"11", X"7F", -- 40..47
--              ./>    ;/:    L      Ç      P      -/_
        X"7F", X"32", X"71", X"14", X"03", X"54", X"21", X"7F", -- 48..4F
--              //?    ~/^           ´/`    =/+
        X"7F", X"42", X"92", X"7F", X"D2", X"31", X"7F", X"7F", -- 50..57
--      CapLk  RShft  Enter   [/{           ]/}
        X"36", X"06", X"77", X"51", X"7F", X"61", X"7F", X"7F", -- 58..5F
--              \/|                                BS
        X"7F", X"41", X"7F", X"7F", X"7F", X"7F", X"57", X"3B", -- 60..67
--              [1]           [4]    [7]    [.]
        X"7F", X"49", X"41", X"79", X"2A", X"7A", X"7F", X"7F", -- 68..6F
--       [0]    [,]    [2]    [5]    [6]    [8]    Esc   NLock
        X"39", X"6A", X"59", X"0A", X"1A", X"3A", X"27", X"7F", -- 70..77
--       F11    [+]    [3]    [-]    [*]    [9]   ScrLk
        X"7F", X"19", X"69", X"5A", X"09", X"4A", X"7F", X"7F", -- 78..7F
--                            F7
        X"7F", X"7F", X"7F", X"E6", X"7F", X"7F", X"7F", X"7F", -- 80..87
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 88..8F
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 90..97
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 98..9F
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- A0..A7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- A8..AF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- B0..B7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- B8..BF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- C0..C7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- C8..CF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- D0..D7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- D8..DF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- E0..E7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- E8..EF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- F0..F7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- F8..FF

	-------------------------------------------------
	-- 108 Keys Brazilian keyboard: E0 + Scan Code --
	-------------------------------------------------

--
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 00..07
--
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 08..0F
--             RAlt   PrtSc         RCtrl
        X"7F", X"26", X"7F", X"7F", X"16", X"7F", X"7F", X"7F", -- 10..17
--                                                        LWin
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"08", -- 18..1F  (LWIN = $1F = SPACE)
--                                                        RWin
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"08", -- 20..27  (RWIN = $27 = SPACE)
--                                                        Menu
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"24", -- 28..2F	(MENU = $2F = 'M' key)
--                                                       Power
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 30..37
--                                                       Sleep
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 38..3F
--
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 40..47
--                     [/]
        X"7F", X"7F", X"29", X"7F", X"7F", X"7F", X"7F", X"7F", -- 48..4F
--
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 50..57
--                    [Enter]                      Wake
        X"7F", X"7F", X"77", X"7F", X"7F", X"7F", X"7F", X"7F", -- 58..5F
--
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 60..67
--              End           Left   Home
        X"7F", X"47", X"7F", X"48", X"18", X"7F", X"7F", X"7F", -- 68..6F
--       Ins    Supr   Down         Right   Up
        X"28", X"38", X"68", X"7F", X"78", X"58", X"7F", X"7F", -- 70..77
--                    PDown                 PUp
        X"7F", X"7F", X"46", X"7F", X"7F", X"67", X"7F", X"7F", -- 78..7F
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 80..87
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 88..8F
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 90..97
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- 98..9F
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- A0..A7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- A8..AF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- B0..B7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- B8..BF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- C0..C7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- C8..CF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- D0..D7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- D8..DF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- E0..E7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- E8..EF
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- F0..F7
        X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", X"7F", -- F8..FF

	-------------------------------------------
	-- 108 Keys Brazilian keyboard: Shift ON --
	-------------------------------------------

--              F9            F5     F3     F1     F2
        X"FF", X"FF", X"FF", X"97", X"F6", X"D6", X"E6", X"FF", -- 00..07
--              F10    F8     F6     F4     Tab    '/"
        X"FF", X"FF", X"FF", X"FF", X"87", X"B7", X"82", X"FF", -- 08..0F
--              LAlt  LShft         LCtrl   Q      1/!
        X"FF", X"A6", X"86", X"FF", X"96", X"E4", X"90", X"FF", -- 10..17
--                     Z      S      A      W      2/@
        X"FF", X"FF", X"F5", X"85", X"E2", X"C5", X"A0", X"FF", -- 18..1F
--              C      X      D      E      4/$    3/#
        X"FF", X"83", X"D5", X"93", X"A3", X"C0", X"B0", X"FF", -- 20..27
--             Space   V      F      T      R      5/%
        X"FF", X"88", X"B5", X"B3", X"95", X"F4", X"D0", X"FF", -- 28..2F
--              N      B      H      G      Y      6/¨
        X"FF", X"B4", X"F2", X"D3", X"C3", X"E5", X"FF", X"FF", -- 30..37
--                     M      J      U      7/&    8/*
        X"FF", X"FF", X"A4", X"F3", X"A5", X"F0", X"81", X"FF", -- 38..3F
--              ,/<    K      I      O      0/)    9/(
        X"FF", X"A2", X"84", X"E3", X"C4", X"80", X"91", X"FF", -- 40..47
--              ./>    ;/:    L      Ç      P      -/_
        X"FF", X"B2", X"F1", X"94", X"83", X"D4", X"A1", X"FF", -- 48..4F
--              //?    ~/^           ´/`    =/+
        X"FF", X"C2", X"E0", X"FF", X"52", X"B1", X"FF", X"FF", -- 50..57
--      CapLk  RShft  Enter   [/{           ]/}
        X"B6", X"86", X"F7", X"D1", X"FF", X"E1", X"FF", X"FF", -- 58..5F
--              \/|                                BS
        X"FF", X"C1", X"FF", X"FF", X"FF", X"FF", X"D7", X"BB", -- 60..67
--              [1]           [4]    [7]    [.]
        X"FF", X"C9", X"C1", X"F9", X"AA", X"FA", X"FF", X"FF", -- 68..6F
--       [0]    [,]    [2]    [5]    [6]    [8]    Esc   NLock
        X"B9", X"EA", X"D9", X"8A", X"9A", X"BA", X"A7", X"EA", -- 70..77
--       F11    [+]    [3]    [-]    [*]    [9]   ScrLk
        X"FF", X"99", X"E9", X"DA", X"89", X"BA", X"FF", X"FF", -- 78..7F
--                            F7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 80..87
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 88..8F
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 90..97
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 98..9F
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- A0..A7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- A8..AF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- B0..B7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- B8..BF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- C0..C7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- C8..CF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- D0..D7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- D8..DF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- E0..E7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- E8..EF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- F0..F7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- F8..FF

---------------------------------------------------------
-- 108 Keys Brazilian keyboard: E0 + Scan Code + Shift --
---------------------------------------------------------

--
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 00..07
--
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 08..0F
--             RAlt   PrtSc         RCtrl
        X"FF", X"A6", X"FF", X"FF", X"96", X"FF", X"FF", X"FF", -- 10..17
--                                                        LWin
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"88", -- 18..1F  (LWIN = $1F = SHIFT + SPACE)
--                                                        RWin
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"88", -- 20..27  (RWIN = $27 = SHIFT + SPACE)
--                                                        Menu
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"A4", -- 28..2F	(MENU = $2F = 'M' key)
--                                                       Power
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 30..37
--                                                       Sleep
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 38..3F
--
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 40..47
--                     [/]
        X"FF", X"FF", X"29", X"FF", X"FF", X"FF", X"FF", X"FF", -- 48..4F
--
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 50..57
--                    [Enter]                      Wake
        X"FF", X"FF", X"77", X"FF", X"FF", X"FF", X"FF", X"FF", -- 58..5F
--
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 60..67
--              End           Left   Home
        X"FF", X"C7", X"FF", X"C8", X"98", X"FF", X"FF", X"FF", -- 68..6F
--       Ins    Supr   Down         Right   Up
        X"A8", X"B8", X"E8", X"FF", X"F8", X"D8", X"FF", X"FF", -- 70..77
--                    PDown                 PUp
        X"FF", X"FF", X"C6", X"FF", X"FF", X"E7", X"FF", X"FF", -- 78..7F
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 80..87
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 88..8F
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 90..97
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- 98..9F
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- A0..A7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- A8..AF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- B0..B7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- B8..BF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- C0..C7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- C8..CF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- D0..D7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- D8..DF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- E0..E7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- E8..EF
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", -- F0..F7
        X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF"  -- F8..FF

	);
begin

	process (clock_i)
	begin
		if rising_edge(clock_i) then
			if we_i = '1' then
				ram_q(to_integer(unsigned(addr_wr_i))) <= data_i;
			end if;
			read_addr_q <= unsigned(addr_rd_i);
		end if;
	end process;

	data_o <= ram_q(to_integer(read_addr_q));

end RTL;
