    cpu INS8900

; Memory map
; 0000-01FF = ROM
; 0200-02FF = RAM
; FE00-FFFF = UART

    ORG 0
    JMP @tget
tget:
    DW main
    DW 1
    DW 2
    DW 3
    DW 4
    DW 5
    DW 6
    DW 7
ram_addr:
    DW x'0200'
uart_addr:
    DW x'FF00'
tmr_val:
    DW x'FF00'
greet_str_ptr:
    DW greet_str
greet_str:
    DW "Hello World!\r\n\0"
main:
    LI AC2, 0
    LD AC3, ram_addr
    LI AC1, x'7F'
    JSR copy_program ; Copy stuff to RAM
    JMP @sloc
sloc:
    DW x'0200' + now_in_ram
; Magic happens here
now_in_ram:
    SFLG F11 ; Map ROM out
    LD AC2, ram_addr
    LI AC3, 0
    LI AC1, x'7F'
    JSR copy_program ; Copy it back
    ; Prove that we edited it
    LI AC0, "Y"
    ST AC0, @greet_str_ptr
    JMP @sloc2 ; Make sure we go to absolute location
sloc2:
    DW actual_prog

; copy from AC2 to AC3
copy_program:
copyloop:
    LD AC0, 0(AC2)
    ST AC0, 0(AC3)
    AISZ AC2, 1
    NOP
    AISZ AC3, 1
    NOP
    AISZ AC1,-1
    JMP copyloop
    RTS 0

actual_prog:
    LD AC2, uart_addr
    LD AC3, ram_addr
    LD AC0, tmr_val
    SFLG BYTE
init_wait:
    AISZ AC0, 1
    JMP init_wait
uart_init:
    LD AC0, 5(AC2) ; Check LSR contents
    ; Throw away what we read.
    LI AC0, x'83'
    ST AC0, 3(AC2) ; line control reg, DLAB=1
    LI AC0, x'30'
    ST AC0, 0(AC2) ; divisor latch LS
    LI AC0, x'00'
    ST AC0, 1(AC2) ; divisor latch MS, set for 2400 baud
    LI AC0, x'03'  ; Use 8 bits.
    ST AC0, 3(AC2) ; line control reg, DLAB=0

do_again:
    LD AC3, greet_str_ptr
    JSR putstring
    JMP do_again

; AC3 points to string
putstring:
stringloop:
    LD AC0, 0(AC3)
    BOC REQ0, endstring
    JSR putchar
    AISZ AC3, 1
    NOP
    RCPY AC3, AC0 ; Copy AC3 to AC0
    SHR AC0, 2
    PFLG F14
    BOC BIT0, skpled
    SFLG F14
skpled:
    JMP stringloop
endstring:
    RTS 0

; AC0 is character. AC2 is address of UART
putchar:
    ST AC0, 0(AC2) ; transmit holding register
    LD AC1, tmr_val ; timeout
    ; Now wait for transmit to complete
checkloop:
    LD AC0, 5(AC2) ; line status register, check bit 5
    SHR AC0, 5
    BOC BIT0, success ; transmit next byte if ready
    ;AISZ AC1, x'01' ; try again until we time out
    JMP checkloop
    RTS 0; TODO: fail code?
success:
    RTS 0

