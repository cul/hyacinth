import React from 'react';
import { Link } from 'react-router-dom';

import ContextualNavbar from '../layout/ContextualNavbar';

export default class DigitalObjectEdit extends React.Component {
  render() {
    return (
      <div>
        <ContextualNavbar lefthandLabel="&laquo; Leave Editing Mode" lefthandLabelLink="/digital-objects/:uuid">
          <Link to="/digital-objects/:uuid/delete" className="nav-link" href="#">Delete</Link>
        </ContextualNavbar>
        Edit!
      </div>
    );
  }
}
