package bson;

import haxe.Int64;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import bson.BsonType;
using Reflect;

class BsonEncoder {
	public static function encode(o:Dynamic):Bytes {
		var bson = new BsonOutput();
		if(Type.typeof(o) == TObject)
			bson.writeObject(o);
		else if(BsonDocument.is(o))
			bson.writeBsonDocument(o);
		else
			throw "Cannot only encode object or BsonDocument"; // TODO: handle class instances and maps?
		return bson.getBytes();
	}
	
	public static function encodeMultiple(arr:Array<Dynamic>):Bytes {
		var bson = new BsonOutput();
		for(o in arr) {
			if(Type.typeof(o) != TObject) throw "Cannot encode non-object"; // TODO: handle class instances and maps?
			bson.writeObject(o);
		}
		return bson.getBytes();
	}
}

private class BsonOutput extends BytesOutput {
	public function writeHeader(key:String, type:BsonType) {
		writeByte(type);
		writeString(key);
		writeByte(BTerminate);
	}
	
	public function writeUInt32(n:Float) {
		var high = Std.int(n / 65536.0);
		var low = Math.round(n - high * 65536.0);
		writeUInt16(low);
		writeUInt16(high);
	}
	
	public function writeUInt64(n:Float) {
		var high = Math.ffloor(n / 4294967296.0);
		var low = n - high * 4294967296.0;
		writeUInt32(low);
		writeUInt32(high);
	}
	
	public function writeKeyValue(key:String, value:Dynamic) {
		if(value == null) writeHeader(key, BNull);
		else switch Type.typeof(value) {
			case TBool:
				writeHeader(key, BBool);
				writeByte(value ? 0x01 : 0x00);
				
			case TInt:
				writeHeader(key, BInt32);
				writeInt32(value);
			
			case TFloat:
				writeHeader(key, BDouble);
				writeDouble(value);
				
			case _ if(Std.is(value, String)):
				var value:String = cast value;
				writeHeader(key, BString);
				writeInt32(value.length + 1);
				writeString(value);
				writeByte(BTerminate);
			
			case _ if(Int64.is(value)):
				var value:Int64 = cast value;
				writeHeader(key, BInt64);
				writeInt32(value.low);
				writeInt32(value.high);
			
			case _ if(Std.is(value, Date)):
				var value:Date = cast value;
				writeHeader(key, BDate);
				writeUInt64(value.getTime());
				
			case _ if(ObjectId.is(value)):
				var value:ObjectId = cast value;
				writeHeader(key, BObjectId);
				write(value.bytes);
			
			case _ if(Std.is(value, Array)):
				writeHeader(key, BArray);
				writeArray(value);
			
			case _ if(Std.is(value, StringMap)):
				writeHeader(key, BDocument);
				writeMap(value);
				
			case _ if(BsonDocument.is(value)):
				writeHeader(key, BDocument);
				writeBsonDocument(value);
			
			case _ if(value.isObject()):
				writeHeader(key, BDocument);
				writeObject(value);
			
		}
	}
	
	public function writeArray(array:Array<Dynamic>) {
		var bson = new BsonOutput();
		for(i in 0...array.length)
			bson.writeKeyValue(Std.string(i), array[i]);
		bson.writeByte(BTerminate);
		var bytes = bson.getBytes();
		writeInt32(bytes.length + 4); // include the 32-bit length value itself
		write(bytes);
	}
	
	public function writeObject(o:Dynamic) {
		var bson = new BsonOutput();
		for(key in o.fields()) {
			var value = o.field(key);
			if(!Reflect.isFunction(value))
				bson.writeKeyValue(key, value);
		}
		bson.writeByte(BTerminate);
		var bytes = bson.getBytes();
		writeInt32(bytes.length + 4); // include the 32-bit length value itself
		write(bytes);
	}
	
	public function writeMap(o:Map<String, Dynamic>) {
		var bson = new BsonOutput();
		for(key in o.keys()) {
			var value = o.field(key);
			bson.writeKeyValue(key, value);
		}
		bson.writeByte(BTerminate);
		var bytes = bson.getBytes();
		writeInt32(bytes.length + 4); // include the 32-bit length value itself
		write(bytes);
	}
	
	public function writeBsonDocument(b:BsonDocument) {
		var bson = new BsonOutput();
		for(item in b)
			bson.writeKeyValue(item.key, item.value);
		bson.writeByte(BTerminate);
		var bytes = bson.getBytes();
		writeInt32(bytes.length + 4); // include the 32-bit length value itself
		write(bytes);
	}
}