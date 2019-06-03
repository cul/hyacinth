import React from 'react';
import { Link } from 'react-router-dom';
import { Card } from 'react-bootstrap';
import produce from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import DynamicFieldsAndGroupsTable from '../layout/dynamic_fields/DynamicFieldsAndGroupsTable';

export default class DynamicFieldIndex extends React.Component {
  state = {
    dynamicFieldGraphs: [],
  }

  componentDidMount() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.dynamicFieldGraphs = res.data.dynamicFieldCategories;
        }));
      });
  }

  renderCategories() {
    const { dynamicFieldGraphs } = this.state;

    return (
      dynamicFieldGraphs.map((dynamicFieldCategory) => {
        const { id, displayLabel, children } = dynamicFieldCategory;

        return (
          <Card className="mb-3" key={id} id={displayLabel.replace(' ', '-')}>
            <Card.Header as="h5">
              {displayLabel}
              {' '}
              <Link to={`/dynamic_field_categories/${id}/edit`}><FontAwesomeIcon icon="pen" /></Link>
              <span className="badge badge-secondary float-right">Category</span>
            </Card.Header>
            <Card.Body>
              <DynamicFieldsAndGroupsTable rows={children} />

              <Card.Text className="text-center">
                <Link
                  to={`/dynamic_field_groups/new?parentType=DynamicFieldCategory&parentId=${id}`}
                >
                  <FontAwesomeIcon icon="plus" />
                  {' '}
New Dynamic Field Group
                </Link>
              </Card.Text>
            </Card.Body>
          </Card>
        );
      })
    );
  }

  render() {
    return (
      <>
        <ContextualNavbar
          title="Dynamic Fields"
          rightHandLinks={[{ link: '/dynamic_field_categories/new', label: 'New Dynamic Field Category' }]}
        />

        {this.renderCategories()}
      </>
    );
  }
}
