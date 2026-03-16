# AUTH_IMPLEMENTATION

**Status**: Active | Domain: Feature  
**Related Modules**: API_DESIGN, DATABASE_SCHEMA, SECURITY_CHECKLIST, BACKEND_PATTERNS

## Purpose

This module provides comprehensive guidance for implementing authentication and authorization in applications. It covers industry-standard authentication methods (passwords, OAuth, JWT, sessions), authorization patterns (RBAC, ABAC), security best practices, and framework-specific implementations. Use this module to build secure, scalable authentication systems that protect user data and application resources.

## When to Use This Module

Reference this module when:
- Implementing user authentication for the first time
- Adding social login (OAuth 2.0) to your application
- Designing role-based or attribute-based authorization
- Migrating from session-based to token-based authentication
- Conducting security reviews of existing authentication systems
- Implementing passwordless authentication flows
- Building API authentication for mobile/SPA clients
- Adding multi-factor authentication (MFA)
- Troubleshooting authentication vulnerabilities

## Authentication Methods

### Password-Based Authentication

**Core Implementation:**

```typescript
// User model with secure password storage
interface User {
  id: string;
  email: string;
  passwordHash: string; // Never store plain passwords
  salt: string;
  createdAt: Date;
  lastLogin: Date;
}

// Registration with bcrypt (cost factor 12-14)
import bcrypt from 'bcrypt';

async function registerUser(email: string, password: string): Promise<User> {
  // Validate password strength
  if (!isStrongPassword(password)) {
    throw new Error('Password does not meet security requirements');
  }
  
  const saltRounds = 12; // Higher = more secure but slower
  const passwordHash = await bcrypt.hash(password, saltRounds);
  
  const user = await db.users.create({
    email,
    passwordHash,
    createdAt: new Date()
  });
  
  return user;
}

// Login with timing-safe comparison
async function loginUser(email: string, password: string): Promise<Session> {
  const user = await db.users.findByEmail(email);
  
  if (!user) {
    // Use timing-safe rejection to prevent user enumeration
    await bcrypt.hash(password, 12); // Dummy operation
    throw new Error('Invalid credentials');
  }
  
  const isValid = await bcrypt.compare(password, user.passwordHash);
  
  if (!isValid) {
    throw new Error('Invalid credentials');
  }
  
  // Update last login
  await db.users.update(user.id, { lastLogin: new Date() });
  
  return createSession(user);
}
```

**Password Strength Validation:**

```typescript
function isStrongPassword(password: string): boolean {
  // Minimum requirements
  const minLength = 12;
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumber = /\d/.test(password);
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
  
  return (
    password.length >= minLength &&
    hasUppercase &&
    hasLowercase &&
    hasNumber &&
    hasSpecial
  );
}

// Optional: Check against common password lists
import { pwnedPassword } from 'hibp'; // Have I Been Pwned API

async function isPasswordCompromised(password: string): Promise<boolean> {
  const count = await pwnedPassword(password);
  return count > 0;
}
```

**Password Reset Flow:**

```typescript
// Generate secure reset token
import crypto from 'crypto';

async function initiatePasswordReset(email: string): Promise<void> {
  const user = await db.users.findByEmail(email);
  
  if (!user) {
    // Don't reveal whether email exists (timing-safe)
    return; // Still return success to prevent enumeration
  }
  
  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetTokenHash = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');
  
  await db.passwordResets.create({
    userId: user.id,
    tokenHash: resetTokenHash,
    expiresAt: new Date(Date.now() + 3600000) // 1 hour
  });
  
  await sendEmail({
    to: user.email,
    subject: 'Password Reset',
    body: `Reset your password: ${process.env.APP_URL}/reset?token=${resetToken}`
  });
}

// Verify and reset password
async function resetPassword(token: string, newPassword: string): Promise<void> {
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  
  const resetRecord = await db.passwordResets.findByToken(tokenHash);
  
  if (!resetRecord || resetRecord.expiresAt < new Date()) {
    throw new Error('Invalid or expired reset token');
  }
  
  if (!isStrongPassword(newPassword)) {
    throw new Error('Password does not meet security requirements');
  }
  
  const passwordHash = await bcrypt.hash(newPassword, 12);
  
  await db.users.update(resetRecord.userId, { passwordHash });
  await db.passwordResets.delete(resetRecord.id);
  
  // Invalidate all existing sessions for this user
  await db.sessions.deleteByUserId(resetRecord.userId);
}
```

