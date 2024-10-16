## REDIS Cluster HA 

This project installs a Redis Cluster HA using Sentinel into 2 Kubernetes Clusters
It uses terragrunt and terraform to define the resources. The main modules are:

- terraform-aws-modules/eks/aws (to create the EKS resources)
- helm/release (helm release module to deploy redis)

Requirements:
- terraform
- terragrunt
- helm
- awscli
- kubectl

- AWS Account
- AWS VPC
- AWS VPC Subnets

Replace the AWS values into `account.hcl`
Also update aws profile in `kubernetes.hcl`

# Deploy 2 Kubernetes Clusters and addons:

```
cd terragrunt/kubernetes/cluster-1
terragrunt apply
```
```
cd terragrunt/kubernetes/cluster-1/addon/ebs
terragrunt apply
```
```
cd terragrunt/kubernetes/cluster-2
terragrunt apply
```
```
cd terragrunt/kubernetes/cluster-2/addon/ebs
terragrunt apply
```
```
cd terragrunt/external-dns-1
terragrunt apply
```
```
cd terragrunt/external-dns-2
terragrunt apply
```

# Deploy Redis
Redis is deployed using helm chart bitnami/redis. It uses SENTINEL for simplicity to achieve the requirement of HA without having the hard requirments from a REDIS-CLUSTER. However, it’s worth mentioning that Redis Sentinel does not provide any sharding mechanisms. All write operations still go to a single master node, which could be a potential bottleneck in a large-scale system.

```
cd terragrunt/redis/redis-1
terragrunt apply
```
```
cd terragrunt/redis/redis-2
terragrunt apply
```

This should create a dns entry for each redis node:
`redis-node-0.redis.redis1.scalegrid-example.com`
`redis-node-1.redis.redis1.scalegrid-example.com`
`redis-node-0.redis.redis2.scalegrid-example.com`
`redis-node-1.redis.redis2.scalegrid-example.com`

and also a dns entry for each redis cluster (service):
`redis.redis1.scalegrid-example.com`
`redis.redis2.scalegrid-example.com`

This project does not include a LoadBalancer or Proxy to connect to a single endpoint. Connection to any of the clusters will return RO access, for write access you need to connect to the master. To check what is the master you can run:

```
redis-cli -h redis.redis1.scalegrid-example.com
SENTINEL GET-MASTER-ADDR-BY-NAME 
```
