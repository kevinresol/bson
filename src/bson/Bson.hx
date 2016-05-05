package bson;

import haxe.io.Bytes;

class Bson {
	
	public inline static function encode(o:Dynamic):Bytes
		return BsonEncoder.encode(o);
	
	public inline static function decode(bytes:Bytes):Dynamic
		return BsonDecoder.decode(bytes);
		
	public inline static function decodeMultiple(bytes:Bytes, num = 1):Dynamic
		return BsonDecoder.decodeMultiple(bytes, num);
}