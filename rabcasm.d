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
 
 //modified to include abcreplace and to work with only a single asasm file

module rabcasm;

import std.file;
import std.path;
import std.conv;
import abcfile;
import asprogram;
import assembler;
import swffile;

void main(string[] args) {
	if (args.length == 1) throw new Exception("No swf file specified");
	string swfName = args[1];
	string asasmName = (2 < args.length ? args[2] : stripExtension(args[1]) ~ ".asasm");
	string outputName = (3 < args.length ? args[3] : args[1]);
	ubyte[] input = cast(ubyte[])read(asasmName);
	string[string] strings;
	string filename;
	int start = 0;
	for (int i = 0; i < input.length; i++) {
		if (input[i] == '\0') {
			string data = cast(string)input[start..i];
			start = i + 1;
			if (filename == null) filename = data;
			else {
				strings[filename] = data;
				filename = null;
			}
		}
	}
	auto as = new ASProgram;
	auto assembler = new Assembler(as);
	assembler.assemble(strings);
	auto abc = as.toABC();
	auto abcData = abc.write();
	auto swf = SWFFile.read(cast(ubyte[])read(swfName));
	foreach (ref tag; swf.tags) if (tag.type == TagType.DoABC || tag.type == TagType.DoABC2) {
		if (tag.type == TagType.DoABC)
			tag.data = abcData;
		else {
			auto p = tag.data.ptr+4; // skip flags
			while (*p++) {} // skip name
			tag.data = tag.data[0..p-tag.data.ptr] ~ abcData;
		}
		tag.length = cast(uint)tag.data.length;
		write(outputName, swf.write());
		return;
	}
}
