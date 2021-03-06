/// Prints a table of the collected times.
module makesvg;

import std.algorithm;
import std.array;
import std.datetime;
import std.exception;
import std.file;
import std.range;
import std.stdio;

import ae.utils.json;

import common;

void main(string[] args)
{
	enforce(args.length == 2, "Usage: " ~ args[0] ~ " FILE.dbuildstat");
	auto modules = args[1].readText().jsonParse!(Module[])();
	modules.sort!`a.name < b.name`();
	foreach (m; modules)
		writefln("%(%6.3f\t%)\t%s", m.bestTime[].map!(a => cast(double)a / TICKS_PER_SECOND)().array(), m.name);
	ulong[Metric.max] total;
	foreach (m; modules)
		foreach (metric, time; m.bestTime)
			total[metric] += time;
	writefln("%(%6.3f\t%)\t%s", total[].map!(a => cast(double)a / TICKS_PER_SECOND)().array(), "Total");
	auto deltas = iota(1, Metric.max).map!(n => total[n] - total[n-1])().array();
	writefln("\t%(%6.3f\t%)\t%s", deltas.map!(a => cast(double)a / TICKS_PER_SECOND)().array(), "Delta");
}
