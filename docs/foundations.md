# Foundations

Four services show up in almost everything else. Learn these before the catalog.

## IAM

IAM answers who can do what. A user is a person. A role is a hat a person or a service puts on. A policy is the list of allowed actions.

A **permissions boundary** is an optional ceiling on a user or role: policies grant access, but the user cannot exceed what the boundary allows. Lab 1 skips boundaries; see [Create an admin IAM user](../labs/01-account-and-iam/runbooks/create-admin-iam-user.md) for the full comparison.

The root user owns the account. It cannot be restricted by IAM policies the way users can. If root credentials leak, the whole account is at risk. Use root briefly for setup (MFA on root, create an admin IAM user), then do daily work as that IAM user—not root.

Azure equivalent: Entra ID users and role assignments. An IAM policy is the permission list; an IAM role is closer to a role you assign than to an Entra group. Avoiding root for daily work is like avoiding the subscription Global Administrator for everyday tasks.

Lab walkthrough: [Create an admin IAM user](../labs/01-account-and-iam/runbooks/create-admin-iam-user.md) (includes why and when root is still OK).

## VPC

A VPC is your private network in one region. Subnets split it. A route table decides where packets go. An internet gateway is the door to the public internet. A security group is the firewall on a resource.

Azure equivalent: a virtual network, subnets, a route table, and a network security group. AWS security groups are stateful; you allow the request, and the reply is allowed back.

## EC2

EC2 is a virtual machine. You pick an instance type (CPU and memory), an AMI (the disk image), a subnet, and a security group. You pay while it is running. Stop it when you are finished.

Azure equivalent: a virtual machine. An AMI is the image. A security group is the closest thing to the NIC's firewall rules.

## S3

S3 stores objects (files) in buckets. Buckets are private unless you deliberately open them. A bucket name is global across all AWS accounts, so `my-files` is probably taken. Use a name that includes your project.

Azure equivalent: a storage account plus a blob container. In AWS the bucket is the container, and there is no separate storage-account wrapper.

## What comes after

Once these four feel ordinary, the rest of AWS is mostly "a managed version of something you would otherwise run yourself": databases, queues, functions, and logs.
