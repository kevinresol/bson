package;

import bson.*;
import haxe.Int64;

class TestComplex extends Base {
	
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
}