# Caddy with Cloudflare - Examples

This directory contains ready-to-use examples for deploying Caddy with Cloudflare DNS plugin in various scenarios.

## Quick Start

1. **Choose an example** that matches your use case
2. **Copy the files** to your project directory
3. **Create `.env` file** from `.env.example` and fill in your Cloudflare credentials
4. **Update the Caddyfile** with your domain name
5. **Run** `docker-compose up -d`

## Available Examples

### 1. Simple Single Domain

**Files:**
- `Caddyfile.simple`
- `docker-compose.yml`

**Use case:** Basic setup for a single domain with Cloudflare DNS challenge.

**Features:**
- Single domain HTTPS
- Automatic certificate renewal
- Simple response handler

**Quick start:**
```bash
cp Caddyfile.simple Caddyfile
cp .env.example .env
# Edit .env and Caddyfile with your details
docker-compose up -d
```

---

### 2. Reverse Proxy

**Files:**
- `Caddyfile.reverse-proxy`
- `docker-compose.full-stack.yml`

**Use case:** Reverse proxy for web applications and APIs.

**Features:**
- Multiple subdomains
- Backend health checks
- CORS support
- Access logging
- Custom headers

**Quick start:**
```bash
cp Caddyfile.reverse-proxy Caddyfile
cp docker-compose.full-stack.yml docker-compose.yml
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

---

### 3. Multiple Domains

**Files:**
- `Caddyfile.multiple-domains`
- `docker-compose.yml`

**Use case:** Hosting multiple domains and wildcard subdomains.

**Features:**
- Multiple domains
- Wildcard subdomain support
- Subdomain routing
- www to non-www redirect

**Quick start:**
```bash
cp Caddyfile.multiple-domains Caddyfile
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

---

### 4. Advanced Production Setup

**Files:**
- `Caddyfile.advanced`
- `docker-compose.full-stack.yml`

**Use case:** Production-ready configuration with security and performance.

**Features:**
- Security headers (HSTS, CSP, etc.)
- Compression (gzip, zstd)
- Static file caching
- WebSocket support
- Load balancing
- Custom error pages
- Structured logging

**Quick start:**
```bash
cp Caddyfile.advanced Caddyfile
cp docker-compose.full-stack.yml docker-compose.yml
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

---

### 5. WordPress

**Files:**
- `Caddyfile.wordpress`
- `docker-compose.wordpress.yml`

**Use case:** WordPress site with automatic HTTPS.

**Features:**
- WordPress + MySQL
- Automatic HTTPS via Cloudflare
- www redirect
- Security headers
- Persistent data volumes

**Quick start:**
```bash
cp Caddyfile.wordpress Caddyfile
cp docker-compose.wordpress.yml docker-compose.yml
cp .env.example .env
# Edit .env with your details
docker-compose up -d
```

Access: `https://your-domain.com/wp-admin`

---

### 6. Monitoring Stack

**Files:**
- `Caddyfile.monitoring`
- `docker-compose.monitoring.yml`
- `prometheus.yml`

**Use case:** Prometheus + Grafana monitoring with Caddy.

**Features:**
- Grafana dashboard
- Prometheus metrics
- Node exporter
- Caddy exporter
- Basic authentication
- Subdomain routing

**Quick start:**
```bash
cp Caddyfile.monitoring Caddyfile
cp docker-compose.monitoring.yml docker-compose.yml
cp .env.example .env
# Edit files with your details
docker-compose up -d
```

Access:
- Grafana: `https://grafana.your-domain.com`
- Prometheus: `https://prometheus.your-domain.com`

---

## Configuration Guide

### Cloudflare Setup

1. **Ensure your domain is using Cloudflare for DNS**
   - Add your domain to Cloudflare
   - Update nameservers at your domain registrar

2. **Create API Token (Recommended) or use Global API Key**

#### Option A: API Token (Recommended - More Secure)

1. Go to Cloudflare Dashboard → My Profile → API Tokens
2. Click "Create Token"
3. Use "Edit zone DNS" template or create custom token with:
   - Permissions: `Zone` → `DNS` → `Edit`
   - Zone Resources: `Include` → `Specific zone` → `your-domain.com`
4. Copy the token and save it securely

Required token permissions:
- Zone / DNS / Edit

#### Option B: Global API Key (Less Secure)

1. Go to Cloudflare Dashboard → My Profile → API Tokens
2. Click "View" under Global API Key
3. Copy your email and the API key

### Environment Variables

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env` with your values:

**Using API Token (Recommended):**
```bash
# Cloudflare API Token
CLOUDFLARE_API_TOKEN=your_api_token_here

# Your domain
DOMAIN=example.com
```

**Using Global API Key:**
```bash
# Cloudflare Global API Key
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_KEY=your_global_api_key_here

# Your domain
DOMAIN=example.com
```

### Domain Configuration

In your Caddyfile, replace `example.com` with your actual domain:
```caddyfile
your-domain.com {
    tls {
        dns cloudflare
    }
    respond "Hello World!"
}
```

## Common Tasks

### View Logs

```bash
# All logs
docker-compose logs -f

