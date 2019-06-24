import React from 'react';
import { Link } from 'react-router-dom';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import { digitalObject } from '../../util/hyacinth_api';

export default class DigitalObjectSearch extends React.Component {
  state = {
    digitalObjects: [],
  }

  componentDidMount() {
    digitalObject.search()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.digitalObjects = res.data.digitalObjects;
        }));
      });
  }

  render() {
    const { digitalObjects } = this.state;
    return (
      <>
        <ContextualNavbar
          title="Digital Objects"
          rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
        />

        <h4>Rights Module Mockups</h4>

        {
          ['asset1', 'test1'].map(id => (
            <Link to={`/digital_objects/${id}/rights/edit`} key={id} className="nav-link">{id}</Link>
          ))
        }

        <hr />

        {
          digitalObjects.map(d => (
            <Link to={`/digital_objects/${d.uid}`} key={d.uid} className="nav-link">{d.uid}</Link>
          ))
        }
      </>
    );
  }
}
