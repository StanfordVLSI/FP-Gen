// randomize() with constraints is a mess wrt verilator, so we do this VRAND
// macro thing: if VRAND already set, use that i.e. vcs +define+VRAND=vrandk
// else verilator defaults to "vrandver" and vcs defaults to "vrandvcs"

// Set up a couple of defaults
// `ifdef verilator `define VRAND_DEFAULT vrandver  // FIXME this should be default
`ifdef verilator `define VRAND_DEFAULT vrandk       // FIXME this should NOT be default
`else            `define VRAND_DEFAULT vrandvcs
`endif

// Use default value if VRAND undefined
`ifndef VRAND `define VRAND `VRAND_DEFAULT
`endif
