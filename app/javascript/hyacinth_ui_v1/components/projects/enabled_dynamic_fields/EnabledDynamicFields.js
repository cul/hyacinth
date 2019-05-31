import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import ProtectedRoute from '../../ProtectedRoute';

import EnabledDynamicFieldEdit from './EnabledDynamicFieldEdit';
import EnabledDynamicFieldShow from './EnabledDynamicFieldShow';

export default class EnabledDynamicFields extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          <Route
            exact
            path="/projects/:projectStringKey/enabled_dynamic_fields/:digitalObjectType"
            component={EnabledDynamicFieldShow}
          />

          <ProtectedRoute
            path="/projects/:projectStringKey/enabled_dynamic_fields/:digitalObjectType/edit"
            component={EnabledDynamicFieldEdit}
            requiredAbility={params => (
              { action: 'manage', subject: 'Project', project: { stringKey: params.projectStringKey } }
            )}
          />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
