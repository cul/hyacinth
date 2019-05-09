import React from 'react';
import { Route, Switch } from 'react-router-dom';

import NoMatch from '../../layout/NoMatch';
import CoreDataShow from './CoreDataShow';
import CoreDataEdit from './CoreDataEdit';

export default class CoreData extends React.Component {
  render() {
    return (
      <Switch>
        <Route exact path={`${this.props.match.path}`} component={CoreDataShow} />
        <Route path={`${this.props.match.path}/edit`} component={CoreDataEdit} />
        
        <Route component={NoMatch} />
      </Switch>
    );
  }
}
