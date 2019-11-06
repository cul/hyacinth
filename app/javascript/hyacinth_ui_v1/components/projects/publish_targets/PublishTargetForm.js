import React, { useState } from 'react';
import { Form, Collapse } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import InputGroup from '../../ui/forms/InputGroup';
import Label from '../../ui/forms/Label';
import FormButtons from '../../ui/forms/FormButtons';
import NumberInput from '../../ui/forms/inputs/NumberInput';
import TextInput from '../../ui/forms/inputs/TextInput';
import Checkbox from '../../ui/forms/inputs/Checkbox';
import {
  createPublishTargetMutation,
  updatePublishTargetMutation,
  deletePublishTargetMutation,
} from '../../../graphql/publishTargets';
import GraphQLErrors from '../../ui/GraphQLErrors';

function PublishTargetForm({ projectStringKey, publishTarget, formType }) {
  const [stringKey, setStringKey] = useState(publishTarget ? publishTarget.stringKey : '');
  const [displayLabel, setDisplayLabel] = useState(publishTarget ? publishTarget.displayLabel : '');
  const [publishUrl, setPublishUrl] = useState(publishTarget ? publishTarget.publishUrl : '');
  const [apiKey, setApiKey] = useState(publishTarget ? publishTarget.apiKey : '');
  const [isAllowedDoiTarget, setIsAllowedDoiTarget] = useState(publishTarget ? publishTarget.isAllowedDoiTarget : false);
  const [doiPriority, setDoiPriority] = useState(publishTarget ? publishTarget.doiPriority : 100);

  const [createPublishTarget, { error: createError }] = useMutation(createPublishTargetMutation);
  const [updatePublishTarget, { error: updateError }] = useMutation(updatePublishTargetMutation);
  const [deletePublishTarget, { error: deleteError }] = useMutation(deletePublishTargetMutation);

  const history = useHistory();

  const onSaveHandler = () => {
    const variables = {
      input: {
        projectStringKey, stringKey, displayLabel, publishUrl, apiKey, isAllowedDoiTarget, doiPriority,
      },
    };

    switch (formType) {
      case 'new':
        return createPublishTarget({ variables }).then((res) => {
          history.push(`/projects/${projectStringKey}/publish_targets/${res.data.createPublishTarget.publishTarget.stringKey}/edit`);
        });
      case 'edit':
        return updatePublishTarget({ variables }).then(() => {
          history.push(`/projects/${projectStringKey}/publish_targets`);
        });
      default:
        return null;
    }
  };

  const onDeleteHandler = (e) => {
    e.preventDefault();

    const variables = { input: { projectStringKey, stringKey: publishTarget.stringKey } };

    deletePublishTarget({ variables }).then(() => {
      history.push(`/projects/${projectStringKey}/publish_targets`);
    });
  };

  return (
    <Form onSubmit={onSaveHandler}>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>String Key</Label>
        <TextInput value={stringKey} onChange={v => setStringKey(v)} disabled={formType === 'edit'} />
      </InputGroup>

      <InputGroup>
        <Label>Display Label</Label>
        <TextInput value={displayLabel} onChange={v => setDisplayLabel(v)} />
      </InputGroup>

      <InputGroup>
        <Label>Publish URL</Label>
        <TextInput value={publishUrl} onChange={v => setPublishUrl(v)} />
      </InputGroup>

      <InputGroup>
        <Label>API Key</Label>
        <TextInput value={apiKey} onChange={v => setApiKey(v)} />
      </InputGroup>

      <InputGroup>
        <Label>Allowed to be set as DOI target?</Label>
        <Checkbox value={isAllowedDoiTarget} onChange={v => setIsAllowedDoiTarget(v)} />
      </InputGroup>

      <Collapse in={isAllowedDoiTarget}>
        <div>
          <InputGroup>
            <Label>DOI Priority</Label>
            <NumberInput value={doiPriority} onChange={v => setDoiPriority(v)} />
          </InputGroup>
        </div>
      </Collapse>

      <FormButtons
        formType={formType}
        cancelTo={`/projects/${projectStringKey}/publish_targets`}
        onSave={onSaveHandler}
        onDelete={onDeleteHandler}
      />
    </Form>
  );
}

export default PublishTargetForm;
