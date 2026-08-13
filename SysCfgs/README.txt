### Sample configurations that might be useful:
```
cma.cfg - "CMA" architecture + "Wallace" trees, everything else default
dp-cma.cfg - 5-cy 64-bit CMA, 2-cycle mul, denorm, forwarding, Wallace trees, Booth-3
dp-fma.cfg - 6-cy 64-bit FMA, 2-cycle mul, denorm, forwarding, "Array" trees, Booth-3
sp-cma.cfg - 6-cy 32-bit CMA, 3-cycle mul, denorm, forwarding, Wallace trees, Booth-2
sp-fma.cfg - 4-cy 32-bit FMA, 2-cycle mul, denorm, forwarding, "ZM" trees, Booth-3
```

#### bfloat configs - these build and run extremely quickly!
```
bf-cma00.cfg - unpipelined 16-bit (bfloat) CMA
bf-fma00.cfg - unpipelined 16-bit (bfloat) FMA
```

### What else is here
```
default.txt - lists default system parameters, it was found by doing this:
    % make clean gen  # Builds default config, produces parm file "FPGen.xml"
    % scripts/summarize_gen_params.py FPGen.xml

empty.xml - old-style "empty" config for building default config

booth3.cfg - sets CMA booth type to "3"
  - probably not very useful on its own, since default config is FMA!!!?
```
