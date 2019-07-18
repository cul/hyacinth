import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import produce from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

import TabHeading from '../../ui/tabs/TabHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import { Can } from '../../../util/ability_context';

export default class FieldSetIndex extends React.Component {
  state = {
    publishTargets: [],
  }

  componentDidMount() {
    hyacinthApi.get(`/projects/${this.props.match.params.projectStringKey}/publish_targets`)
      .then((res) => {
        this.setState(produce((draft) => { draft.publishTargets = res.data.publishTargets; }));
      });
  }

  render() {
    const { params: { projectStringKey } } = this.props.match;

    let rows = <tr><td colSpan="4">No publish targets have been defined</td></tr>;

    if (this.state.publishTargets.length > 0) {
      rows = this.state.publishTargets.map(publishTarget => (
        <tr key={publishTarget.stringKey}>

          <td>
            <Can I="edit" of={{ subjectType: 'PublishTarget', project: { stringKey: projectStringKey } }} passThrough>
              {
                  can => (
                    can
                      ? <Link to={`/projects/${projectStringKey}/publish_targets/${publishTarget.stringKey}/edit`}>{publishTarget.displayLabel}</Link>
                      : publishTarget.displayLabel
                  )
                }
            </Can>
          </td>
          <td>{publishTarget.stringKey}</td>
          <td>{publishTarget.publishUrl}</td>
          <td>{publishTarget.apiKey}</td>
        </tr>
      ));
    }

    return (
      <>
        <TabHeading>Publish Targets</TabHeading>

        <Table hover>
          <thead>
            <tr>
              <th>Display Label</th>
              <th>String Key</th>
              <th>Publish URL</th>
              <th>API Key</th>
            </tr>
          </thead>
          <tbody>
            {rows}
            <Can I="PublishTarget" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }}>
              <tr>
                <td className="text-center" colSpan="4">
                  <LinkContainer to={`/projects/${projectStringKey}/publish_targets/new`}>
                    <Button size="sm" variant="link">
                      <FontAwesomeIcon icon="plus" />
                      {' '}
  Add New Publish Target
                    </Button>
                  </LinkContainer>
                </td>
              </tr>
            </Can>
          </tbody>
        </Table>
      </>
    );
  }
}