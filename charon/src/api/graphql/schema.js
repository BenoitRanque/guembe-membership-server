const { buildSchema } = require('graphql')

// Construct a schema, using GraphQL schema language
const schema = buildSchema(/* GraphQL */`
  scalar uuid

  type Session {
    user_id: uuid!
    username: String!
    name: String
    roles: [String!]!
  }

  type Auth {
    token: String!
    session: Session!
  }

  type Query {
    session_login (username: String! password: String!): Auth!
    session_logout: Boolean!
    session_refresh: Auth!
  }
`)

module.exports = schema