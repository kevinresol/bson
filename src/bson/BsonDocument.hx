package bson;

import haxe.macro.Context;
import haxe.macro.Expr;

@:forward
abstract BsonDocument(BsonDocumentBase) {
	
	public inline function new() this = new BsonDocumentBase();
	
	public static inline function is(v:Dynamic)
		return Std.is(v, BsonDocumentBase);
	
	#if (haxe_ver >= 3.3)
		@:from
		public static macro function fromObject(e:ExprOf<{}>):ExprOf<BsonDocument> {
			var exprs = [];
			switch e.expr {
				case EObjectDecl(fields):
					for(field in fields) {
						var key = field.field;
						var expr = field.expr;
						exprs.push(macro doc.add($v{key}, $expr));
					}
				case EMeta({name:':this'}, _):
					switch Context.follow(Context.typeof(e)) {
						case TAnonymous(_.get() => a):
							// sort the fields based on the pos
							a.fields.sort(function(f1, f2) {
								var p1 = parsePos(f1.pos);
								var p2 = parsePos(f2.pos);
								var r = Reflect.compare(p1.line, p2.line);
								if(r != 0) return r;
								return Reflect.compare(p1.min, p2.min);
							});
							
							exprs.push(macro var o = $e);
							for(f in a.fields){
								var key = f.name;
								exprs.push(macro doc.add($v{key}, o.$key));
							}
						default:
							throw 'assert';
					}
				case EBlock([]):
					// do nothing
				default:
					throw 'assert';
			}
			return macro @:pos(e.pos) {
				var doc = new bson.BsonDocument();
				$b{exprs};
				doc;
			};
		}
	#end
	
	static function parsePos(pos:Dynamic) {
		var s = Std.string(pos).split(':');
		var line = Std.parseInt(s[1]);
		var s = s[2].split(s[2].indexOf('lines') == -1 ? 'characters ' : 'lines ')[1].split('-');
		var min = Std.parseInt(s[0]);
		var max = Std.parseInt(s[1]);
		return {
			line: line,
			min: min,
			max: max,
		}
	}
}

class BsonDocumentBase {
	
	var items:Array<{key:String, value:Dynamic}>;
	
	public function new() {
		items = [];
	}
	
	public inline function add(key:String, value:Dynamic) {
		items.push({key:key, value:value});
	}
	
	public inline function iterator()
		return items.iterator();
		
	public inline function toString()
		return '{' + [for(i in items) '${i.key}:${i.value}'].join(',') + '}';
}
