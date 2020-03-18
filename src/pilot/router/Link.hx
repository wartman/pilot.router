package pilot.router;

import pilot.Children;
import pilot.Style;

/**
  A Link that intercepts the given URL and updates the Router.

  While `Link` must be used inside a `Router`, it does NOT need to
  be used inside a `Switch`.
**/
class Link extends Component {
  
  @:attribute var to:String;
  @:attribute var children:Children;
  @:attribute @:optional var style:Style;
  @:attribute( inject = Router.HISTORY_ID ) var history:History;

  override function render() return html(
    <a class={style} href={to} onClick={e -> {
      e.preventDefault();
      history.push(to);
    }}>{children}</a>
  );

}
