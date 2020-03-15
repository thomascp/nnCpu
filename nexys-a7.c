
void main()
{
	int *led;
	int *gpio;
	int led_val;
	int gpio_val;

	led = 0x80000004;
	gpio = 0x80000000;
	led_val = 0;
	gpio_val = 0;

	*led = 0;

	while (1)
	{
		gpio_val = *gpio;
		if (gpio_val == 1)
		{
			led_val = *led;
			*led = led_val + 1;
		}
		else
		{
			led_val = *led;
			*led = led_val - 1;
		}
	}
}

