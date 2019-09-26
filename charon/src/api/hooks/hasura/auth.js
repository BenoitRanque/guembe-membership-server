const express = require('express')
const app = express()

const { ForbiddenError } = require('utils/errors')

const parseSession = require('middlewares/parseSession')

app.get('/', parseSession, function (req, res, next) {
  const grants = {
    Now: new Date().toISOString()
  }

  const session = req.session

  if (session) {
    const role = req.get('X-HASURA-ROLE')

    if (session.roles.includes(role)) {
      grants['ROLE'] = role
    } else {
      console.log(session)
      throw new ForbiddenError(`Unauthorized role ${role}`)
    }

    grants['User-Id'] = session.user_id
  } else {
    grants['ROLE'] = 'anonymous'
  }

  res.status(200).json(Object.keys(grants).reduce((obj, key) => {
    obj[`X-Hasura-${key}`] = grants[key]
    return obj
  }, {}))
})

module.exports = app
