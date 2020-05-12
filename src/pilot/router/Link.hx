package pilot.router;

import pilot.Children;
import pilot.Style;
#if (js && !nodejs)
  import js.html.Event;
#end

/**
  A Link that intercepts the given URL and updates the Router.

  While `Link` must be used inside a `Router`, it does NOT need to
  be used inside a `Switch`. Also note that `Link` components will
  use the basename of the `Switch` or `Router` they are wrapped in.
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
  @:attribute(consume) var router:Router;
  @:attribute(consume, optional) var context:Switch;
  @:computed var parsedPath:String = if (context != null) {
    context.preparePath(to);
  } else {
    router.preparePath(to);
  }

  override function render() return html(
    <a class={style} href={parsedPath} onClick={
      onClick != null ? onClick : e -> {
        e.preventDefault();
        router.history.push(parsedPath);
      }
    }>{children}</a>
  );

}
