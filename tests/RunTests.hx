package;

import bson.*;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using StringTools;

class RunTests extends TestCase {
	
	static function main() {
		
		var t = new TestRunner();
		t.add(new RunTests());
		if(!t.run()) {
			#if sys
			Sys.exit(500);
			#end
		}
	}
	
	function testDecode() {
		var str = "1F000000075F696400572AE3AFE378209D612B364302610002000000620000";
		var bytes = Bytes.alloc(str.length >> 1);
		for(i in 0...bytes.length) bytes.set(i, Std.parseInt('0x' + str.substr(i << 1, 2)));
		var decoded = Bson.decode(bytes);
		assertEquals('b', decoded.a);
		var id:ObjectId = decoded._id;
		assertEquals('572ae3afe378209d612b3643', id.valueOf());
	}
	
	function testComplex() {
		
		var data = {
			_id: new ObjectId(),
			title: 'My awesome post',
			hol: [10, 2, 20.5],
			int64: Int64.ofInt(1),
			lint64: Int64.make(1<<31, 0),  // smallest int64
			options: {
				delay: 1.565,
				test: true,
				nested: [
					{
						going: 'deeper',
						mining: -35
					}
				]
			},
			date: Date.now(),
			int: 21474,
			float: 2147483647.0,
			monkey: null,
			bool: true
		};
		var encoded = Bson.encode(data);
		// trace([for(i in 0...encoded.length) encoded.get(i).hex(2)].join(","));
		var decoded = Bson.decode(encoded);
		compare(data, decoded);
	}
	
	function compare(a:Dynamic, b:Dynamic, ?pos:haxe.PosInfos) {
		
		if(ObjectId.is(a)) {
			
			if(!ObjectId.is(b)) fail('b is not object id', pos);
			var a:ObjectId = cast a;
			var b:ObjectId = cast b;
			assertTrue(a == b, pos);
			
		} else if(Std.is(a, String)) {
			
			if(!Std.is(b, String)) fail('b is not string', pos);
			assertEquals(a, b, pos);
			
		} else if(Std.is(a, Date)) {
			
			if(!Std.is(b, Date)) fail('b is not date', pos);
			var a:Date = cast a;
			var b:Date = cast b;
			assertTrue(Math.abs(a.getTime() - b.getTime()) < 1, pos); // rounding issue
			
		} else if (Std.is(a, Array)) {
			
			if(!Std.is(b, Array)) fail('b is not array', pos);
			if(a.length != b.length) fail('not same length', pos);
			for(i in 0...a.length) compare(a[i], b[i], pos);
			
		} else if(Int64.is(a)) {
			
			#if !java
			if(!Int64.is(b)) fail('b is not int64', pos);
			#end
			var a:Int64 = cast a;
			var b:Int64 = cast b;
			assertTrue(a == b, pos);
			
		} else if(Reflect.isObject(a)) {
			
			if(!Reflect.isObject(b)) fail('b is not object', pos);
			var keys = Reflect.fields(a);
			if(keys.length != Reflect.fields(b).length) fail('not same number of keys', pos);
			for(key in keys) compare(Reflect.field(a, key), Reflect.field(b, key), pos);
			
		} else {
			assertEquals(a, b, pos);
		}
	}
	
	function fail( reason:String, ?c : haxe.PosInfos ) : Void {
		currentTest.done = true;
		currentTest.success = false;
		currentTest.error   = reason;
		currentTest.posInfos = c;
		throw currentTest;
	}
}