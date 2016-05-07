package;


import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using StringTools;

class RunTests {
	
	
	static function main() {
		
		var t = new TestRunner();
		t.add(new TestEncoder());
		t.add(new TestDecoder());
		t.add(new TestComplex());
		if(!t.run()) {
			#if sys
			Sys.exit(500);
			#end
		}
	}
	
	
	
	
}