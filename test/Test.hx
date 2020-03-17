import pilot.Component;
import pilot.router.*;

using pilot.router.PathTools;

class Test {

  public static function main() {
    var testPath = '/foo/:id'.createMatcher();
    switch testPath('/foo/bar') {
      case None:
      case Some(v): trace(v.params);
    }

    var history = new StaticHistory('/foo/bar');

    Pilot.mount(
      Pilot.document.getElementById('root'),
      Pilot.html(<>
        <Router root='' history={history}>
          <button onClick={_ -> history.push('/')}>Home</button>
          <button onClick={_ -> history.push('/foo/changed')}>Changed</button>
          <button onClick={_ -> history.push('/foo/barg')}>Barg</button>
          <div>
            <RouteSwitcher>
              <Route url="/foo/:id" component={FooComponent} />
              <Route url="/" component={HomeComponent} />
            </RouteSwitcher>
          </div>
        </Router>
      </>)
    );
  }

}

class HomeComponent extends Component {

  override function render() {
    return html(<>home</>);
  }

}

class FooComponent extends Component {

  @:attribute var id:String;

  override function render() {
    return html(<>The id is: {id}</>);
  }

}
