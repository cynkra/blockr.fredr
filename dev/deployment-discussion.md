# blockr.fredr Dashboard Deployment Discussion

**Date**: 2025-11-22
**Purpose**: Prepare for AWS deployment discussion with Nelson
**Current Status**: Working dashboard at `dev/examples/series_selector_demo.R`

## Goal

Deploy blockr.fredr dashboard as a public website on AWS for external users to access and interact with FRED economic data visualizations.

## Proposed Approach: ShinyProxy + Docker

**Overview**: ShinyProxy spawns isolated Docker containers for each user session.

**Pros**:
- Multi-user isolation (each user gets own container)
- Scalable (spin containers up/down based on demand)
- Good security boundaries
- Nelson's expertise available
- Resource control (set memory/CPU limits)

**Cons**:
- More complex (ShinyProxy + Docker + orchestration)
- Cold start delays for users
- Higher cost with many concurrent users
- More maintenance overhead

**AWS Implementation Options**:
1. **EC2 + Docker** - Simple single-server setup
2. **ECS + ALB** - Better scaling, managed orchestration (recommended)
3. **EKS** - Overkill unless you have other Kubernetes workloads

## Alternative Approaches

### 1. AWS Fargate + ALB (Serverless Containers)
- No EC2 management, auto-scaling
- Pay only when running
- Sweet spot: easier than ShinyProxy, more scalable than single EC2
- **Cost**: ~$15-50/month for low-medium traffic

### 2. EC2 + Shiny Server Open Source
- Simplest self-hosted option
- Single t3.medium instance (~$30/month)
- Good for <50 concurrent users
- **Limitation**: Users share same R process

### 3. shinyapps.io (Hosted)
- Easiest deployment (`rsconnect::deployApp()`)
- Free tier: 25 active hours/month
- Paid: $9-$99/month
- **Limitation**: Not on AWS, less control

## Recommendation

**Start Simple, Scale Later**:
1. **Phase 1**: EC2 + Shiny Server (~$30/month)
   - Validate usage patterns
   - Low complexity, quick to deploy

2. **Phase 2**: Move to ShinyProxy + ECS if needed
   - When you see >20 concurrent users
   - When you need session isolation
   - When you have budget for complexity

**Or Go Straight to ShinyProxy if**:
- Expecting high traffic from launch
- Need strong user isolation
- Have budget and maintenance capacity
- Want to build reusable infrastructure for future apps

## Key Discussion Questions for Nelson

1. **Traffic Expectations**
   - How many concurrent users anticipated?
   - Peak vs. average usage?

2. **Budget**
   - Monthly hosting budget?
   - One-time setup budget?

3. **Timeline**
   - When does this need to be live?
   - Time available for setup/testing?

4. **Requirements**
   - Authentication needed (SSO, AD)?
   - Uptime expectations (SLA)?
   - Custom domain/SSL?

5. **Future Plans**
   - Is this a one-off or first of many Shiny apps?
   - Other R/Shiny applications planned?

6. **ShinyProxy Experience**
   - Which AWS services has Nelson used with ShinyProxy?
   - Existing ShinyProxy configurations we can leverage?
   - Monitoring/logging setup recommendations?

## Preparation Checklist

- [ ] Dockerize the blockr.fredr app
- [ ] Test Docker container locally
- [ ] Estimate compute requirements (memory/CPU for typical session)
- [ ] Document R package dependencies
- [ ] Create AWS cost estimate for different approaches
- [ ] Draft ShinyProxy configuration (if going that route)
- [ ] Set up development/staging environment plan

## Next Steps

1. Discuss with Nelson, decide on approach
2. Create Dockerfile for blockr.fredr dashboard
3. Set up AWS infrastructure (based on chosen approach)
4. Configure domain/SSL
5. Deploy and test
6. Set up monitoring/logging
7. Document deployment process

## Resources

- ShinyProxy docs: https://www.shinyproxy.io/
- AWS ECS docs: https://docs.aws.amazon.com/ecs/
- Shiny deployment guide: https://shiny.posit.co/r/deploy.html