### Session-Based Authentication

**Server-Side Session Storage:**

```typescript
// Session model
interface Session {
  id: string;
  userId: string;
  token: string; // Random session identifier
  expiresAt: Date;
  createdAt: Date;
  ipAddress: string;
  userAgent: string;
}

// Create session after successful login
async function createSession(user: User, req: Request): Promise<string> {
  const sessionToken = crypto.randomBytes(32).toString('hex');
  
  const session = await db.sessions.create({
    userId: user.id,
    token: sessionToken,
    expiresAt: new Date(Date.now() + 86400000), // 24 hours
    createdAt: new Date(),
    ipAddress: req.ip,
    userAgent: req.headers['user-agent']
  });
  
  return sessionToken;
}

// Express middleware for session authentication
function requireAuth(req: Request, res: Response, next: NextFunction) {
  const sessionToken = req.cookies.sessionToken;
  
  if (!sessionToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  const session = await db.sessions.findByToken(sessionToken);
  
  if (!session || session.expiresAt < new Date()) {
    return res.status(401).json({ error: 'Session expired' });
  }
  
  // Attach user to request
  req.user = await db.users.findById(session.userId);
  
  // Refresh session expiration (sliding window)
  await db.sessions.update(session.id, {
    expiresAt: new Date(Date.now() + 86400000)
  });
  
  next();
}

// Secure cookie configuration
app.use(cookieParser());

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await loginUser(email, password);
  const sessionToken = await createSession(user, req);
  
  res.cookie('sessionToken', sessionToken, {
    httpOnly: true,     // Prevent JavaScript access
    secure: true,       // HTTPS only
    sameSite: 'strict', // CSRF protection
    maxAge: 86400000    // 24 hours
  });
  
  res.json({ user: { id: user.id, email: user.email } });
});

app.post('/logout', requireAuth, async (req, res) => {
  const sessionToken = req.cookies.sessionToken;
  await db.sessions.deleteByToken(sessionToken);
  res.clearCookie('sessionToken');
  res.json({ message: 'Logged out successfully' });
});
```

### JWT (JSON Web Token) Authentication

**Token Generation and Verification:**

```typescript
import jwt from 'jsonwebtoken';

interface JWTPayload {
  userId: string;
  email: string;
  role: string;
  iat: number; // Issued at
  exp: number; // Expiration
}

// Generate access and refresh tokens
function generateTokens(user: User): { accessToken: string; refreshToken: string } {
  const accessToken = jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role
    },
    process.env.JWT_SECRET!,
    { expiresIn: '15m' } // Short-lived access token
  );
  
  const refreshToken = jwt.sign(
    { userId: user.id },
    process.env.JWT_REFRESH_SECRET!,
    { expiresIn: '7d' } // Longer-lived refresh token
  );
  
  return { accessToken, refreshToken };
}

// Store refresh token in database for revocation capability
async function storeRefreshToken(userId: string, token: string): Promise<void> {
  await db.refreshTokens.create({
    userId,
    token,
    expiresAt: new Date(Date.now() + 7 * 86400000)
  });
}

// JWT authentication middleware
function requireJWT(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid authorization header' });
  }
  
  const token = authHeader.substring(7);
  
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;
    req.user = payload;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// Token refresh endpoint
app.post('/auth/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  
  if (!refreshToken) {
    return res.status(401).json({ error: 'Refresh token required' });
  }
  
  try {
    const payload = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET!) as { userId: string };
    
    // Check if refresh token is in database (not revoked)
    const storedToken = await db.refreshTokens.findByToken(refreshToken);
    if (!storedToken) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }
    
    const user = await db.users.findById(payload.userId);
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);
    
    // Rotate refresh token
    await db.refreshTokens.delete(storedToken.id);
    await storeRefreshToken(user.id, newRefreshToken);
    
    res.json({ accessToken, refreshToken: newRefreshToken });
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired refresh token' });
  }
});
```

