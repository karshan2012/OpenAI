import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { JWT_PUBLIC_KEY } from './config.js';

export interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    roles: string[];
    accountIds: string[];
  };
}

interface TokenClaims extends JwtPayload {
  roles?: string[];
  account_ids?: string[];
}

export function authenticate(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Missing authorization header' });
  }
  const token = authHeader.replace('Bearer ', '');
  try {
    const decoded = jwt.verify(token, JWT_PUBLIC_KEY, { algorithms: ['RS256'] }) as TokenClaims;
    const roles = decoded.roles ?? [];
    const accountIds = decoded.account_ids ?? [];
    if (!roles.length || !accountIds.length) {
      return res.status(403).json({ error: 'Invalid token claims' });
    }
    req.user = {
      sub: decoded.sub ?? 'unknown',
      roles,
      accountIds
    };
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token', details: (error as Error).message });
  }
}

export function requireRoleAccess(permittedRoles: string[]) {
  return function roleMiddleware(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    const roles = req.user?.roles ?? [];
    if (!roles.some((role) => permittedRoles.includes(role))) {
      return res.status(403).json({ error: 'Insufficient role permissions' });
    }
    return next();
  };
}
