function [mapped_delay, routed_delay, optimized_delay,...
    mapped_dynamic_power, routed_dynamic_power, optimized_dynamic_power]...
    = readcsv(filename, Vth0, Vdd0)
    
    [design, Vth, Vdd, mapped_d, routed_d, optimized_d, ...
        mapped_core_area, routed_core_area, optimized_core_area, ...
        mapped_p, routed_p, optimized_p,...
        mapped_leakage_power, routed_leakage_power, optimized_leakage_power]...
    = textread(filename, '%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f', 'headerlines', 1,'delimiter', ',');

    mapped_d2a = filterVtVdd (mapped_d, Vth, Vdd, Vth0, Vdd0);
    routed_d2a = filterVtVdd (routed_d, Vth, Vdd, Vth0, Vdd0);
    optimized_d2a = filterVtVdd (optimized_d, Vth, Vdd, Vth0, Vdd0);
    mapped_p2a = filterVtVdd (mapped_p, Vth, Vdd, Vth0, Vdd0);
    routed_p2a = filterVtVdd (routed_p, Vth, Vdd, Vth0, Vdd0);
    optimized_p2a = filterVtVdd (optimized_p, Vth, Vdd, Vth0, Vdd0);
    
    [mapped_delay, mapped_dynamic_power] = getFrontier(mapped_d2a, mapped_p2a);
    [optimized_delay, optimized_dynamic_power] = getFrontier(optimized_d2a, optimized_p2a);
    [routed_delay, routed_dynamic_power] = getFrontier(routed_d2a, routed_p2a);

end