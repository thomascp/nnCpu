
void main()
{
	int i;
	i = 1;

	while (1)
	{
		setled(i);
		i = i + 1;
	}
}

int setled(int i)
{
	int *p;
	p = 0x80000004;
	*p = i;
	return;
}
