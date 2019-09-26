const pg = require('utils/pg')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')

const ONE_MONTH = 30 * 24 * 60 * 60 * 1000

module.exports = {
  async session_login ({ username = '', password = '' }, { res }) {
    const user = await authenticateUser({ username, password })
    const session = {
      ...user,
      roles: await getUserRoles(user)
    }

    res.cookie('refresh-token', getRefreshToken(user), { httpOnly: true, maxAge: ONE_MONTH })

    return {
      session,
      token: getAuthToken(session)
    }
  },
  async session_logout (args, { res }) {
    res.clearCookie('refresh-token')
    return true
  },
  async session_refresh (args, { req, res }) {
    const refreshToken = req.cookie['refresh-token']

    if (!refreshToken) {
      throw new Error('No refresh token')
    }

    const { username, user_id } = jwt.verify(token, process.env.AUTH_JWT_SECRET)
    const user = {
      username,
      user_id
    }
    const session = {
      ...user,
      roles: await getUserRoles(user)
    }

    res.cookie('refresh-token', getRefreshToken(user), { httpOnly: true, maxAge: ONE_MONTH })

    return {
      session,
      token: getAuthToken(session)
    }
  }
}

async function authenticateUser ({ username, password }) {
  const { rows: [ user ] } = await pg.query(/* sql */`
    SELECT user_id, username, password
    FROM account.user
    WHERE account.user.username = $1
  `, [ username ])

  if (user) {
    const valid = await bcrypt.compare(password, user.password)
    if (valid) {
      return { username, user_id: user.user_id }
    }
  }
  throw new Error('Error de authenticacion')
}

async function getUserRoles ({ user_id }) {
  const { rows: roles } = await pg.query(/* sql */`
    SELECT account.role.role_id
    FROM account.user_role
    LEFT JOIN account.role ON (account.user_role.role_id = account.role.role_id)
    WHERE user_id = $1
  `, [ user_id ])

  return roles.map(({ role_id }) => role_id).concat(['user', 'anonymous'])
}

function getRefreshToken({ username, user_id }) {
  const payload = {
    username,
    user_id
  }

  return jwt.sign(payload, process.env,AUTH_JWT_SECRET, { expiresIn: '30 days' })
}
function getAuthToken({ username, user_id, roles }) {
  const payload = {
    username,
    user_id,
    roles
  }

  return jwt.sign(payload, process.env.AUTH_JWT_SECRET, { expiresIn: '10 minutes' })
}