package bson;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.crypto.Md5;

@:forward
abstract ObjectId(ObjectIdBase) from ObjectIdBase {
	
	public inline function new(?bytes:Bytes) this = new ObjectIdBase(bytes);
	
	public static inline function is(o:Dynamic):Bool
		return Std.is(o, ObjectIdBase);
	
	@:from
	public static function fromString(s:String) {
		if(s.length != 24) throw "String ObjectId should be of length 24";
		var bytes = Bytes.alloc(12);
		for(i in 0...12) bytes.set(i, Std.parseInt('0x' + s.substr(i << 1, 2)));
		return new ObjectIdBase(bytes);
	}
	
	@:op(A == B)
	public inline function eq(b:ObjectId):Bool
		return this.bytes.toHex() == b.bytes.toHex();
}

private class ObjectIdBase {
	
	static var pid = Std.random(65536);
	static var sequence = 0;
	static var machine = Bytes.ofString(Md5.encode(
		#if php
			try sys.net.Host.localhost() catch(e:Dynamic) 'php'
		#elseif sys 
			sys.net.Host.localhost() 
		#else 
			'flash' 
		#end
	));
	
	public var bytes(default, null):Bytes;
	
	public function new(?bytes:Bytes) {
		if(bytes != null) this.bytes = bytes;
		else {
			var out = new BytesOutput();
			out.writeInt32(Math.floor(Date.now().getTime() / 1000));
			out.writeBytes(machine, 0, 3);
			out.writeUInt16(pid);
			out.writeUInt24(sequence++);
			if(sequence > 0xffffff) sequence = 0;
			this.bytes = out.getBytes();
		}
	}
	
	public function toString():String {
		return 'ObjectID("${bytes.toHex()}")';
	}
	
	public inline function getTimeStamp()
		return Date.fromTime(bytes.getInt32(0) * 1000);
	
	public inline function valueOf()
		return bytes.toHex();
}