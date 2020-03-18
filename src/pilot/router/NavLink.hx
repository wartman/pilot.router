package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Style;

/**
  A `Link` that marks if it's active or not.

  Note that, unlike `Link`, `NavLink` should only be used inside a
  `Switch`.
**/
class NavLink extends Component {

  @:attribute var to:String;
  @:attribute( inject = RouteContext.ID ) var context:RouteContext;
  @:attribute var children:Children;
  @:attribute @:optional var active:Style;
  @:attribute @:optional var inactive:Style;

  function getStyle() {
    return if (to == context.path) active else inactive;
  }

  override function render() return html(
    <Link to={to} style={getStyle()}>{children}</Link>
  );

}