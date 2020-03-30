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

    var history = new BroswerHistory();

    Pilot.mount(
      Pilot.document.getElementById('root'),
      Pilot.html(<>
        <Router history={history}>
          <Link to='/'>Home</Link>
          <Link to='/func'>Func</Link>
          <Link to='/foo/changed'>Changed</Link>
          <Link to='/foo/barg'>Barg</Link>
          <div>
            <Switch>
              <Route url='/' to={HomeComponent} />
              <Route url='/func' to={_ -> <p>Works</p>} />
              <Route url="/foo/:id" to={FooComponent} />
              <p>You can stick any component in \<Switch />, just be aware that they will be re-rendered every time the history changes.</p>
            </Switch>
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

  // Attributes will be mapped directly to route params
  // when used as the `Route#component` argument.
  @:attribute var id:String;

  override function render() {
    return html(<>The id is: {id}</>);
  }

}
