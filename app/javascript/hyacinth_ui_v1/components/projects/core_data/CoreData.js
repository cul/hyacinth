import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import CoreDataShow from './CoreDataShow';
import CoreDataEdit from './CoreDataEdit';
import ProtectedRoute from '../../ProtectedRoute';

export default class CoreData extends React.PureComponent {
  render() {
    const { match: { path } } = this.props;
    return (
      <Switch>
        <Route exact path={`${path}`} component={CoreDataShow} />

        <ProtectedRoute
          path={`${path}/edit`}
          component={CoreDataEdit}
          requiredAbility={params => (
            { action: 'update', subject: 'Project', stringKey: params.stringKey }
          )}
        />

        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
