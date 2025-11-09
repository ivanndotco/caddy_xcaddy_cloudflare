# Caddy with Cloudflare DNS Plugin

Docker image with Caddy web server and Cloudflare DNS plugin for automatic HTTPS via DNS-01 ACME challenge.

## Why This Exists

>Hi!
>I'll probably rewrite this part a few more times, so make sure you're using the latest version of the repo.
>
>As someone who loves doing things fast, I prefer using ready-to-go containers instead of building them from scratch.
>This time, it's my turn to help others do things faster — without any builds.
>
>Here you'll find an automated setup that explains everything clearly, includes usage samples, and works right out of the box.
>
>To be honest, I built it first and only then realized that similar solutions already exist — but I'll try to make this one better.
>The repo includes all the samples and recommendations you need for a full understanding of how to use it.
>
>And the best part? It's fully automated.
>So even if I stop using it (or, you know, die 😅), the containers should keep updating — assuming GitHub doesn't delete my account!
>
> — **IvanN.co**

## Features

- **Latest Caddy**: Automatically updated when new versions are released
- **Cloudflare DNS Plugin**: For ACME DNS-01 challenges (perfect for wildcard certificates)
- **Multi-platform**: AMD64 and ARM64 support
- **Fully Automated**: CI/CD pipeline checks for Caddy AND Cloudflare plugin updates weekly
- **Version Pinning**: Each image tag reflects exact versions of Caddy and Cloudflare plugin used
- **Production Ready**: Optimized for security and performance

## Quick Start

### Pull the Image

```bash
docker pull ivannco/caddy_xcaddy_cloudflare:latest
```

### Run with Docker

```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  -e CLOUDFLARE_API_TOKEN=your_api_token \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  -v caddy_data:/data \
  ivannco/caddy_xcaddy_cloudflare:latest
```

### Run with Docker Compose

```bash
docker-compose up -d
```

See [examples/](examples/) for ready-to-use configurations.

## Available Tags

### Recommended (Full Version Info)
- `caddy-2.10.2-cloudflare-0.2.2` - **Pinned versions** (Caddy 2.10.2 + Cloudflare 0.2.2)
- `c2.10.2-cf0.2.2` - **Short format** (same as above)

### Traditional Tags
- `latest` - Always the most recent build
- `2.10.2` - Specific Caddy version (with latest Cloudflare plugin at build time)
- `v2.10.2` - Same with 'v' prefix
- `caddy-v2.10.2` - Alternative format

**Recommendation:** Use the full version tags (e.g., `caddy-2.10.2-cloudflare-0.2.2`) for production to ensure reproducible deployments with pinned plugin versions.

## Example Caddyfile

```caddyfile
example.com {
    tls {
        dns cloudflare
    }
    respond "Hello from Caddy with Cloudflare!"
}
```

### Wildcard Certificate

```caddyfile
*.example.com, example.com {
    tls {
        dns cloudflare
    }

    @blog host blog.example.com
    handle @blog {
        reverse_proxy blog:8080
    }

    @app host app.example.com
    handle @app {
        reverse_proxy app:3000
    }
}
```

## Cloudflare Setup

### 1. Configure DNS

Ensure your domain uses Cloudflare for DNS:
- Add domain to Cloudflare
- Update nameservers at your domain registrar to Cloudflare's nameservers

### 2. API Credentials

Choose between API Token (recommended) or Global API Key:

#### Option A: API Token (Recommended - More Secure)

1. Go to Cloudflare Dashboard → My Profile → API Tokens
2. Click "Create Token"
3. Use "Edit zone DNS" template or create custom token with:
   - **Permissions**: `Zone` → `DNS` → `Edit`
   - **Zone Resources**: `Include` → `Specific zone` → `your-domain.com` (or all zones)
4. Copy the token and save it securely

Required permissions:
```
Zone / DNS / Edit
```

#### Option B: Global API Key (Less Secure, Not Recommended)

1. Go to Cloudflare Dashboard → My Profile → API Tokens
2. View "Global API Key"
3. You'll need both your Cloudflare email and the API key

### 3. Credentials

**Option A: API Token (Recommended)**
```bash
CLOUDFLARE_API_TOKEN=your_api_token_here
```

