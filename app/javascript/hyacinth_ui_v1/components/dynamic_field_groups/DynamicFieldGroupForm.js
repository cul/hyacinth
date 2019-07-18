import React from 'react';
import PropTypes from 'prop-types';
import {
  Row, Col, Form, Button, Card,
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import { LinkContainer } from 'react-router-bootstrap';
import produce from 'immer';

import CancelButton from '../layout/forms/CancelButton';
import SubmitButton from '../layout/forms/SubmitButton';
import DeleteButton from '../layout/forms/DeleteButton';
import hyacinthApi from '../../util/hyacinth_api';
import DynamicFieldsAndGroupsTable from '../layout/dynamic_fields/DynamicFieldsAndGroupsTable';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';

class DynamicFieldGroupForm extends React.Component {
  state = {
    formType: '',
    dynamicFieldCategories: [],
    dynamicFieldGroup: {
      stringKey: '',
      displayLabel: '',
      sortOrder: '',
      isRepeatable: false,
      parentType: '',
      parentId: '',
    },
    children: [],
  }

  componentDidMount() {
    const { id, formType, defaultValues } = this.props;

    if (formType === 'edit' && id) {
      hyacinthApi.get(`/dynamic_field_groups/${id}`)
        .then((res) => {
          const { dynamicFieldGroup, dynamicFieldGroup: { parentType } } = res.data;

          if (parentType === 'DynamicFieldCategory') {
            this.loadCategories();
          }

          this.setState(produce((draft) => {
            draft.formType = formType;
            draft.dynamicFieldGroup = dynamicFieldGroup; // except children
            draft.children = dynamicFieldGroup.children;
          }));
        });
    } else if (formType === 'new') {
      const { parentType, parentId } = defaultValues;

      if (parentType === 'DynamicFieldCategory') {
        this.loadCategories();
      }

      this.setState(produce((draft) => {
        draft.formType = formType;
        draft.dynamicFieldGroup.parentType = parentType || 'DynamicFieldCategory';
        draft.dynamicFieldGroup.parentId = parentId;
      }));
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { formType, dynamicFieldGroup: { id }, dynamicFieldGroup } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        hyacinthApi.post('/dynamic_field_groups', dynamicFieldGroup)
          .then((res) => {
            const { dynamicFieldGroup: { id: newId } } = res.data;

            push(`/dynamic_field_groups/${newId}/edit`);
          });
        break;
      case 'edit':
        hyacinthApi.patch(`/dynamic_field_groups/${id}`, dynamicFieldGroup)
          .then(() => push(`/dynamic_field_groups/${id}/edit`));
        break;
      default:
        break;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { id, history: { push } } = this.props;

    hyacinthApi.delete(`/dynamic_field_groups/${id}`)
      .then(() => push('/dynamic_fields'));
  }

  onChangeHandler = (event) => {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    this.setState(produce((draft) => {
      draft.dynamicFieldGroup[name] = type === 'checkbox' ? checked : value;
    }));
  }

  loadCategories() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.dynamicFieldCategories = res.data.dynamicFieldCategories.map(category => (
            { id: category.id, displayLabel: category.displayLabel }
          ));
        }));
      });
  }

  render() {
    const {
      formType,
      dynamicFieldGroup: {
        id, stringKey, displayLabel, sortOrder, isRepeatable, parentType, parentId,
      },
      dynamicFieldCategories,
      children,
    } = this.state;

    let categoriesDropdown = '';
    if (parentType === 'DynamicFieldCategory') {
      categoriesDropdown = (
        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Dynamic Field Category</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              as="select"
              name="parentId"
              value={parentId}
              onChange={this.onChangeHandler}
            >
              {
                dynamicFieldCategories.map(c => (
                  <option key={c.id} value={c.id}>{c.displayLabel}</option>
                ))
              }
            </Form.Control>
          </Col>
        </Form.Group>
      );
    }

    return (
      <Row>
        <Col sm={7}>
          <Form onSubmit={this.onSubmitHandler}>
            <Form.Group as={Row}>
              <Form.Label column sm={12} xl={3}>String Key</Form.Label>
              <Col sm={12} xl={9}>
                <Form.Control
                  type="text"
                  name="stringKey"
                  value={stringKey}
                  onChange={this.onChangeHandler}
                  disabled={formType === 'edit'}
                />
              </Col>
            </Form.Group>

            <Form.Group as={Row}>
              <Form.Label column sm={12} xl={3}>Display Label</Form.Label>
              <Col sm={12} xl={9}>
                <Form.Control
                  type="text"
                  name="displayLabel"
                  value={displayLabel}
                  onChange={this.onChangeHandler}
                />
              </Col>
            </Form.Group>

            <Form.Group as={Row}>
              <Form.Label column sm={12} xl={3}>Sort Order</Form.Label>
              <Col sm={12} xl={9}>
                <Form.Control
                  type="number"
                  name="sortOrder"
                  value={sortOrder}
                  onChange={this.onChangeHandler}
                />
              </Col>
            </Form.Group>

            {categoriesDropdown}

            <Form.Group as={Row}>
              <Form.Label column sm={12} xl={3}>Is Repeatable?</Form.Label>
              <Col sm={12} xl={9}>
                <Form.Check
                  name="isRepeatable"
                  aria-label="is repeatable option"
                  checked={isRepeatable}
                  onChange={this.onChangeHandler}
                />
              </Col>
            </Form.Group>

            <Form.Row>
              <Col sm="auto" className="mr-auto">
                <DeleteButton onClick={this.onDeleteHandler} formType={formType} />
              </Col>

              <Col sm="auto">
                <CancelButton to="/dynamic_fields" />
              </Col>

              <Col sm="auto">
                <SubmitButton onClick={this.onSubmitHandler} formType={formType} />
              </Col>
            </Form.Row>
          </Form>
        </Col>
        <Col sm={5}>
          <Card>
            <Card.Header>Child Fields and Field Groups</Card.Header>
            <Card.Body>
              <DynamicFieldsAndGroupsTable rows={children} />

              {
                formType === 'edit' && (
                  <>
                    <LinkContainer className="m-1" to={`/dynamic_fields/new?dynamicFieldGroupId=${id}`}>
                      <Button variant="secondary">New Child Field</Button>
                    </LinkContainer>

                    <LinkContainer className="m-1" to={`/dynamic_field_groups/new?parentId=${id}&parentType=DynamicFieldGroup`}>
                      <Button variant="secondary">New Child Field Group</Button>
                    </LinkContainer>
                  </>
                )
              }
            </Card.Body>
          </Card>
        </Col>
      </Row>
    );
  }
}

DynamicFieldGroupForm.defaultProps = {
  id: null,
};

DynamicFieldGroupForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  id: PropTypes.string,
};

export default withRouter(withErrorHandler(DynamicFieldGroupForm, hyacinthApi));