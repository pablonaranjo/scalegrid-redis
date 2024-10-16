## REDIS Cluster HA 

```
Assignment:

Create 2 Kubernetes clusters in your preferred cloud platform.

Deploy a Redis cluster across the 2 Kubernetes clusters in a High Availability setup through helm charts only.
You must have nodes in both kubernetes clusters of the redis HA solution.
```


This project installs a Redis Cluster HA using Sentinel into 2 Kubernetes Clusters
It uses terragrunt and terraform to define the resources. The main modules are:

- terraform-aws-modules/eks/aws (to create the EKS resources)
- helm/release (helm release module to deploy redis)

Requirements:
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [helm](https://helm.sh/docs/intro/install/)
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

- [AWS Account](https://aws.amazon.com/free/?gclid=Cj0KCQjwyL24BhCtARIsALo0fSAux8h9PhdHE_VRhWGb3mZJKsmakMX0n69rQDjn35yfDF81YQ1lm3QaAgsvEALw_wcB&trk=349e66be-cf8d-4106-ae2c-54262fc45524&sc_channel=ps&ef_id=Cj0KCQjwyL24BhCtARIsALo0fSAux8h9PhdHE_VRhWGb3mZJKsmakMX0n69rQDjn35yfDF81YQ1lm3QaAgsvEALw_wcB:G:s&s_kwcid=AL!4422!3!455709741582!e!!g!!aws%20account!10817378576!108173614202&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all)
- [AWS VPC](https://console.aws.amazon.com/vpcconsole/home?region=us-east-1#vpcs:)
- [AWS VPC Subnets](https://console.aws.amazon.com/vpcconsole/home?region=us-east-1#subnets:)

Replace the AWS values into `account.hcl`.
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
- `redis-node-0.redis.redis1.scalegrid-example.com`
- `redis-node-1.redis.redis1.scalegrid-example.com`
- `redis-node-0.redis.redis2.scalegrid-example.com`
- `redis-node-1.redis.redis2.scalegrid-example.com`

and also a dns entry for each redis cluster (service):
- `redis.redis1.scalegrid-example.com`
- `redis.redis2.scalegrid-example.com`

This project does not include a LoadBalancer or Proxy to connect to a single endpoint. Connection to any of the clusters will return RO access, for write access you need to connect to the master. To check what is the master you can run:

```
redis-cli -h redis.redis1.scalegrid-example.com
SENTINEL GET-MASTER-ADDR-BY-NAME 
```
