# Secure AWS VPC Infrastructure

A multi-AZ VPC with public web servers and a private RDS database, built entirely with Terraform. This demonstrates how to structure a network so that critical resources (databases) are protected from direct internet access, while web services remain available to users.

---

### What You're Looking At

This is a working example of network isolation in AWS. The idea is simple: your database has no route to the internet. Only your web servers can reach it. If someone breaks into a web server, they still can't directly access the database without jumping through additional security layers.

The project lives in two availability zones for high availability. If one entire datacenter goes down, your application keeps running in the other.

---

### Architecture

**The layout:**

Two subnets in each AZ:
- Public: 10.0.1.0/24 (AZ 1a) and 10.0.3.0/24 (AZ 1b) where web servers live
- Private: 10.0.2.0/24 (AZ 1a) and 10.0.4.0/24 (AZ 1b) where the database lives

Traffic flows like this:
- Internet users hit the Internet Gateway, which routes to web servers in the public subnets
- Web servers can talk to the RDS database in the private subnets
- Private subnets can reach the internet *outbound* (for package updates, etc.) through NAT Gateways, but nothing from the internet can initiate a connection to them

---

### Why This

**Public subnet = exposed**
- Web servers live here because users need to reach them
- Still protected by security groups (only ports 80, 443, 22)
- If hacked, the damage is contained

**Private subnet = locked down**
- Database lives here where it's unreachable from the internet
- Can only accept connections from the web server security group
- Even if someone compromises the web server, they hit another wall at the database

---

### Design Decisions

**Why multi-AZ?**
Simple: if AWS takes down the entire us-east-1a datacenter, your database still runs in 1b. The RDS failover is automatic.

**Why separate public and private subnets?**
Only expose what needs to be exposed. Databases don't need to be on the internet. This is non-negotiable for security.

**Why NAT Gateway instead of a NAT instance?**
Cost vs. management. NAT Gateway costs ~$32/month per AZ, but AWS manages it completely. A NAT instance would cost ~$5/month but you'd have to patch it, monitor it, and handle failover yourself. For a prod-like setup, NAT Gateway is the right call. For a hobby lab, NAT instance would work.

**Security group rules:**

Web servers allow:
- Port 80/443 from anywhere (0.0.0.0/0) - necessary for users
- Port 22 from your IP only - SSH access restricted to you
- All outbound traffic

Database allows:
- Port 3306 only from the web server security group - only web servers can talk to it
- Everything else blocked

Even if port 3306 is somehow exposed, only traffic coming from a web server is accepted.

---

### Prerequisites

- AWS account (free tier eligible for this project)
- Terraform installed locally (v1.0+)
- AWS CLI configured with credentials
- WSL with Arch (you already have this)
- SSH key pair created in AWS (for EC2 access)

---

### Deployment Instructions

#### Step 1: Clone and navigate to the project

```bash
git clone https://github.com/Chunkylovr/secure-aws-vpc-infrastructure.git
cd secure-aws-vpc-infrastructure
```

#### Step 2: Configure Terraform variables

Edit `terraform.tfvars` and set:
- `aws_region` (e.g., "us-east-1")
- `environment` (e.g., "dev")
- `your_ip` (your public IP, for SSH access)

#### Step 3: Initialize Terraform

```bash
terraform init
```

This downloads the required AWS provider and prepares the working directory.

#### Step 4: Review the plan

```bash
terraform plan
```

This shows you exactly what will be created. Review it carefully before applying.

#### Step 5: Deploy

```bash
terraform apply
```

Type `yes` when prompted. Terraform will create all resources. This takes 5-10 minutes (RDS takes the longest).

#### Step 6: Capture outputs

After deployment, Terraform displays outputs like:
- Web server public IP addresses
- RDS endpoint
- Security group IDs

Save these — you'll need them for testing.

---

### Verification & Testing

#### Test 1: SSH into the web server

```bash
ssh -i /path/to/your/key.pem ubuntu@[web-server-public-ip]
```

If this works, the public subnet and security group are configured correctly.

#### Test 2: Connect to the database from the web server

From inside the web server SSH session:

```bash
mysql -h [rds-endpoint] -u admin -p
```

When prompted, enter the password you set in `terraform.tfvars`.

If this works, the private subnet and security group rules are configured correctly.

#### Test 3: Try to connect to the database from your laptop (should fail)

```bash
mysql -h [rds-endpoint] -u admin -p
```

This should timeout or be refused. If it connects, your security group is too permissive.

#### Test 4: Verify multi-AZ

In the AWS console, go to RDS > Databases and check that:
- The database has a standby replica in a different AZ
- Failover is enabled

---

### Costs

Running this costs money while it's active. Be aware of the NAT Gateway: at $32/month per AZ, that's $64/month just for the two gateways. EC2 and RDS are free tier if you're careful. Everything else is free.

When you're done testing, run `terraform destroy` to delete everything and stop the charges. It takes a few minutes.

If you want to keep it running without the cost, you can comment out the NAT Gateways and manage outbound traffic differently, but that defeats the point of showing a prod-like setup.

---

### Cleanup

When you're done testing, destroy all resources to avoid unexpected charges:

```bash
terraform destroy
```

Type `yes` when prompted. This removes everything except the VPC deletion policy (AWS deletes the VPC last).

---

### Lessons Learned

- How long RDS actually takes to create (spoiler: longer than EC2)

---

### Useful References

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
