# Fly.io Deployment Guide for blockr.fredr Dashboard

This guide explains how to deploy the blockr.fredr dashboard to Fly.io using Docker.

## Prerequisites

1. **Fly.io CLI** installed ([Install guide](https://fly.io/docs/hands-on/install-flyctl/))
   ```bash
   # macOS
   brew install flyctl

   # Linux
   curl -L https://fly.io/install.sh | sh

   # Windows
   powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
   ```

2. **Fly.io account** (free signup at https://fly.io/app/sign-up)

3. **FRED API key** from https://fred.stlouisfed.org/docs/api/api_key.html

4. **Docker** installed (for local testing, optional)

## Quick Deploy (First Time)

### 1. Authenticate with Fly.io

```bash
fly auth login
```

This will open your browser for authentication.

### 2. Launch the App

From the project root directory:

```bash
fly launch
```

This will:
- Detect your Dockerfile
- Ask if you want to modify the `fly.toml` (select **No** to use existing config)
- Ask for an app name (press Enter to accept default or choose your own)
- Ask for a region (choose closest to your users, e.g., `iad` for US East)
- Ask if you want to deploy now (select **No** - we need to set secrets first)

### 3. Set FRED API Key Secret

```bash
fly secrets set FRED_API_KEY="your-api-key-here"
```

This securely stores your API key as an environment variable.

### 4. Deploy the App

```bash
fly deploy
```

This will:
- Build the Docker image (first time takes ~5-10 minutes)
- Push to Fly.io registry
- Deploy to your machine
- Provide a URL like `https://blockr-fredr-dashboard.fly.dev`

### 5. Verify Deployment

```bash
fly open
```

This opens your dashboard in the browser.

## Subsequent Deployments

After initial setup, deploying updates is simple:

```bash
fly deploy
```

## Configuration

### Machine Size

The default configuration in `fly.toml` uses:
- **Size**: `shared-cpu-1x` (1GB RAM, 1 vCPU)
- **Cost**: ~$5-7/month
- **Auto-scaling**: Scales to 0 when idle (saves costs)

To change machine size, edit `fly.toml`:

```toml
[[vm]]
  size = 'shared-cpu-2x'  # 2GB RAM - ~$15/month
  memory = '2gb'
```

Then redeploy:

```bash
fly deploy
```

### Multiple Machines (High Availability)

To run multiple machines for redundancy, uncomment the second `[[vm]]` block in `fly.toml`.

### Custom Domain

To add a custom domain (e.g., `dashboard.yourcompany.com`):

1. Add certificate:
   ```bash
   fly certs add dashboard.yourcompany.com
   ```

2. Follow the DNS instructions provided

3. Verify:
   ```bash
   fly certs show dashboard.yourcompany.com
   ```

Full guide: https://fly.io/docs/networking/custom-domain/

## Monitoring & Troubleshooting

### View Logs

```bash
fly logs
```

### Check Status

```bash
fly status
```

### SSH into Machine

```bash
fly ssh console
```

### View Dashboard

```bash
fly dashboard
```

Opens the Fly.io web dashboard for your app.

### Common Issues

**Problem**: Build fails with package installation errors
- **Solution**: Check GitHub packages are accessible. Might need GitHub PAT if private.

**Problem**: App crashes on startup
- **Solution**: Check logs with `fly logs`. Common issues:
  - Missing FRED_API_KEY secret
  - Package version conflicts

**Problem**: App is slow or crashes under load
- **Solution**: Increase machine size in `fly.toml` to `shared-cpu-2x` (2GB RAM)

**Problem**: Build is very slow
- **Solution**: This is normal for first build (installing R packages). Subsequent builds are faster thanks to Docker layer caching.

## Cost Management

### Current Setup Costs
- **1GB machine**: ~$5-7/month
- **Auto-scaling to 0**: Saves money when idle
- **Bandwidth**: First 100GB free, then $0.02/GB

### Cost Optimization Tips
1. Keep `auto_stop_machines = true` in `fly.toml` to scale to zero
2. Use `shared-cpu-1x` (1GB) unless you need more
3. Start with 0 minimum machines: `min_machines_running = 0`

### View Current Costs

```bash
fly status
```

Or check the billing dashboard at https://fly.io/dashboard/personal/billing

## Local Testing (Optional)

To test the Docker image locally before deploying:

```bash
# Build the image
docker build -t blockr-fredr .

# Run locally
docker run -p 3838:3838 -e FRED_API_KEY="your-key" blockr-fredr

# Visit http://localhost:3838
```

## File Structure

```
blockr.fredr/
├── Dockerfile          # Docker build configuration
├── .dockerignore       # Files to exclude from build
├── fly.toml           # Fly.io deployment configuration
├── DEPLOY.md          # This file
└── deploy/
    ├── app.R          # Shiny app entry point
    ├── dashboard.json # Dashboard configuration
    └── DESCRIPTION    # R package dependencies
```

## For DevOps Team

### Migration to Other Platforms

This Docker-based setup is portable. To migrate:

1. **AWS ECS/Fargate**:
   - Push Docker image to ECR
   - Create ECS task definition with same env vars
   - Set `FRED_API_KEY` in task secrets

2. **Kubernetes**:
   - Use same Docker image
   - Create Deployment + Service manifests
   - Set `FRED_API_KEY` in Secret resource

3. **AWS Lightsail**:
   - Push to Lightsail Container Service
   - Configure environment variables

4. **DigitalOcean App Platform**:
   - Connect repo or push image
   - Configure environment variables

### CI/CD Integration

To automate deployments:

```bash
# Generate deploy token
fly tokens create deploy

# Add FLY_API_TOKEN to CI environment variables
```

Example GitHub Actions workflow:

```yaml
- name: Deploy to Fly.io
  run: fly deploy --remote-only
  env:
    FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

### Scaling Considerations

**Current setup supports:**
- ~5-10 concurrent users
- Light FRED API usage

**To scale:**
- Increase machine size (`shared-cpu-2x` or `dedicated-cpu-*`)
- Add multiple machines for redundancy
- Consider connection pooling if heavy usage

## Useful Commands Reference

```bash
# Deploy
fly deploy                    # Deploy current code
fly deploy --remote-only      # Build on Fly.io (slower but no local Docker needed)

# Manage
fly scale count 2             # Scale to 2 machines
fly scale memory 2048         # Change to 2GB RAM
fly secrets list              # View secret names (not values)
fly secrets set KEY=value     # Set a secret

# Monitor
fly status                    # App status
fly logs                      # Stream logs
fly logs -a app-name          # Logs for specific app

# Regions
fly regions list              # Available regions
fly regions add sea           # Add Seattle region
fly regions remove sea        # Remove region

# Cleanup
fly apps destroy app-name     # Delete app (prompts for confirmation)
```

## Support

- **Fly.io Docs**: https://fly.io/docs/
- **Fly.io Community**: https://community.fly.io/
- **blockr Package**: https://github.com/BristolMyersSquibb/blockr
- **FRED API**: https://fred.stlouisfed.org/docs/api/

## Quick Troubleshooting Checklist

- [ ] Fly.io CLI installed and authenticated (`fly auth login`)
- [ ] FRED_API_KEY secret set (`fly secrets list`)
- [ ] Docker image builds successfully locally (optional: `docker build .`)
- [ ] App deployed without errors (`fly deploy`)
- [ ] App is accessible at URL (`fly open`)
- [ ] Logs show no errors (`fly logs`)
- [ ] FRED data loads correctly in dashboard
