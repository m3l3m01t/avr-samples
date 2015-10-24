#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	unsigned int counter;

	DDRB=0xff;      //设置PORTB输出

	while(1) {
		PORTB=0xff; //设置PORTB为高

		counter=0;
		while(counter < 100) {
			_delay_loop_2(3000);
			counter++;
		}

		PORTB=0x00;

		counter=0;
		while(counter < 1000) {
			_delay_loop_2(3000);
			counter++;
		}
	}
	return 1;
}
