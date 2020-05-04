package pilot.router;

import haxe.DynamicAccess;
import haxe.ds.Option;

typedef PathMatcher = (path:String) -> Option<{ 
  path:String, 
  params:DynamicAccess<Dynamic> 
}>;
