import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class ReadOnlyInput extends React.PureComponent {
  render() {
    const { value } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }}>
        <Form.Control
          type="text"
          value={value}
          readOnly
          disabled
        />
      </Col>
    );
  }
}

ReadOnlyInput.propTypes = {
  value: PropTypes.string.isRequired,
};

export default ReadOnlyInput;
