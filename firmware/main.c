#include "rp2350_playground.h"

int main() {
    static int was_here = 0;

    if (was_here == 0){
        uint32_t *vtor = 0xe000ed08;
        *vtor = 0x20000000;

        was_here = 1;
        ((void(*)(void))0x2000019f)();
    }

    init_uart();




    uart_putc_raw(uart0, 'X');


    volatile char *  otp_guarded_data_ptr = ((uint32_t *)(OTP_DATA_GUARDED_BASE + (0xc08*2)));
    for(int i = 0; i<0x20; i++){
        const char * hex = "0123456789ABCDEF";
        char high = hex[otp_guarded_data_ptr[i]>>4 & 0xf];
        char low =  hex[otp_guarded_data_ptr[i]  & 0xf];


        uart_putc_raw(uart0, high);
        uart_putc_raw(uart0, low);
    }

    while (1){
        for (unsigned int j=0; j < 0xffffffff; j++){};
        volatile char *  otp_guarded_data_ptr = ((uint32_t *)(OTP_DATA_GUARDED_BASE + (0xc08*2)));
        for(int i = 0; i<0x20; i+=2){
            /* Challenge set up stores two bytes with swapped byte-order, restore correct secret */
            const char * hex = "0123456789ABCDEF";
            char high = hex[otp_guarded_data_ptr[i+1]>>4 & 0xf];
            char low =  hex[otp_guarded_data_ptr[i+1]  & 0xf];
            uart_putc_raw(uart0, high);
            uart_putc_raw(uart0, low);

            high = hex[otp_guarded_data_ptr[i]>>4 & 0xf];
            low =  hex[otp_guarded_data_ptr[i]  & 0xf];
            uart_putc_raw(uart0, high);
            uart_putc_raw(uart0, low);
        }
	uart_putc_raw(uart0, '\r');
	uart_putc_raw(uart0, '\n');

    };
}
