# Deploying Express App on Cloud using Jenkins & Terraform on ECS

## Tools & Services Used
- **AWS Services:** EC2, ECS, IAM, VPC, Security Groups, NLB (Network Load Balancer), CloudWatch
- **Containerization:** Docker(Multistage Dockerfile using NGINX Commented out due to lack of need in this App)
- **Infrastructure as Code:** Terraform (With the bit help of ChatGPT)
- **CI/CD:** Jenkins
- **Version Control:** GitHub
- **OS:** Ubuntu 22.04
- **Programming Language:** Express.js (Alraedy Provided)

## Challenges I Faced & How I Resolved Them
1. **Integrating Terraform:**
   - As deploying on AWS ECS using Jenkins and Terraform, I initially faced difficulty provisioning AWS resources through Terraform.  
   - I resolved this by using CHATGPT and successfully set-uped infra using the Terraform .

2. **Allocating Elastic IP via NLB:**
   - ECS tasks kept receiving new public IPs on redeployment, which made accessing the app consistently difficult. Issue of IAM Role was raising in this case after provideing all the permissions even.  
   - I was not able to fully solve this during the project but planned to use a Network Load Balancer to attach an Elastic IP for stable access.

3. **CloudWatch Logging & Monitoring using Terraform:**
   - I faced issues integrating CloudWatch for logging and monitoring using Terraform altough i set-uped it manually from the AWS Console.  
   - The issue was similar to the Elastic IP problem, so full automation was not achieved.

4. **Git Branching Strategy:**
   - Initially, I troubleshooted and deployed directly on the `main` branch, which caused instability.  
   - I implemented proper branching strategies in the end later in the project by creating a `dev` branch for testing changes safely before merging to `main`.

## Improvements I Plan to Implement as i have implemented earlier in my projects:
- Integrate **SonarQube** for automated code quality checks.
- Integrate **Trivy** for Image checks.
- Integrate **OWASP Dependency-Check** for security vulnerability scanning.
- Fully automate Elastic IP assignment via NLB for consistent access.
- Automate CloudWatch logging and monitoring for ECS containers.
- Implement blue/green deployments for zero-downtime updates.
- Add rollback strategies in Jenkins for failed deployments.