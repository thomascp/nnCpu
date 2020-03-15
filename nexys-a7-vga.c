
void main()
{
	int *led;
	int *gpio;
	int *rbx;
	int *rby;
	int *gbx;
	int *gby;
	int led_val;
	int gpio_val;
	int direx;
	int direy;
	int rbxl;
	int rbxr;
	int rbyu;
	int rbyd;
	int gbxl;
	int gbxr;
	int gbyu;
	int gbyd;
	int tmp;
	int delayrgb;
	int delaykey;

	led = 0x80000004;
	gpio = 0x80000000;
	rbx = 0x80001000;
	rby = 0x80001004;
	gbx = 0x80001008;
	gby = 0x8000100c;
	led_val = 0;
	gpio_val = 0;
	direx = 1;
	direy = 1;
	tmp = 0;
	delayrgb = 10;
	delaykey = 120;

	*led = 0;
	rbxl = 0x00000000;
	rbxr = 0x00000014;
	*rbx = 0x00000014; // 0 20
	rbyu = 0x00000000;
	rbyd = 0x00000014;
	*rby = 0x00000014; // 0 20
	gbxl = 0x00000000;
	gbxr = 0x00000050;
	*gbx = 0x00000050; // 0 80
	gbyu = 0x02440000;
	gbyd = 0x00000258;
	*gby = 0x02440258; // 580 600

	while (1)
	{
		gpio_val = *gpio;
		if (gpio_val == 1) //left
		{
			if (gbxl >= 0x00140000)
			{
				gbxl = gbxl - 0x00140000;
				gbxr = gbxr - 0x00000014;
				tmp = gbxl + gbxr;
				*gbx = tmp;
			}
		}
		if (gpio_val == 2) //right
		{
			if (gbxr <= 0x0000030c)
			{
				gbxl = gbxl + 0x00140000;
				gbxr = gbxr + 0x00000014;
				tmp = gbxl + gbxr;
				*gbx = tmp;
			}
		}

		
		while (delaykey > 0)
		{
			delaykey = delaykey - 1;
		}
		delaykey = 120;

		if (delayrgb > 0)
		{
			delayrgb = delayrgb - 1;
			continue;
		}
		delayrgb = 10;

		if (rbyu == 0)
		{
			direy = 1;
		}
		if (rbyd == 580)  // think about touch down
		{
			if (rbxl >= gbxl && rbxr <= gbxr)
			{
				direy = 0;
			}
			else
			{
				direy = 2;
			}
		}

		if (rbxl == 0)
		{
			direx = 1;
		}
		if (rbxr == 800)
		{
			direx = 0;
		}

		if (direx == 1)
		{
			rbxl = rbxl + 0x00140000;
			rbxr = rbxr + 0x00000014;
		}
		if (direx == 0)
		{
			rbxl = rbxl - 0x00140000;
			rbxr = rbxr - 0x00000014;
		}
		if (direy == 1)
		{
			rbyu = rbyu + 0x00140000;
			rbyd = rbyd + 0x00000014;
		}
		if (direy == 0)
		{
			rbyu = rbyu - 0x00140000;
			rbyd = rbyd - 0x00000014;
		}

		if (direy == 2) // fail
		{
			tmp = 0;
			while (1)
			{
				delayrgb = 100;
				while (delayrgb > 0)
				{
					delayrgb = delayrgb - 1;
				}
				tmp = tmp + 1;
				*led = tmp;
			}
		}

		tmp = rbxl + rbxr;
		*rbx = tmp;
		tmp = rbyu + rbyd;
		*rby = tmp;
	}
}

