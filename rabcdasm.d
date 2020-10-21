/*
 *  Copyright 2010, 2011 Vladimir Panteleev <vladimir@thecybershadow.net>
 *  This file is part of RABCDAsm.
 *
 *  RABCDAsm is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  RABCDAsm is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with RABCDAsm.  If not, see <http://www.gnu.org/licenses/>.
 */
 
 //modified to also include abcexport and to only output a single asasm file

module rabcdasm;

import std.file;
import std.path;
import std.conv;
import std.stdio;
import std.format;
import swffile;
import abcfile;
import asprogram;
import disassembler;

void main(string[] args) {
	if (args.length == 1) throw new Exception("No swf specified");
	string swfName = args[1];
	string asasmName = (2 < args.length ? args[2] : stripExtension(args[1]) ~ ".asasm");
	ubyte[] abcBytes;
	try {
		scope swf = SWFFile.read(cast(ubyte[])read(swfName));
		uint count = 0;
		foreach (ref tag; swf.tags) if ((tag.type == TagType.DoABC || tag.type == TagType.DoABC2)) {
			if (++count == 2) break;
			else if (tag.type == TagType.DoABC) abcBytes = tag.data;
			else {
				auto p = tag.data.ptr+4; // skip flags
				while (*p++) {} // skip name
				abcBytes = tag.data[p-tag.data.ptr..$];
			}
		}
		if (count == 0) throw new Exception("No DoABC tags found");
		else if (1 < count) throw new Exception("More than 1 DoABC tag found");
	} catch (Exception e) throw new Exception("Error while processing %s: %s".format(swfName, e));
	auto abc = ABCFile.read(abcBytes);
	auto as = ASProgram.fromABC(abc);
	auto disassembler = new Disassembler(as);
	string[string] strings = disassembler.disassemble();
	ubyte[] output;
	foreach (filename, data; strings) {
		output ~= cast(ubyte[])filename;
		output ~= '\0';
		output ~= cast(ubyte[])data;
		output ~= '\0';
	}
	std.file.write(asasmName, output);
}
