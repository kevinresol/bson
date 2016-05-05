package bson;

import haxe.io.Bytes;

class Bson {
	
	public inline static function encode(o:Dynamic):Bytes
		return BsonEncoder.encode(o);
	
	public inline static function decode(bytes:Bytes):Dynamic
		return BsonDecoder.decode(bytes);
}