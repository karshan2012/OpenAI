/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: true,
    externalDir: true
  },
  output: 'standalone'
};

export default nextConfig;
