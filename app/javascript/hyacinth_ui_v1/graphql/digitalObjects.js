import { gql } from 'apollo-boost';

const minimalDigitalObjctProjectFields = `
  stringKey
`;

export const getMinimalDigitalObjectQuery = gql`
  query MinimalDigitalObject($id: ID!){
    digitalObject(id: $id) {
      id,
      primaryProject {
        ${minimalDigitalObjctProjectFields}
      },
      otherProjects {
        ${minimalDigitalObjctProjectFields}
      }
    }
  }
`;
