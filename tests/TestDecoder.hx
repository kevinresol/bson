package;

import bson.*;
import haxe.Int64;

class TestDecoder extends Base {
	
	
	function testDecodeString() {
		var bytes = hexToBytes(Base.STRING);
		var decoded = Bson.decode(bytes);
		assertEquals('b', decoded.a);
		var id:ObjectId = decoded._id;
		assertEquals('572ae3afe378209d612b3643', id.valueOf());
	}
	
	function testDecodeDate() {
		var bytes = hexToBytes(Base.DATE);
		var decoded = Bson.decode(bytes);
		assertTrue(Std.is(decoded.a, Date));
		
		var d:Date = decoded.a;
		assertDate(Date.fromTime(1462455634589), d);
		var id:ObjectId = decoded._id;
		assertEquals('572b4d524dd01c6e90e069eb', id.valueOf());
	}
	
	#if !java
	// Int64 is broken on java
	// see https://github.com/HaxeFoundation/haxe/issues/5204
	function testDecodeInt64() {
		var bytes = hexToBytes(Base.INT64);
		var decoded = Bson.decode(bytes);
		assertTrue(Int64.is(decoded.a));
		var i:Int64 = decoded.a;
		assertEquals(0x01, i.high);
		assertEquals(0x23456789, i.low);
		var id:ObjectId = decoded._id;
		assertEquals('572b443e4dd01c6e90e069ea', id.valueOf());
	}
	#end
}