**JWT Best Practices:**

```typescript
// Include security claims
function generateSecureJWT(user: User, req: Request): string {
  return jwt.sign(
    {
      // Standard claims
      sub: user.id,           // Subject
      iat: Math.floor(Date.now() / 1000), // Issued at
      exp: Math.floor(Date.now() / 1000) + 900, // Expires in 15 min
      
      // Custom claims
      email: user.email,
      role: user.role,
      
      // Security claims
      jti: crypto.randomUUID(), // JWT ID for revocation
      aud: 'myapp.com',         // Audience
      iss: 'myapp.com'          // Issuer
    },
    process.env.JWT_SECRET!,
    { algorithm: 'HS256' }      // Explicitly specify algorithm
  );
}

// Verify with strict options
function verifyJWT(token: string): JWTPayload {
  return jwt.verify(token, process.env.JWT_SECRET!, {
    algorithms: ['HS256'],      // Prevent algorithm confusion attacks
    audience: 'myapp.com',
    issuer: 'myapp.com',
    maxAge: '15m'
  }) as JWTPayload;
}
```

### OAuth 2.0 Social Login

**Google OAuth Implementation:**

```typescript
import { OAuth2Client } from 'google-auth-library';

const googleClient = new OAuth2Client({
  clientId: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  redirectUri: `${process.env.APP_URL}/auth/google/callback`
});

// Initiate OAuth flow
app.get('/auth/google', (req, res) => {
  const authUrl = googleClient.generateAuthUrl({
    access_type: 'offline',
    scope: ['profile', 'email'],
    state: crypto.randomBytes(16).toString('hex') // CSRF protection
  });
  
  // Store state in session for verification
  req.session.oauthState = authUrl.state;
  
  res.redirect(authUrl);
});

// Handle OAuth callback
app.get('/auth/google/callback', async (req, res) => {
  const { code, state } = req.query;
  
  // Verify state parameter (CSRF protection)
  if (state !== req.session.oauthState) {
    return res.status(400).json({ error: 'Invalid state parameter' });
  }
  
  try {
    // Exchange code for tokens
    const { tokens } = await googleClient.getToken(code as string);
    googleClient.setCredentials(tokens);
    
    // Verify ID token and extract user info
    const ticket = await googleClient.verifyIdToken({
      idToken: tokens.id_token!,
      audience: process.env.GOOGLE_CLIENT_ID
    });
    
    const payload = ticket.getPayload();
    
    if (!payload) {
      throw new Error('Invalid token payload');
    }
    
    // Find or create user
    let user = await db.users.findByEmail(payload.email!);
    
    if (!user) {
      user = await db.users.create({
        email: payload.email!,
        name: payload.name,
        avatarUrl: payload.picture,
        provider: 'google',
        providerId: payload.sub
      });
    }
    
    // Create session
    const sessionToken = await createSession(user, req);
    
    res.cookie('sessionToken', sessionToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'strict'
    });
    
    res.redirect('/dashboard');
  } catch (error) {
    console.error('OAuth error:', error);
    res.redirect('/login?error=oauth_failed');
  }
});
```

**Generic OAuth 2.0 Client:**

```typescript
class OAuth2Provider {
  constructor(
    private config: {
      clientId: string;
      clientSecret: string;
      authorizationUrl: string;
      tokenUrl: string;
      userInfoUrl: string;
      redirectUri: string;
      scope: string[];
    }
  ) {}
  
  getAuthorizationUrl(state: string): string {
    const params = new URLSearchParams({
      client_id: this.config.clientId,
      redirect_uri: this.config.redirectUri,
      response_type: 'code',
      scope: this.config.scope.join(' '),
      state
    });
    
    return `${this.config.authorizationUrl}?${params}`;
  }
  
  async exchangeCodeForToken(code: string): Promise<any> {
    const response = await fetch(this.config.tokenUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
        redirect_uri: this.config.redirectUri
      })
    });
    
    return response.json();
  }
  
  async getUserInfo(accessToken: string): Promise<any> {
    const response = await fetch(this.config.userInfoUrl, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    
    return response.json();
  }
}
```

