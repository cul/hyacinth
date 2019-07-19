import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class TextInput extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { value } } = event;
    const { onChange } = this.props;

    onChange(value);
  }

  render() {
    const { inputName, value } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Form.Control
          type="text"
          name={inputName}
          value={value}
          onChange={this.onChangeHandler}
          size="sm"
        />
      </Col>
    );
  }
}

TextInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};

export default TextInput;
