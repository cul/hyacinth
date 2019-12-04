import React, { useState } from 'react';
import { Col, Form, Button } from 'react-bootstrap';
import { gql } from 'apollo-boost';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import ContextualNavbar from '../layout/ContextualNavbar';
import GraphQLErrors from '../ui/GraphQLErrors';

const CREATE_PROJECT = gql`
  mutation CreateProject($input: CreateProjectInput!) {
    createProject(input: $input) {
      project {
        stringKey
      }
    }
  }
`;

function ProjectNew() {
  const [stringKey, setStringKey] = useState('');
  const [displayLabel, setDisplayLabel] = useState('');
  const [projectUrl, setProjectUrl] = useState('');
  const [isPrimary, setIsPrimary] = useState(false);

  const [createProject, { error }] = useMutation(CREATE_PROJECT);
  const history = useHistory();

  const handleSubmit = (e) => {
    e.preventDefault();
    createProject({
      variables: {
        input: {
          stringKey,
          displayLabel,
          projectUrl,
          isPrimary
        },
      },
    }).then((res) => {
      history.push(`/projects/${res.data.createProject.project.stringKey}/core_data/edit`);
    });
  };

  return (
    <>
      <ContextualNavbar
        title="Create New Project"
        rightHandLinks={[{ link: '/projects', label: 'Cancel' }]}
      />

      <GraphQLErrors errors={error} />

      <Form onSubmit={handleSubmit}>
        <Form.Row>
          <Form.Group as={Col} sm={6}>
            <Form.Label>String Key</Form.Label>
            <Form.Control
              type="text"
              name="stringKey"
              value={stringKey}
              onChange={e => setStringKey(e.target.value)}
            />
          </Form.Group>

          <Form.Group as={Col} sm={6}>
            <Form.Label>Display Label</Form.Label>
            <Form.Control
              type="text"
              name="displayLabel"
              value={displayLabel}
              onChange={e => setDisplayLabel(e.target.value)}
            />
          </Form.Group>
        </Form.Row>

        <Form.Row>
          <Form.Group as={Col}>
            <Form.Label>Project URL</Form.Label>
            <Form.Control
              type="text"
              name="projectUrl"
              value={projectUrl}
              onChange={e => setProjectUrl(e.target.value)}
            />
          </Form.Group>
        </Form.Row>

        <Form.Row>
          <Form.Group as={Col}>
            <Form.Label>Is Primary?</Form.Label>
            <Form.Control
              type="checkbox"
              name="isPrimary"
              value={isPrimary}
              onChange={e => setIsPrimary(e.target.checked)}
            />
          </Form.Group>
        </Form.Row>

        <Button variant="primary" type="submit" onClick={handleSubmit}>Create</Button>
      </Form>
    </>
  );
}

export default ProjectNew;
