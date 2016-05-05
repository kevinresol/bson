package bson;

@:enum
abstract BsonType(Int) from Int to Int {
	var BTerminate = 0x00;
	var BDouble = 0x01;
	var BString = 0x02;
	var BDocument = 0x03;
	var BArray = 0x04;
	var BBinary = 0x05;
	// var BUndefined = 0x06; // deprecated per bson spec
	var BObjectId = 0x07;
	var BBool = 0x08;
	var BDate = 0x09;
	var BNull = 0x0A;
	var BRegEx = 0x0B;
	// var BDBPointer = 0x0C; // deprecated per bson spec
	var BJavascript = 0x0D;
	// var  = 0x0E; // deprecated per bson spec
	var BJavascriptWithScope = 0x0F;
	var BInt32 = 0x10;
	var BTimestamp = 0x11;
	var BInt64 = 0x12;
	var BMinKey = 0xFF;
	var BMaxKey = 0x7F;
}

@:enum
abstract BsonSubType(Int) from Int to Int {
	var BSGeneric = 0x00;
	var BSFunction = 0x01;
	var BSBinary = 0x02;
	var BSUuidOld = 0x03;
	var BSUuid = 0x04;
	var BSMd5 = 0x05;
	var BSUserDefined = 0x80;
}