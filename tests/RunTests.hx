package;


import haxe.unit.TestRunner;
import haxe.unit.TestCase;

#if flash
import flash.system.System.exit;
#else
import Sys.exit;
#end

using StringTools;

class RunTests {
	
	
	static function main() {
		
		var t = new TestRunner();
		t.add(new TestEncoder());
		t.add(new TestDecoder());
		t.add(new TestComplex());
		exit(t.run() ? 0 : 500);
	}
	
	
	
	
}