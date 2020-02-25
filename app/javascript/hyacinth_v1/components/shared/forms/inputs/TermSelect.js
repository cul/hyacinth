import React from 'react';
import PropTypes from 'prop-types';
import { Col, Dropdown } from 'react-bootstrap';

import TermMenu from './term_select/TermMenu';
import RemoveButton from '../../buttons/RemoveButton';

function TermSelect(props) {
  const {
    name, value, vocabulary, onChange,
  } = props;

  let prefLabel = null;
  if (value) {
    prefLabel = value.pref_label || value.prefLabel || null;
  }

  return (
    <Col sm={8} style={{ alignSelf: 'center' }}>
      <Dropdown name={name} drop="right">
        <Dropdown.Toggle size="sm" variant="outline-secondary">
          { prefLabel || 'Select one...' }
        </Dropdown.Toggle>

        {
          prefLabel && (
            <RemoveButton onClick={() => onChange({})} />
          )
        }

        <Dropdown.Menu
          as={TermMenu}
          vocabulary={vocabulary}
          onChange={onChange}
        />
      </Dropdown>
    </Col>
  );
}

TermSelect.defaultProps = {
  name: '',
};

TermSelect.propTypes = {
  vocabulary: PropTypes.string.isRequired,
  value: PropTypes.shape({
    pref_label: PropTypes.string,
    uri: PropTypes.string,
  }).isRequired,
  onChange: PropTypes.func.isRequired,
  name: PropTypes.string,
};

export default TermSelect;
