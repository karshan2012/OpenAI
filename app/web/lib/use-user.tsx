'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import jwtDecode from 'jwt-decode';

type User = {
  sub: string;
  roles: string[];
  accountIds: string[];
};

const UserContext = createContext<{ user: User | null }>({ user: null });

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const storedToken = window.localStorage.getItem('demo_jwt');
    if (storedToken) {
      try {
        const decoded = jwtDecode<{ sub?: string; roles?: string[]; account_ids?: string[] }>(storedToken);
        if (decoded.roles && decoded.account_ids) {
          setUser({
            sub: decoded.sub ?? 'user',
            roles: decoded.roles,
            accountIds: decoded.account_ids
          });
        }
      } catch (error) {
        console.error('Failed to decode JWT', error);
      }
    }
  }, []);

  return <UserContext.Provider value={{ user }}>{children}</UserContext.Provider>;
}

export function useUser() {
  return useContext(UserContext);
}