### Passwordless Authentication

**Magic Link Implementation:**

```typescript
// Generate and send magic link
async function sendMagicLink(email: string): Promise<void> {
  const user = await db.users.findByEmail(email);
  
  if (!user) {
    // Create user on-the-fly for passwordless systems
    user = await db.users.create({ email });
  }
  
  const token = crypto.randomBytes(32).toString('hex');
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  
  await db.magicLinks.create({
    userId: user.id,
    tokenHash,
    expiresAt: new Date(Date.now() + 900000) // 15 minutes
  });
  
  const magicLink = `${process.env.APP_URL}/auth/verify?token=${token}`;
  
  await sendEmail({
    to: user.email,
    subject: 'Your magic login link',
    body: `Click here to log in: ${magicLink}\n\nThis link expires in 15 minutes.`
  });
}

// Verify magic link and create session
app.get('/auth/verify', async (req, res) => {
  const { token } = req.query;
  
  if (!token) {
    return res.redirect('/login?error=invalid_token');
  }
  
  const tokenHash = crypto.createHash('sha256').update(token as string).digest('hex');
  
  const magicLink = await db.magicLinks.findByToken(tokenHash);
  
  if (!magicLink || magicLink.expiresAt < new Date()) {
    return res.redirect('/login?error=expired_token');
  }
  
  const user = await db.users.findById(magicLink.userId);
  const sessionToken = await createSession(user, req);
  
  // Invalidate magic link after use
  await db.magicLinks.delete(magicLink.id);
  
  res.cookie('sessionToken', sessionToken, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  });
  
  res.redirect('/dashboard');
});
```

**OTP (One-Time Password) via SMS/Email:**

```typescript
import speakeasy from 'speakeasy';

// Generate and send OTP
async function sendOTP(userId: string, method: 'sms' | 'email'): Promise<void> {
  const user = await db.users.findById(userId);
  
  const otp = speakeasy.totp({
    secret: process.env.OTP_SECRET!,
    encoding: 'base32',
    digits: 6,
    step: 300 // Valid for 5 minutes
  });
  
  // Store OTP hash (not plain OTP)
  const otpHash = crypto.createHash('sha256').update(otp).digest('hex');
  
  await db.otps.create({
    userId,
    otpHash,
    expiresAt: new Date(Date.now() + 300000)
  });
  
  if (method === 'email') {
    await sendEmail({
      to: user.email,
      subject: 'Your verification code',
      body: `Your code: ${otp}\n\nValid for 5 minutes.`
    });
  } else {
    await sendSMS({
      to: user.phone,
      body: `Your verification code: ${otp}`
    });
  }
}

// Verify OTP
async function verifyOTP(userId: string, otp: string): Promise<boolean> {
  const otpHash = crypto.createHash('sha256').update(otp).digest('hex');
  
  const record = await db.otps.findByUserAndHash(userId, otpHash);
  
  if (!record || record.expiresAt < new Date()) {
    return false;
  }
  
  await db.otps.delete(record.id);
  return true;
}
```

## Authorization Patterns

### Role-Based Access Control (RBAC)

**Role and Permission Model:**

```typescript
interface Role {
  id: string;
  name: string; // 'admin', 'editor', 'viewer'
  permissions: Permission[];
}

interface Permission {
  id: string;
  resource: string;   // 'posts', 'users', 'settings'
  action: string;     // 'create', 'read', 'update', 'delete'
  conditions?: object; // Optional conditions
}

interface UserRole {
  userId: string;
  roleId: string;
  grantedAt: Date;
}

// Check if user has permission
async function hasPermission(
  userId: string,
  resource: string,
  action: string
): Promise<boolean> {
  const userRoles = await db.userRoles.findByUserId(userId);
  const roleIds = userRoles.map(ur => ur.roleId);
  
  const roles = await db.roles.findByIds(roleIds);
  
  for (const role of roles) {
    const hasPermission = role.permissions.some(
      p => p.resource === resource && p.action === action
    );
    
    if (hasPermission) {
      return true;
    }
  }
  
  return false;
}

// Authorization middleware
function requirePermission(resource: string, action: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    const allowed = await hasPermission(req.user.id, resource, action);
    
    if (!allowed) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    
    next();
  };
}

// Usage
app.get('/posts', requireAuth, requirePermission('posts', 'read'), async (req, res) => {
  const posts = await db.posts.findAll();
  res.json(posts);
});

app.post('/posts', requireAuth, requirePermission('posts', 'create'), async (req, res) => {
  const post = await db.posts.create(req.body);
  res.json(post);
});

app.delete('/posts/:id', requireAuth, requirePermission('posts', 'delete'), async (req, res) => {
  await db.posts.delete(req.params.id);
  res.json({ message: 'Deleted' });
});
```

