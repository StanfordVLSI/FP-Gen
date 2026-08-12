#!/usr/bin/python3
import os,sys
import xml.etree.ElementTree as ET

# Given a generated configuration "FPGen.xml", show the major
# ("IMPLEMENTATIOON" and "FUNCTIONAL") parameters used, e.g.
#
# % python findparms.py |& head
# 
#      top_FPGen.FPGen.Architecture = FMA
#      Which architecture implements Multiply Add? (Pick:CMA/FMA) 
#     
#      top_FPGen.FPGen.FMA.FractionWidth = 52
#      Width of the Fraction for the multiplier (default is IEEE Double, 52 bit) 
#      ...

# Process optional command-line argument <xml-file>
if len(sys.argv) > 1: xml_file = sys.argv[1]  # Specified on command line
else:                 xml_file = "FPGen.xml"  # The default

# Complain if xml file not exists
scriptname = sys.argv[0];
err1 = f"Cannot find xml file '{xml_file}'\n\n  USAGE:  {scriptname} [<xml_filename>]"
assert os.path.exists(xml_file), err1

# Parse the xml file
root = ET.parse(xml_file).getroot()

nparms_bypassed = 0
nparms_legit = 0

def redundant_path(path):
    '''Skip ifc and incrementer parms, we assume they are strictly inherited from uplevel'''
    for rpath in [".FPGen_ifc.", ".Incrementer."]:
        if path.endswith(rpath):
            global nparms_bypassed; nparms_bypassed+=1; return True
    return False
    

def process_parameter_items(path, pitems):
    '''
    Look for parameter description ("Doc"), specifically one that
    contains the keyword "IMPLEMENTATIOON" or "FUNCTIONAL", e.g.
        <Doc>Width of the exponent for the multiplier !FUNCTIONAL!</Doc>
        <Name>ExponentWidth</Name>
        <Val>11</Val>
    '''
    for pi in pitems:
        if pi.find("Doc")      == None: continue
        if pi.find("Doc").text == None: continue

        # Include top-level (top_FPGen) parms
        rawdoc = pi.find("Doc").text.strip()
        if path == "top_FPGen.":                 doc = rawdoc
        elif rawdoc[-16:] == "!IMPLEMENTATION!": doc = rawdoc[:-17].strip()
        elif rawdoc[-12:] == "!FUNCTIONAL!":     doc = rawdoc[:-13].strip()
        else: continue

        # Skip e.g. ifc and incrementer parms, we assume they are strictly inherited from uplevel
        # Do it inside the loop so we can count them
        if redundant_path(path): continue

        # Print the parameter name, value, and description
        name = pi.find("Name").text
        val =  pi.find("Val")
        if val != None: val = val.text
        print("PARM", path+name, "=", val)
        print("PARM", doc, "\nPARM")
        global nparms_legit; nparms_legit+=1
             
# Danger(m)ous(e) because recursive...
def dangermouse(root, path=""):

    # Look for base name, add to path if found
    for e in root:
        if e.tag == "InstanceName":
            path = path + e.text + "."; break

    # Process all parms found at this level; recurse to lower levels
    for e in root:
        process_parameter_items(path, e.findall("ParameterItem"))
        dangermouse(e, path)

dangermouse(root)

# Check your answers
if True:
    totparms = nparms_legit + nparms_bypassed
    print(f"\nFound {nparms_legit} legit parms; bypassed {nparms_bypassed} parms; total {totparms} parms")

    # (Add two for the two top-level parms, see?)
    shouldbe = len([s for s in list(root.itertext()) if "FUNC" in s or "IMP" in s])+2

    print(f"Should be {shouldbe} parms", flush=True)
    errmsg = f"ERROR found {totparms} parms when there maybe should be {shouldbe}"
    if totparms != shouldbe: print(errmsg)
    else:                    print("WE GOOD")
    assert totparms == shouldbe, errmsg
