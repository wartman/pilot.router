package pilot.router;

import pilot.Children;
import pilot.Style;
#if (js && !nodejs)
  import js.html.Event;
#end

/**
  A Link that intercepts the given URL and updates the Router.

  While `Link` must be used inside a `Router`, it does NOT need to
  be used inside a `Switch`.
**/
class Link extends Component {
  
  @:attribute var to:String;
  @:attribute var children:Children;
  #if (js && !nodejs)
    @:attribute(optional) var onClick:(e:Event)->Void;
  #else
    @:attribute(optional) var onClick:(e:Dynamic)->Void;
  #end
  @:attribute(optional) var style:Style;
  @:attribute( inject = Router.id ) var options:Router.RouterOptions;

  override function render() return html(
    <a class={style} href={to} onClick={
      onClick != null ? onClick : e -> {
        e.preventDefault();
        options.history.push(to);
      }
    }>{children}</a>
  );

}