**Hierarchical Roles:**

```typescript
// Role hierarchy: admin > editor > viewer
const roleHierarchy: Record<string, string[]> = {
  admin: ['admin', 'editor', 'viewer'],
  editor: ['editor', 'viewer'],
  viewer: ['viewer']
};

function hasRoleOrHigher(userRole: string, requiredRole: string): boolean {
  const allowedRoles = roleHierarchy[userRole] || [];
  return allowedRoles.includes(requiredRole);
}

// Middleware using hierarchy
function requireRole(requiredRole: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const userRoles = await db.userRoles.findByUserId(req.user.id);
    
    const hasRole = userRoles.some(ur => 
      hasRoleOrHigher(ur.role.name, requiredRole)
    );
    
    if (!hasRole) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    next();
  };
}
```

### Attribute-Based Access Control (ABAC)

**Policy-Based Authorization:**

```typescript
interface Policy {
  id: string;
  resource: string;
  action: string;
  effect: 'allow' | 'deny';
  conditions: Condition[];
}

interface Condition {
  attribute: string;  // 'user.department', 'resource.owner', 'time.hour'
  operator: 'eq' | 'ne' | 'in' | 'gt' | 'lt';
  value: any;
}

class PolicyEngine {
  async evaluate(
    user: User,
    resource: any,
    action: string,
    context: Record<string, any> = {}
  ): Promise<boolean> {
    const policies = await db.policies.findByResourceAndAction(
      resource.type,
      action
    );
    
    for (const policy of policies) {
      const conditionsMet = this.evaluateConditions(
        policy.conditions,
        { user, resource, context }
      );
      
      if (conditionsMet) {
        return policy.effect === 'allow';
      }
    }
    
    return false; // Default deny
  }
  
  private evaluateConditions(
    conditions: Condition[],
    attributes: Record<string, any>
  ): boolean {
    return conditions.every(condition => {
      const actualValue = this.getAttributeValue(condition.attribute, attributes);
      return this.compareValues(actualValue, condition.operator, condition.value);
    });
  }
  
  private getAttributeValue(path: string, attributes: Record<string, any>): any {
    return path.split('.').reduce((obj, key) => obj?.[key], attributes);
  }
  
  private compareValues(actual: any, operator: string, expected: any): boolean {
    switch (operator) {
      case 'eq': return actual === expected;
      case 'ne': return actual !== expected;
      case 'in': return Array.isArray(expected) && expected.includes(actual);
      case 'gt': return actual > expected;
      case 'lt': return actual < expected;
      default: return false;
    }
  }
}

// Usage example
const policyEngine = new PolicyEngine();

app.put('/posts/:id', requireAuth, async (req, res) => {
  const post = await db.posts.findById(req.params.id);
  
  const allowed = await policyEngine.evaluate(
    req.user,
    post,
    'update',
    { time: new Date() }
  );
  
  if (!allowed) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  // Update post
});

// Example policy: Users can only edit their own posts
const policy: Policy = {
  resource: 'posts',
  action: 'update',
  effect: 'allow',
  conditions: [
    { attribute: 'user.id', operator: 'eq', value: 'resource.authorId' }
  ]
};
```

## Multi-Factor Authentication (MFA)

### TOTP (Time-Based One-Time Password)

**Setup and Verification:**

