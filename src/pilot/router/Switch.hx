package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Provider;
import pilot.Signal;
import pilot.VNodeValue;

/**
  The Switch provides context for active routes. When you
  set `currentUrl` it triggers a re-render and cuases all nested
  Routes to check for matches. The `currentUrl` will also be updated
  by when the provided History changes (generally supplied by a
  parent Router).

  Note that we handle switching here and not in the Router itself,
  as this allows us to only update the part of the app that needs it
  (for example, we might want a Navbar component to have access to
  the History provided by the Router, but not want it to update when the
  route changes).
**/
class Switch extends Component {

  @:attribute var children:Children;
  @:attribute var currentUrl:String = '/';
  @:attribute( inject = Router.HISTORY_ID ) var history:History;
  var historySub:SignalSubscription<String>;
  var context:RouteContext = new RouteContext();

  @:init
  function subscribeToHistory() {
    __attrs.currentUrl = history.getLocation();
    historySub = history.subscribe(setCurrentUrl);
  }

  @:dispose
  function disconnectFromHistory() {
    historySub.cancel();
  }

  @:update
  public function setCurrentUrl(url:String) {
    return { currentUrl: url };
  }

  override function render() {
    context.setPath(currentUrl);
    return html(
      <Provider id={RouteContext.ID} value={context}>
        {children}
      </Provider>
    );
  }

}
