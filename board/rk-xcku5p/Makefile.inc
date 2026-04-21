XILINX_PART ?= xcku5p-ffvb676-2-i

# The user.org:rk_xcku5p_f board definition under board_files/ is informational
# only -- its board.xml does not parse cleanly in Vivado 2023.2 (Board 49-56)
# and there is no complete DDR4 bus interface description. We pin everything
# explicitly via *.xdc instead, so BOARD_PART is set to NONE to skip the
# set_property BOARD_PART call in vivado.tcl.
BOARD_PART  ?= NONE

CFG_DEVICE  ?= SPIx4 -size 64
CFG_PART    ?= mx25u51245g-spi-x1_x2_x4
MEMORY_SIZE ?= 0x80000000