```typescript
import speakeasy from 'speakeasy';
import QRCode from 'qrcode';

// Enable MFA for user
async function enableMFA(userId: string): Promise<{ secret: string; qrCode: string }> {
  const secret = speakeasy.generateSecret({
    name: `MyApp (${user.email})`,
    issuer: 'MyApp'
  });
  
  await db.users.update(userId, {
    mfaSecret: secret.base32,
    mfaEnabled: false // Not enabled until verified
  });
  
  const qrCode = await QRCode.toDataURL(secret.otpauth_url!);
  
  return {
    secret: secret.base32,
    qrCode
  };
}

// Verify MFA code during setup
async function verifyMFASetup(userId: string, token: string): Promise<boolean> {
  const user = await db.users.findById(userId);
  
  const verified = speakeasy.totp.verify({
    secret: user.mfaSecret!,
    encoding: 'base32',
    token,
    window: 1 // Allow 1 step before/after for clock drift
  });
  
  if (verified) {
    await db.users.update(userId, { mfaEnabled: true });
  }
  
  return verified;
}

// Verify MFA during login
async function verifyMFALogin(userId: string, token: string): Promise<boolean> {
  const user = await db.users.findById(userId);
  
  if (!user.mfaEnabled) {
    return true; // MFA not required
  }
  
  return speakeasy.totp.verify({
    secret: user.mfaSecret!,
    encoding: 'base32',
    token,
    window: 1
  });
}

// Login flow with MFA
app.post('/login', async (req, res) => {
  const { email, password, mfaToken } = req.body;
  
  const user = await loginUser(email, password);
  
  if (user.mfaEnabled) {
    if (!mfaToken) {
      return res.status(200).json({ requiresMFA: true });
    }
    
    const mfaValid = await verifyMFALogin(user.id, mfaToken);
    
    if (!mfaValid) {
      return res.status(401).json({ error: 'Invalid MFA code' });
    }
  }
  
  const sessionToken = await createSession(user, req);
  
  res.cookie('sessionToken', sessionToken, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  });
  
  res.json({ user });
});
```

### Backup Codes

**Generate and Verify Backup Codes:**

```typescript
// Generate backup codes during MFA setup
async function generateBackupCodes(userId: string): Promise<string[]> {
  const codes = Array.from({ length: 10 }, () =>
    crypto.randomBytes(4).toString('hex').toUpperCase()
  );
  
  const hashedCodes = await Promise.all(
    codes.map(code => bcrypt.hash(code, 10))
  );
  
  await db.backupCodes.createMany(
    hashedCodes.map(hash => ({ userId, codeHash: hash, used: false }))
  );
  
  return codes; // Show to user once, never again
}

// Verify backup code
async function verifyBackupCode(userId: string, code: string): Promise<boolean> {
  const backupCodes = await db.backupCodes.findByUserId(userId);
  
  for (const record of backupCodes) {
    if (record.used) continue;
    
    const matches = await bcrypt.compare(code, record.codeHash);
    
    if (matches) {
      await db.backupCodes.update(record.id, { used: true });
      return true;
    }
  }
  
  return false;
}
```

## Security Best Practices

### CSRF Protection

```typescript
import csrf from 'csurf';

// CSRF middleware for session-based auth
const csrfProtection = csrf({ cookie: true });

app.use(csrfProtection);

// Include CSRF token in forms
app.get('/form', (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});

// Verify CSRF token on POST
app.post('/submit', csrfProtection, (req, res) => {
  // CSRF token verified automatically
  res.send('Form submitted');
});

// For AJAX requests
app.get('/csrf-token', (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});
```

### Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// Login rate limiting
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

app.post('/login', loginLimiter, async (req, res) => {
  // Login logic
});

// Stricter limiting for password reset
const resetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3
});

app.post('/reset-password', resetLimiter, async (req, res) => {
  // Reset logic
});
```

### Secure Headers

```typescript
import helmet from 'helmet';

app.use(helmet()); // Sets secure HTTP headers

// Additional security headers
app.use((req, res, next) => {
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  next();
});
```

### Input Validation

```typescript
import { z } from 'zod';

// Validation schemas
const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12).regex(/[A-Z]/).regex(/[a-z]/).regex(/\d/).regex(/[^A-Za-z0-9]/),
  name: z.string().min(1).max(100)
});

