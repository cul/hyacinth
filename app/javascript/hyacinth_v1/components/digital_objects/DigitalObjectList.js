import React from 'react';
import PropTypes from 'prop-types';
import { Badge, Card } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { startCase } from 'lodash';
/*
  Display for list of Digital Objects. Have a flag to optionally display
  parents and projects. Parents and Projects are only displayed on the search
  page. Eventually, we may no longer be able to use a generalized componenet
  to display a list of digital objects.
*/

const DigitalObjectList = (props) => {
  const { digitalObjects, displayProjects, displayParentIds } = props;

  return (
    <>
      {
        digitalObjects.map(digitalObject => (
          <Card key={digitalObject.id} className="mb-3">
            <Card.Header>
              <LinkContainer to={`/digital_objects/${digitalObject.id}`}>
                <a>{digitalObject.title}</a>
              </LinkContainer>
            </Card.Header>
            <Card.Body>
              <Card.Text>
                <ul className="list-unstyled small">
                  <li>
                    <strong>ID: </strong>
                    {digitalObject.id}
                  </li>
                  {
                    digitalObject.numberOfChildren > 0 && (
                      <li>
                        <strong>Children: </strong>
                        {digitalObject.numberOfChildren}
                      </li>
                    )
                  }
                  {
                    displayParentIds && digitalObject.parentIds.length > 0 && (
                      <li>
                        <strong>Parent(s): </strong>
                        { digitalObject.parentIds.map(id => <a href={`digital_objects/${id}`}>{id}</a>) }
                      </li>
                    )
                  }
                </ul>
              </Card.Text>
              <Badge variant="secondary">{startCase(digitalObject.digitalObjectType)}</Badge>
              {
                displayProjects && digitalObject.projects.map(p => (
                  <>
                    {' '}
                    <Badge variant="primary">{p.displayLabel}</Badge>
                  </>
                ))
              }
            </Card.Body>
          </Card>
        ))
      }
    </>
  );
};

DigitalObjectList.defaultProps = {
  displayProjects: false,
  displayParentIds: false,
};

DigitalObjectList.propTypes = {
  digitalObjects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      digitalObjectType: PropTypes.string.isRequired,
      title: PropTypes.string.isRequired,
    }),
  ).isRequired,
  displayProjects: PropTypes.bool,
  displayParentIds: PropTypes.bool,
};

export default DigitalObjectList;