# Just Caddy
docker-compose logs -f caddy

# Last 100 lines
docker-compose logs --tail=100 caddy
```

### Reload Configuration

After editing Caddyfile:
```bash
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

Or restart:
```bash
docker-compose restart caddy
```

### Check Certificate Status

```bash
docker-compose exec caddy caddy list-certificates
```

### Test Configuration

Before applying:
```bash
docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

### Backup Certificates

```bash
docker run --rm -v caddy_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/caddy-data-backup.tar.gz /data
```

### Restore Certificates

```bash
docker run --rm -v caddy_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/caddy-data-backup.tar.gz -C /
```

## Troubleshooting

### Certificate Provisioning Fails

**Problem:** Certificate not being issued

**Solutions:**
1. Check Cloudflare credentials are correct
2. Verify API token has correct permissions (Zone/DNS/Edit)
3. Ensure domain is active in Cloudflare
4. Check Caddy logs: `docker-compose logs caddy`
5. Verify DNS records in Cloudflare dashboard
6. Ensure Cloudflare proxy (orange cloud) is disabled for validation or use DNS challenge

### Connection Timeout

**Problem:** Cannot connect to domain

**Solutions:**
1. Check ports 80 and 443 are open in firewall
2. Verify DNS records point to your server in Cloudflare dashboard
3. Wait for DNS propagation (usually minutes with Cloudflare)
4. Test with: `dig your-domain.com`
5. Check Cloudflare proxy status (orange vs grey cloud)

### Backend Connection Refused

**Problem:** Caddy can't reach backend service

**Solutions:**
1. Ensure backend is running: `docker-compose ps`
2. Check service names match in docker-compose and Caddyfile
3. Verify backend is listening on correct port
4. Check backend health: `docker-compose logs backend`

### Permission Denied

**Problem:** Caddy can't write to volumes

**Solutions:**
1. Check volume permissions
2. Try with sudo: `sudo docker-compose up`
3. Fix volume ownership:
   ```bash
   sudo chown -R 1000:1000 ./caddy_data
   ```

### Cloudflare Error 522 (Connection Timed Out)

**Problem:** Cloudflare proxy can't reach your origin server

**Solutions:**
1. Ensure your origin server accepts connections on port 443
2. Check firewall allows Cloudflare IPs
3. Verify SSL/TLS encryption mode in Cloudflare is set to "Full" or "Full (strict)"
4. Disable proxy (grey cloud) temporarily for testing

## Best Practices

### Security

- ✅ Always use HTTPS in production
- ✅ Enable HSTS headers
- ✅ Use API Tokens instead of Global API Key
- ✅ Limit API token permissions to specific zones
- ✅ Use strong passwords for databases
- ✅ Restrict access to admin panels
- ✅ Keep credentials in `.env`, never commit to git
- ✅ Enable logging for audit trails
- ✅ Consider using Cloudflare's Web Application Firewall (WAF)

### Performance

- ✅ Enable compression (gzip, zstd)
- ✅ Cache static assets
- ✅ Use HTTP/3 (enabled by default in Caddy)
- ✅ Configure connection pooling
- ✅ Set up health checks
- ✅ Use Cloudflare's CDN for static content

### Maintenance

- ✅ Monitor logs regularly
- ✅ Backup certificate data
- ✅ Test configuration changes before applying
- ✅ Keep Docker images updated
- ✅ Document custom configurations
- ✅ Review Cloudflare analytics

## Advanced Usage

### Custom Plugins

To add more Caddy plugins, fork the repository and modify the `Dockerfile`:

```dockerfile
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/route53 \
    --with your-custom-plugin
```

### Multiple Environments

Create separate docker-compose files:
- `docker-compose.prod.yml`
- `docker-compose.staging.yml`

Run specific environment:
```bash
docker-compose -f docker-compose.staging.yml up -d
```

### External Configuration

Mount configuration from external source:
```yaml
volumes:
  - /etc/caddy/Caddyfile:/etc/caddy/Caddyfile:ro
  - /var/caddy/data:/data
```

### Using with Cloudflare Proxy

When using Cloudflare's proxy (orange cloud):
1. Set SSL/TLS encryption mode to "Full" or "Full (strict)" in Cloudflare dashboard
2. Caddy will automatically obtain certificates via DNS challenge
3. Traffic flows: Client → Cloudflare (with Cloudflare cert) → Origin (with Let's Encrypt cert)

## Resources

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Cloudflare Plugin Docs](https://github.com/caddy-dns/cloudflare)
- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)
- [Cloudflare API Documentation](https://developers.cloudflare.com/api/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Let's Encrypt](https://letsencrypt.org/)

## Support

- GitHub Issues: [Report a bug](https://github.com/ivannco/caddy_xcaddy_cloudflare/issues)
- Caddy Community: [forum.caddyserver.com](https://caddy.community/)
- Cloudflare Community: [community.cloudflare.com](https://community.cloudflare.com/)

## License

These examples are provided as-is for use with the Caddy Cloudflare Docker image.
