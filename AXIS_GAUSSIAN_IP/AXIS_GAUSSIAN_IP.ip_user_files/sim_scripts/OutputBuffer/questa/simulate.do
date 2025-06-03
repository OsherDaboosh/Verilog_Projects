onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib OutputBuffer_opt

do {wave.do}

view wave
view structure
view signals

do {OutputBuffer.udo}

run -all

quit -force
