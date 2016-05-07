package;

import bson.*;
import haxe.Int64;

class TestEncoder extends Base {
	
	function testEncodeString() {
		var data:BsonDocument = {
			_id: new ObjectId('572ae3afe378209d612b3643'),
			a: 'b',
		}
		assertBytes(Base.STRING, Bson.encode(data));
	}
	
	function testEncodeDate() {
		var data:BsonDocument = {
			_id: new ObjectId("572b4d524dd01c6e90e069eb"),
			a: Date.fromTime(1462455634589),
		}
		assertBytes(Base.DATE, Bson.encode(data));
	}
	
	#if !java
	// Int64 is broken on java
	// see https://github.com/HaxeFoundation/haxe/issues/5204
	function testEncodeInt64() {
		var data:BsonDocument = {
			_id: new ObjectId("572b443e4dd01c6e90e069ea"), 
			a: Int64.make(0x01, 0x23456789)
		}
		assertBytes(Base.INT64, Bson.encode(data));
	}
	#end
}