**Option B: Email + Global API Key**
```bash
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_KEY=your_global_api_key
```

## Examples

The [examples/](examples/) directory contains ready-to-use configurations:

### Basic Examples
- **[Simple](examples/Caddyfile.simple)** - Single domain with HTTPS
- **[Reverse Proxy](examples/Caddyfile.reverse-proxy)** - Proxy to backend services
- **[Multiple Domains](examples/Caddyfile.multiple-domains)** - Multiple domains and wildcards

### Full Stack Examples
- **[WordPress](examples/docker-compose.wordpress.yml)** - WordPress with MySQL
- **[Monitoring](examples/docker-compose.monitoring.yml)** - Prometheus + Grafana
- **[Full Stack](examples/docker-compose.full-stack.yml)** - Frontend + Backend + Database

### Production Ready
- **[Advanced](examples/Caddyfile.advanced)** - Security headers, caching, load balancing

See the [examples README](examples/README.md) for detailed guides.

## Common Use Cases

### Static Website

```caddyfile
example.com {
    tls {
        dns cloudflare
    }
    root * /var/www/html
    file_server
    encode gzip
}
```

### Reverse Proxy

```caddyfile
api.example.com {
    tls {
        dns cloudflare
    }
    reverse_proxy backend:8080 {
        health_uri /health
        health_interval 10s
    }
}
```

### Load Balancing

```caddyfile
app.example.com {
    tls {
        dns cloudflare
    }
    reverse_proxy backend1:8080 backend2:8080 backend3:8080 {
        lb_policy round_robin
        health_uri /health
    }
}
```

## Docker Compose Configuration

Minimal `docker-compose.yml`:

```yaml
version: '3.8'

services:
  caddy:
    image: ivannco/caddy_xcaddy_cloudflare:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN}

volumes:
  caddy_data:
  caddy_config:
```

Create `.env` file:
```bash
CLOUDFLARE_API_TOKEN=your_api_token_here
```

Or using Global API Key:
```bash
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_KEY=your_global_api_key
```

Run:
```bash
docker-compose up -d
```

## Management

### View Logs

```bash
docker-compose logs -f caddy
```

### Reload Configuration

```bash
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### List Certificates

```bash
docker-compose exec caddy caddy list-certificates
```

### Validate Configuration

```bash
docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

## Troubleshooting

### Certificate Not Being Issued

1. Verify Cloudflare API token is correct
2. Check API token has `Zone/DNS/Edit` permissions
3. Ensure domain is active in Cloudflare
4. Check logs: `docker-compose logs caddy`
5. Verify DNS records exist in Cloudflare dashboard
6. Use GPTs to analyze the logs from step 4

### Cannot Connect to Domain

1. Verify DNS records point to your server: `dig example.com`
2. Check firewall allows ports 80, 443 (If the server is private, make sure you can access these resources somehow (like VPN). Ports 80 and 443 do not need to be open to the world, but they should work for you.)
3. Check Cloudflare proxy status (orange vs grey cloud)
4. Wait for DNS propagation (usually very fast with Cloudflare)

### Backend Connection Error

1. Verify backend service is running
2. Check service names match in docker-compose
3. Test backend directly: `curl http://backend:8080`

### Cloudflare Error 522 (Connection Timed Out)

1. Ensure your origin server accepts connections on port 443
2. Check firewall allows Cloudflare IPs
3. Set SSL/TLS encryption mode to "Full" or "Full (strict)" in Cloudflare
4. Try disabling proxy (grey cloud) temporarily for testing

## Security Best Practices

- ✅ Use API Tokens instead of Global API Key
- ✅ Limit API token permissions to specific zones
- ✅ Use environment variables for credentials
- ✅ Never commit `.env` to version control
- ✅ Enable security headers (see [advanced example](examples/Caddyfile.advanced))
- ✅ Keep images updated
- ✅ Restrict access to sensitive endpoints
- ✅ Monitor logs for suspicious activity
- ✅ Consider using Cloudflare's Web Application Firewall (WAF)

## Performance Tips