// Validation middleware
function validateRequest(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ errors: error.errors });
      }
      next(error);
    }
  };
}

// Usage
app.post('/login', validateRequest(loginSchema), async (req, res) => {
  // Login logic
});
```

## Testing Authentication

### Unit Tests

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import bcrypt from 'bcrypt';

describe('Password Authentication', () => {
  it('should hash passwords securely', async () => {
    const password = 'SecureP@ssw0rd';
    const hash = await bcrypt.hash(password, 12);
    
    expect(hash).not.toBe(password);
    expect(await bcrypt.compare(password, hash)).toBe(true);
  });
  
  it('should reject weak passwords', () => {
    expect(isStrongPassword('weak')).toBe(false);
    expect(isStrongPassword('NoSpecialChar123')).toBe(false);
    expect(isStrongPassword('SecureP@ssw0rd')).toBe(true);
  });
  
  it('should prevent timing attacks', async () => {
    const start1 = Date.now();
    await loginUser('nonexistent@example.com', 'password');
    const time1 = Date.now() - start1;
    
    const start2 = Date.now();
    await loginUser('valid@example.com', 'wrongpassword');
    const time2 = Date.now() - start2;
    
    // Timing should be similar (within 50ms)
    expect(Math.abs(time1 - time2)).toBeLessThan(50);
  });
});

describe('JWT', () => {
  it('should generate valid tokens', () => {
    const user = { id: '123', email: 'test@example.com', role: 'user' };
    const token = generateTokens(user).accessToken;
    
    const payload = jwt.verify(token, process.env.JWT_SECRET!);
    expect(payload.userId).toBe(user.id);
  });
  
  it('should reject expired tokens', () => {
    const expiredToken = jwt.sign({ userId: '123' }, process.env.JWT_SECRET!, {
      expiresIn: '-1h'
    });
    
    expect(() => jwt.verify(expiredToken, process.env.JWT_SECRET!))
      .toThrow(jwt.TokenExpiredError);
  });
});
```

### Integration Tests

```typescript
import request from 'supertest';
import app from './app';

describe('Authentication Flow', () => {
  it('should complete full registration and login flow', async () => {
    // Register
    const registerRes = await request(app)
      .post('/register')
      .send({
        email: 'test@example.com',
        password: 'SecureP@ssw0rd123',
        name: 'Test User'
      });
    
    expect(registerRes.status).toBe(201);
    
    // Login
    const loginRes = await request(app)
      .post('/login')
      .send({
        email: 'test@example.com',
        password: 'SecureP@ssw0rd123'
      });
    
    expect(loginRes.status).toBe(200);
    expect(loginRes.headers['set-cookie']).toBeDefined();
    
    // Access protected route
    const cookie = loginRes.headers['set-cookie'][0];
    const profileRes = await request(app)
      .get('/profile')
      .set('Cookie', cookie);
    
    expect(profileRes.status).toBe(200);
    expect(profileRes.body.email).toBe('test@example.com');
  });
  
  it('should enforce rate limiting', async () => {
    const attempts = Array.from({ length: 6 }, () =>
      request(app)
        .post('/login')
        .send({ email: 'test@example.com', password: 'wrong' })
    );
    
    const results = await Promise.all(attempts);
    
    expect(results[5].status).toBe(429); // Too many requests
  });
});
```

## Anti-Patterns

### ❌ Storing Passwords in Plain Text

```typescript
// NEVER DO THIS
await db.users.create({
  email: user.email,
  password: user.password // Plain text password
});
```

**Why it's wrong**: Password breaches expose all user credentials.

**Do this instead**:
```typescript
const passwordHash = await bcrypt.hash(user.password, 12);
await db.users.create({ email: user.email, passwordHash });
```

### ❌ Using Weak Hashing Algorithms

```typescript
// NEVER DO THIS
const passwordHash = crypto.createHash('md5').update(password).digest('hex');
const passwordHash = crypto.createHash('sha1').update(password).digest('hex');
```

**Why it's wrong**: MD5 and SHA-1 are broken and can be cracked quickly.

**Do this instead**: Use bcrypt, scrypt, or Argon2.

