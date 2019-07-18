import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import {
  snakeCase, lowerFirst, words, last,
} from 'lodash';
import { withRouter } from 'react-router-dom';

import hyacinthApi from '../../../util/hyacinth_api';
import EditButton from '../../ui/buttons/EditButton';
import UpArrowButton from '../../ui/buttons/UpArrowButton';
import DownArrowButton from '../../ui/buttons/DownArrowButton';

class DynamicFieldsAndGroupsTable extends React.PureComponent {
  updateSortOrder(type, id, sortOrder) {
    const data = { [lowerFirst(type)]: { sortOrder } };
    const { history: { push }, onChange } = this.props;

    hyacinthApi.patch(`/${snakeCase(type)}s/${id}`, data)
      .then(() => onChange());
  }

  render() {
    const { rows, ...rest } = this.props;

    let body = null;

    if (!Array.isArray(rows) || !rows.length) {
      body = <p>Child elements have not been defined.</p>;
    } else {
      body = (
        <Table hover borderless {...rest}>
          <tbody>
            {
              rows.map((fieldOrGroup, index) => {
                const sortUp = (index === 0) ? null : Math.max(0, rows[index - 1].sortOrder - 1);
                const sortDown = (index === rows.length - 1) ? null : rows[index + 1].sortOrder + 1;

                const { displayLabel, id, type } = fieldOrGroup;

                return (
                  <tr key={`${type}_${id}`}>
                    <td><span className="badge badge-secondary">{last(words(type))}</span></td>
                    <td>{displayLabel}</td>
                    <td>
                      <UpArrowButton
                        variant="outline-secondary"
                        onClick={() => this.updateSortOrder(type, id, sortUp)}
                        disabled={sortUp === null}
                      />
                      <DownArrowButton
                        variant="outline-secondary"
                        onClick={() => this.updateSortOrder(type, id, sortDown)}
                        disabled={sortDown === null}
                      />
                    </td>
                    <td>
                      <EditButton link={`/${snakeCase(type)}s/${id}/edit`} />
                    </td>
                  </tr>
                );
              })
            }
          </tbody>
        </Table>
      );
    }
    return (body);
  }
}

DynamicFieldsAndGroupsTable.defaultProps = {
  rows: [],
};

DynamicFieldsAndGroupsTable.propTypes = {
  rows: PropTypes.arrayOf(
    PropTypes.shape({
      displayLabel: PropTypes.string.isRequired,
      id: PropTypes.number.isRequired,
      type: PropTypes.string.isRequired,
      sortOrder: PropTypes.number.isRequired,
    }),
  ),
};

export default withRouter(DynamicFieldsAndGroupsTable);