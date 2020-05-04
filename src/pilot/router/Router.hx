package pilot.router;

import pilot.State;
import pilot.Children;

/**
  The Router provides context for nested Routes and
  Links. It should be on the top-level of your app.
**/
class Router extends State {

  @:attribute var history:History;
  @:attribute var basename:String = '';

}