### ❌ Storing JWT in localStorage

```typescript
// NEVER DO THIS (XSS vulnerable)
localStorage.setItem('token', accessToken);
```

**Why it's wrong**: XSS attacks can steal tokens from localStorage.

**Do this instead**: Use httpOnly cookies for web apps, secure storage for mobile.

### ❌ Not Implementing Token Refresh

```typescript
// NEVER DO THIS
const token = jwt.sign({ userId: user.id }, secret, { expiresIn: '30d' });
```

**Why it's wrong**: Long-lived tokens increase attack surface.

**Do this instead**: Use short-lived access tokens (15 min) + refresh tokens (7 days).

### ❌ Revealing User Existence

```typescript
// NEVER DO THIS
if (!user) {
  return res.status(404).json({ error: 'User not found' });
}
if (!validPassword) {
  return res.status(401).json({ error: 'Invalid password' });
}
```

**Why it's wrong**: Allows attackers to enumerate users.

**Do this instead**: Return generic "Invalid credentials" message.

### ❌ No Rate Limiting

```typescript
// NEVER DO THIS
app.post('/login', async (req, res) => {
  // No rate limiting = brute force attacks possible
});
```

**Why it's wrong**: Enables credential stuffing and brute force.

**Do this instead**: Implement rate limiting on all authentication endpoints.

### ❌ Hardcoded Secrets

```typescript
// NEVER DO THIS
const JWT_SECRET = 'my-secret-key-123';
```

**Why it's wrong**: Secrets in code can be exposed via version control.

**Do this instead**: Use environment variables and secret management.

## Framework-Specific Examples

### Express.js

```typescript
import express from 'express';
import session from 'express-session';
import passport from 'passport';
import { Strategy as LocalStrategy } from 'passport-local';

const app = express();

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    maxAge: 86400000
  }
}));

// Passport configuration
passport.use(new LocalStrategy(
  { usernameField: 'email' },
  async (email, password, done) => {
    try {
      const user = await db.users.findByEmail(email);
      
      if (!user) {
        return done(null, false, { message: 'Invalid credentials' });
      }
      
      const valid = await bcrypt.compare(password, user.passwordHash);
      
      if (!valid) {
        return done(null, false, { message: 'Invalid credentials' });
      }
      
      return done(null, user);
    } catch (error) {
      return done(error);
    }
  }
));

passport.serializeUser((user: any, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id: string, done) => {
  try {
    const user = await db.users.findById(id);
    done(null, user);
  } catch (error) {
    done(error);
  }
});

app.use(passport.initialize());
app.use(passport.session());

// Routes
app.post('/login', passport.authenticate('local'), (req, res) => {
  res.json({ user: req.user });
});

app.post('/logout', (req, res) => {
  req.logout((err) => {
    if (err) return res.status(500).json({ error: 'Logout failed' });
    res.json({ message: 'Logged out' });
  });
});
```

### Next.js (App Router)

```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';
import GoogleProvider from 'next-auth/providers/google';

const handler = NextAuth({
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null;
        }
        
        const user = await loginUser(credentials.email, credentials.password);
        
        if (!user) {
          return null;
        }
        
        return { id: user.id, email: user.email, name: user.name };
      }
    }),
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!
    })
  ],
  session: {
    strategy: 'jwt',
    maxAge: 24 * 60 * 60 // 24 hours
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
      }
      return session;
    }
  },
  pages: {
    signIn: '/login',
    error: '/login'
  }
});

export { handler as GET, handler as POST };

// Protected page
import { getServerSession } from 'next-auth';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const session = await getServerSession();
  
  if (!session) {
    redirect('/login');
  }
  
  return <div>Welcome, {session.user?.name}</div>;
}
```

## Related Modules

- **API_DESIGN** - Authentication for REST/GraphQL APIs
- **DATABASE_SCHEMA** - User and session schema design
- **SECURITY_CHECKLIST** - Security audit checklist
- **BACKEND_PATTERNS** - Middleware and error handling
- **TESTING_STRATEGY** - Testing authentication flows
- **PRODUCTION_READINESS** - Security hardening for production
