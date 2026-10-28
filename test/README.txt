From the top-level directory, you can run e.g.
```
    test/tapeout.sh |& tee test/tmp.log  # Option 1
    test/tapeout.sh SysCfgs/bf-cma.cfg   # Option 2, same thing (i.e. default is bf-fma00)
```

### Q-and-A

Q. What will the test script do?
```
  * build verilog for a pipelined 16-bit (bfloat) cascade multiply-add unit (CMA)

  * build and launch a librelane docker instance for physical design

  * inside the instance, build a GDS-II tape for the mul-add unit,
    using librelane default process (sky130 maybe)
```

Q. How do you know if it worked?
A. Look for something like this at the end of the output log:
```
        librelane.log runs/RUN_2026-08-11_15-48-53
                    Clock 100.0ns (10MHz)
            Critical path  36.89ns
               Setup/Hold  42.86ns 40.73ns
                  WARNING  Max Slew violations found
                   PASSED  Antenna LVS DRC
```

Q. Is this good?

All three tests passed at the end, and a GDS-II tape got generated, so
that's enough to declare short-term victory. BUT. There are max slew
violations, so that should probably be a one of many things to address
before actually trying to tape out a chip.

You can see results of a sample run in the "example" subdirectory:
```
  gunzip -c example/tapeout.log.gz | less
```

