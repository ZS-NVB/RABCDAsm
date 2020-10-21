Robust ABC (ActionScript Bytecode) [Dis-]Assembler
==================================================

Modified version of [RABCDAsm][] which outputs all asasm files to a single file, making it much faster.

To disassemble a swf:

    rabcdasm swfFilename outputFilename

If outputFilename is omitted then swfFilename with its extension replaced with .asasm will be used.

To reassemble a swf:

    rabcasm swfFilename asasmFilename outputFilename

If asasmFilename is omitted then swfFilename with its extension replaced with .asasm will be used and if outputFilename is omitted then it will use swfFilename. 

License
=======

RABCDAsm is distributed under the terms of the GPL v3 or later, with the 
exception of `murmurhash2a.d`, `zlibx.d` and LZMA components, which are in the 
public domain, and `asasm.hrc`, which is tri-licensed under the MPL 1.1/GPL 
2.0/LGPL 2.1. The full text of the GNU General Public License can be found in 
the file `COPYING`.
