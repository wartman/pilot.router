package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Provider;

class Router extends Component {

  @:attribute var root:String;
  @:attribute var children:Children;
  @:attribute var history:History;
  var routeContext:RouteContext = new RouteContext();

  override function render() return html(
    <HistoryProvider value={history}>
      {children}
    </HistoryProvider>
  );

}
