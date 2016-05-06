package;

import bson.*;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using StringTools;

class RunTests extends TestCase {
	
	// {_id: ObjectId("572ae3afe378209d612b3643"), a: 'b'}
	static inline var STRING = "1F,00,00,00,07,5F,69,64,00,57,2A,E3,AF,E3,78,20,9D,61,2B,36,43,02,61,00,02,00,00,00,62,00,00";
	
	// {_id: ObjectId("572b4d524dd01c6e90e069eb"), a: Date.fromTime(1462455634589)}
	#if (neko || python) // no ms precision
		static inline var DATE = "21,00,00,00,07,5F,69,64,00,57,2B,4D,52,4D,D0,1C,6E,90,E0,69,EB,09,61,00,50,08,26,81,54,01,00,00,00";
	#else
		static inline var DATE = "21,00,00,00,07,5F,69,64,00,57,2B,4D,52,4D,D0,1C,6E,90,E0,69,EB,09,61,00,9D,0A,26,81,54,01,00,00,00";
	#end
	
	// {_id: ObjectId("572b443e4dd01c6e90e069ea"), a: Int64.make(0x01, 0x23456789)}
	static inline var INT64 = "21,00,00,00,07,5F,69,64,00,57,2B,44,3E,4D,D0,1C,6E,90,E0,69,EA,12,61,00,89,67,45,23,01,00,00,00,00";
	
	static function main() {
		
		var t = new TestRunner();
		t.add(new RunTests());
		if(!t.run()) {
			#if sys
			Sys.exit(500);
			#end
		}
	}
	
	function testEncodeString() {
		var data:BsonDocument = {
			_id: new ObjectId('572ae3afe378209d612b3643'),
			a: 'b',
		}
		assertBytes(STRING, Bson.encode(data));
	}
	
	function testEncodeDate() {
		var data:BsonDocument = {
			_id: new ObjectId("572b4d524dd01c6e90e069eb"),
			a: Date.fromTime(1462455634589),
		}
		assertBytes(DATE, Bson.encode(data));
	}
	
	function testEncodeInt64() {
		var data:BsonDocument = {
			_id: new ObjectId("572b443e4dd01c6e90e069ea"), 
			a: Int64.make(0x01, 0x23456789)
		}
		assertBytes(INT64, Bson.encode(data));
	}
	
	function testDecodeString() {
		var bytes = hexToBytes(STRING);
		var decoded = Bson.decode(bytes);
		assertEquals('b', decoded.a);
		var id:ObjectId = decoded._id;
		assertEquals('572ae3afe378209d612b3643', id.valueOf());
	}
	
	function testDecodeDate() {
		var bytes = hexToBytes(DATE);
		var decoded = Bson.decode(bytes);
		assertTrue(Std.is(decoded.a, Date));
		
		var d:Date = decoded.a;
		assertDate(Date.fromTime(1462455634589), d);
		var id:ObjectId = decoded._id;
		assertEquals('572b4d524dd01c6e90e069eb', id.valueOf());
	}
	
	function testDecodeInt64() {
		var bytes = hexToBytes(INT64);
		var decoded = Bson.decode(bytes);
		assertTrue(Int64.is(decoded.a));
		var i:Int64 = decoded.a;
		assertEquals(0x01, i.high);
		assertEquals(0x23456789, i.low);
		var id:ObjectId = decoded._id;
		assertEquals('572b443e4dd01c6e90e069ea', id.valueOf());
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
			buggyDate: Date.fromTime(1462535772414),
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
			
			if(!ObjectId.is(b)) fail('b is not object id');
			var a:ObjectId = cast a;
			var b:ObjectId = cast b;
			assertTrue(a == b);
			
		} else if(Std.is(a, String)) {
			
			if(!Std.is(b, String)) fail('b is not string');
			assertEquals(a, b);
			
		} else if(Std.is(a, Date)) {
			
			if(!Std.is(b, Date)) fail('b is not date');
			var a:Date = cast a;
			var b:Date = cast b;
			assertDate(a, b);
			
		} else if (Std.is(a, Array)) {
			
			if(!Std.is(b, Array)) fail('b is not array');
			if(a.length != b.length) fail('not same length');
			for(i in 0...a.length) compare(a[i], b[i]);
			
		} else if(Int64.is(a)) {
			
			#if !java
			if(!Int64.is(b)) fail('b is not int64');
			#end
			var a:Int64 = cast a;
			var b:Int64 = cast b;
			assertTrue(a == b);
			
		} else if(Reflect.isObject(a)) {
			
			if(!Reflect.isObject(b)) fail('b is not object');
			var keys = Reflect.fields(a);
			if(keys.length != Reflect.fields(b).length) fail('not same number of keys');
			for(key in keys) compare(Reflect.field(a, key), Reflect.field(b, key));
			
		} else {
			assertEquals(a, b);
		}
	}
	
	function assertBytes(s:String, b:Bytes, ?pos:haxe.PosInfos) {
		assertEquals(s.replace(',' ,'').toLowerCase(), b.toHex());
	}
	
	function assertDate(a:Date, b:Date, ?pos:haxe.PosInfos) {
		#if (neko || cs)
		assertEquals(Std.int(a.getTime() / 1000), Std.int(b.getTime() / 1000));
		#else
		assertEquals(a.getTime(), b.getTime());
		#end
	}
	
	function fail( reason:String, ?c : haxe.PosInfos ) : Void {
		currentTest.done = true;
		currentTest.success = false;
		currentTest.error   = reason;
		currentTest.posInfos = c;
		throw currentTest;
	}
	
	function hexToBytes(str:String) {
		var s = str.split(',');
		var bytes = Bytes.alloc(s.length);
		for(i in 0...s.length) bytes.set(i, Std.parseInt('0x${s[i]}'));
		return bytes;
	}
}