package;

import bson.*;
import haxe.Int64;
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
		assertEquals(Std.string(data), Std.string(decoded));
	}
}