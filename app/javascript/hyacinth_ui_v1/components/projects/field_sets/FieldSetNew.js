import React from 'react';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler';
import FieldSetForm from './FieldSetForm';

class FieldSetNew extends React.Component {
  createFieldSet = (data) => {
    hyacinthApi.post(`/projects/${this.props.match.params.string_key}/field_sets`, data)
      .then((res) => {
        this.props.history.push(`/projects/${this.props.match.params.string_key}/field_sets/${res.data.field_set.id}/edit`);
      });
  }

  render() {
    return (
      <>
        <ProjectSubHeading>Create New Field Set</ProjectSubHeading>
        <FieldSetForm submitFormAction={this.createFieldSet} submitButtonName="Create" />
      </>
    );
  }
}

export default withErrorHandler(FieldSetNew, hyacinthApi);
