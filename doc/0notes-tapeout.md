# State of the tapeout as of Oct 2026

To tape out a given configuration, do e.g.
```
    make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-cma.cfg
    make tapeout
OR JUST:
    make clean tapeout GENESIS_CFG_SCRIPT=SysCfgs/bf-cma.cfg
```

Sample tapeout results for various configurations are shown in the table below.
By default, the tools use 20MHz as their target frequency.
```
    Config     Critical Path    u^2    Final Checks   RTL->GDS
    --------   -------------  -----   ---------------  -------
    bf-cma     12.3ns 81MHz     57K   Antenna LVS DRC   0h12m
    bf-fma     17.8ns 56MHz     41K   Antenna LVS DRC   0h44m
    bf-cma00   25.3ns 40MHz     22K   Antenna LVS DRC   0h05m
    bf-fma00   25.0ns 40MHz     17K   Antenna LVS DRC   0h05m
    --------   -------------  -----   ---------------  -------
    sp-cma     12.5ns 79MHz    105K   Antenna LVS DRC   0h18m
    sp-fma     24.9ns 40MHz     71K   Antenna LVS DRC   0h16m
    dp-cma     26.2ns 38MHz    237K           LVS DRC   3h18m
    dp-fma     FAILED b/c congestion in OpenROAD.GlobalRouting
```


#### Notes to self (some of these resources are not available in the repo)

What I did to make the data:
```
  steveri/do_tapeouts.sh --gen  # Creates 8 files steveri/tapeout--<config>.log etc.
  steveri/do_tapeouts.sh --sum > steveri/tapeout.sum
  mv steveri/tapeout* steveri/tapeouts.res0/
```

The summary table above was generated from `"tapeout.sum"` using this basic command ish:
```
  % egrep 'CONFIG|Crit|PASSED|Libre|Complex' tapeouts.res0/tapeout.sum \
    | sed 's/ns//;s/u / /' \
    | awk -v i=0 -v fmt="%-8s   %4.1fns %5s   %4.0fK  %16s   %s\n" '
      /CONFIG/{c[++i]=$2; tt[i]=$(NF-1)}  /Crit/{ns[i]=$3;fq[i]=$5}
      /PASSED/{$1="";p[i]=$0} /Complex/{area[i]=$5/1000}
      END{for (i in c) { printf(fmt, c[i], ns[i], fq[i], area[i], p[i], tt[i])}}'
```