- ✅ Enable compression (`encode gzip`)
- ✅ Cache static assets
- ✅ Use HTTP/3 (enabled by default on port 443/udp)
- ✅ Configure health checks for backends
- ✅ Use connection pooling
- ✅ Leverage Cloudflare's CDN for static content

## Version Tracking & Automation

This repository uses a fully automated version tracking system:

### How It Works

1. **Weekly Checks**: GitHub Actions checks for new Caddy and Cloudflare plugin releases every Monday at 2 AM UTC
2. **Version Detection**: Compares current versions (stored in `versions.json`) with latest GitHub releases
3. **Automatic Updates**: If either component has a new version:
   - Updates `versions.json` automatically
   - Triggers a new Docker build
   - Pushes images with updated version tags
4. **Zero Manual Intervention**: Everything happens automatically - no repo updates needed!

### Version File (`versions.json`)

```json
{
  "caddy": "v2.10.2",
  "cloudflare": "v0.2.2",
  "last_checked": "2025-11-09T00:00:00Z",
  "changed": ["cloudflare"]
}
```

This file is the source of truth for which versions are built into each Docker image.

### Tag Format Explained

**Full version tag:** `caddy-2.10.2-cloudflare-0.2.2`
- Caddy web server version: `2.10.2`
- Cloudflare DNS plugin version: `0.2.2`
- **Use this for production!** It guarantees exact versions for reproducible builds.

**Short version tag:** `c2.10.2-cf0.2.2`
- Same versions, compact format
- Useful when space is limited

**Traditional tags:** `latest`, `2.10.2`, `v2.10.2`
- Backward compatible with old deployments
- Caddy version is pinned, but Cloudflare plugin version is whatever was latest at build time

### Why This Matters

Using full version tags (`caddy-X.X.X-cloudflare-Y.Y.Y`) ensures:
- ✅ **Reproducible builds**: Exact same versions every time
- ✅ **Audit trail**: Know exactly what's in your container
- ✅ **Easy rollback**: Pin to known-good version combinations
- ✅ **No surprises**: Plugin updates won't break your setup unexpectedly

## Working with Cloudflare Proxy

When using Cloudflare's proxy feature (orange cloud):

1. **SSL/TLS Mode**: Set to "Full" or "Full (strict)" in Cloudflare dashboard
2. **Certificate**: Caddy will automatically obtain Let's Encrypt certificates via DNS challenge
3. **Traffic Flow**: Client → Cloudflare (Cloudflare cert) → Origin Server (Let's Encrypt cert)
4. **Benefits**: DDoS protection, CDN, WAF, while maintaining automatic HTTPS

## Building Your Own

Want to customize? Fork this repository and modify:

### Add More Plugins

Edit `Dockerfile`:
```dockerfile
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare${CLOUDFLARE_VERSION:+@$CLOUDFLARE_VERSION} \
    --with github.com/caddy-dns/route53 \
    --with your-custom-plugin
```

### Build with Specific Versions

```bash
# Build with specific Caddy and Cloudflare versions
docker build \
  --build-arg CADDY_VERSION=2.10.2 \
  --build-arg CLOUDFLARE_VERSION=v0.2.2 \
  -t my-caddy:custom .

# Build with latest versions (default)
docker build -t my-caddy:latest .
```

### Configure CI/CD

The repository includes GitHub Actions workflows that:
- Check for Caddy AND Cloudflare plugin updates weekly
- Build multi-platform images (AMD64, ARM64)
- Push to Docker Hub with version-pinned tags
- Fully automated - no manual intervention needed

## Resources

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Cloudflare Plugin](https://github.com/caddy-dns/cloudflare)
- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)
- [Cloudflare API Documentation](https://developers.cloudflare.com/api/)
- [Examples](examples/)

## Support

- GitHub Issues: Report bugs and request features
- Caddy Community: [caddy.community](https://caddy.community/)
- Cloudflare Community: [community.cloudflare.com](https://community.cloudflare.com/)

## License

This project follows Caddy's Apache 2.0 license.

---

**Built with:**
- [Caddy](https://caddyserver.com/) - Modern web server
- [xcaddy](https://github.com/caddyserver/xcaddy) - Caddy build tool
- [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare) - Cloudflare DNS plugin
