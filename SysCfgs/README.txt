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
bf-fma.cfg   - uses default pipeline (3-cy mul, 7-cy mul-add?)
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

### Example configs

A guide to some of the major top-level parameters
Notes on some of the major top-level parameters

EXAMPLE: 1-cycle (unpipelined) 16-bit bfloat FMA. Note that forwarding
must be OFF ("NO") to enable 0-depth pipelines.

    configure( 'top_FPGen.FPGen.Architecture' ,      'FMA' );
    configure( 'top_FPGen.FPGen.FMA.FractionWidth' ,    10 );
    configure( 'top_FPGen.FPGen.FMA.ExponentWidth' ,     5 );
    configure( 'top_FPGen.FPGen.FMA.PipelineDepth' ,     0 );
    configure( 'top_FPGen.FPGen.FMA.MulpPipelineDepth' , 0 );
    configure( 'top_FPGen.FPGen.FMA.EnableForwarding' , 'NO' );

EXAMPLE: 1-cycle (unpipelined) 16-bit bfloat CMA. Note that forwarding
must be OFF ("NO") to enable 0-depth pipelines.

    configure( 'top_FPGen.FPGen.Architecture' ,      'CMA' );
    configure( 'top_FPGen.FPGen.CMA.FractionWidth' ,    10 );
    configure( 'top_FPGen.FPGen.CMA.ExponentWidth' ,     5 );
    configure( 'top_FPGen.FPGen.CMA.PipelineDepth' ,     0 );
    configure( 'top_FPGen.FPGen.CMA.MulpPipelineDepth' , 0 );
    configure( 'top_FPGen.FPGen.CMA.EnableForwarding' , 'NO' );

EXAMPLE: Minimally-pipelined CMA with forwarding. With forwarding
enabled, min values for pipe and mulpipe are 5 and 2 respectively.

    configure( 'top_FPGen.FPGen.Architecture' ,      'CMA' );
    configure( 'top_FPGen.FPGen.CMA.FractionWidth' ,    10 );
    configure( 'top_FPGen.FPGen.CMA.ExponentWidth' ,     5 );
    configure( 'top_FPGen.FPGen.CMA.PipelineDepth' ,     5 );
    configure( 'top_FPGen.FPGen.CMA.MulpPipelineDepth' , 2 );
    configure( 'top_FPGen.FPGen.CMA.EnableForwarding' , 'YES' );

NOTES
- 3-deep pipe adds about 60K of code vs. no pipe. 5-deep adds 130K
- cma is about 150K bigger than fma (why?)
-- more adder trees; "sumcomparators"; cma has 5 pipeline registers (?)

    661K    bf-cma52/genesis_synth
    584K    bf-cma30/genesis_synth
    527K    bf-cma00/genesis_synth

    410K    bf-fma30/genesis_synth
    389K    bf-fma00/genesis_synth

1.2M    default/genesis_synth
910K    sp-cma/genesis_synth
