function out = filterVtVdd (in, Vth, Vdd, Vth0, Vdd0)
	index1 = find (strcmp(Vth, Vth0));
    index2 = find (Vdd(index1) == Vdd0);
    out = in(index1(index2));
end