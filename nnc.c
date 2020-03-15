
void main()
{
	int i;
	i = 0;

	while (1)
	{
		setled(i);
		i = i + 1;
	}
}

int setled(int i)
{
	int *p;
	p = 2147483652;
	*p = i;
	return;
}
