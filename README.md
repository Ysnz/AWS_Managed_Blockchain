# AWS_Managed_Bockchain_Setup

This a detailed description of setting up the AWS Managed Blockchain Service.

![](images/images.png 'Amazon Managed Blockchain')

## Setting up AWS Managed Blockchain Service

The AWS Blockchain service looks like the picture given below.

![](images/images1.png 'Amazon Managed Blockchain')

![](images/images2.png 'Amazon Managed Blockchain-2')

![](images/images3.png 'Amazon Managed Blockchain-3')

![](images/images4.png 'Amazon Managed Blockchain-4')

![](images/images5.png 'Amazon Managed Blockchain-5')

- Amazon Managed Blockchain is a fully managed service for creating and managing blockchain networks and network resources using open-source frameworks.

- Blockchain allows you to build applications where multiple parties can securely and transparently run transactions and share data without the need for a trusted, central authority.

- You can use Managed Blockchain to create scalable blockchain resources and networks quickly and efficiently using the AWS Management Console, the AWS CLI, or the Managed Blockchain SDK.

### Get Started Creating a Hyperledger Fabric Blockchain Network Using Amazon Managed Blockchain

##### Prerequisites and Considerations

- An AWS account
- A Linux Client (EC2 Instance)
- A VPC
- Permissions to Create an Interface VPC Endpoint
- EC2 Security Groups That Allow Communication on Required Ports
- Additional Considerations

##### Steps

- Step 1: Create the Network and First Member
- Step 2: Create an Endpoint
- Step 3: Create a Peer Node
- Step 4: Set Up a Client
- Step 5: Enroll the Member Admin
- Step 6: Create a Channel
- Step 7: Run Chaincode
- Step 8: Invite a Member and Create a Multi-Member Channel

# Step 1: Create the Network and First Member<a name="get-started-create-network"></a>

When you create the network, you specify the following parameters along with basic information such as names and descriptions:

- The open\-source framework and version\. This tutorial uses Hyperledger Fabric version 2\.2\.
- The voting policy for proposals on the network\. For more information, see [Work with Proposals for a Hyperledger Fabric Network on Amazon Managed Blockchain](managed-blockchain-proposals.md)\.
- The first member of the network, including the administrative user and administrative password that are used to authenticate to the member's certificate authority \(CA\)\.
  **Important**  
  Each member that is created accrues charges according to the membership rate for the network\. For more information, see [Amazon Managed Blockchain Pricing](http://aws.amazon.com/managed-blockchain/pricing/hyperledger/)\.

Create the network using the AWS CLI or Managed Blockchain console according to the following instructions\. It takes around 30 minutes for Managed Blockchain to provision resources and bring the network online\.

## To create a Hyperledger Fabric network using the AWS Management Console<a name="w79aab9c11b9b1"></a>

1. Open the Managed Blockchain console at [https://console\.aws\.amazon\.com/managedblockchain/](https://console.aws.amazon.com/managedblockchain/)\.

1. Choose **Create private network**\.

1. Under **Blockchain frameworks**:

   1. Select the blockchain framework to use\. This tutorial is based on **Hyperledger Fabric version 2\.2**\.

   1. Select the **Network edition** to use\. The network edition determines attributes of the network, such as the maximum number of members, nodes per member, and transaction throughput\. Different editions have different rates associated with the membership\. For more information, see [Amazon Managed Blockchain Pricing](https://aws.amazon.com/managed-blockchain/pricing)\.

1. Enter a **Network name and description**\.

1. Under **Voting Policy**, choose the following:

   1. Enter the **Approval threshold percentage** along with the comparator, either **Greater than** or **Greater than or equal to**\. For a proposal to pass, the Yes votes cast must meet this threshold before the vote duration expires\.

   1. Enter the **Proposal duration in hours**\. If enough votes are not cast within this duration to either approve or reject a proposal, the proposal status is `EXPIRED`, no further votes on this proposal are allowed, and the proposal does not pass\.

1. Choose **Next**, and then, under **Create member**, do the following to define the first member for the network, which you own:

   1. Enter a **Member name** that will be visible to all members and an optional **Description**\.

   1. Under **Hyperledger Fabric certificate authority \(CA\) configuration** specify a username and password to be used as the administrator on the Hyperledger Fabric CA\. Remember the user name and password\. You need them later any time that you create users and resources that need to authenticate\.

   1. Choose **Next**\.

1. Review **Network options** and **Member options**, and then choose **Create network and member**\.

   The **Networks** list shows the name and **Network ID** of the network you created, with a **Status** of **Creating**\. It takes around 30 minutes for Managed Blockchain to create your network, after which the **Status** is **Available**\.

## To create a Hyperledger Fabric network using the AWS CLI<a name="w79aab9c11b9b3"></a>

Use the `create-network` command as shown in the following example\. Consider the following:

- The example shows `HYPERLEDGER_FABRIC` as the `Framework` and `2.2` as the `FrameworkVersion`\. The `FrameworkConfiguration` properties for `--network-configuration` and `--member-configuration` options may be different for other frameworks and versions\.
- The `AdminPassword` must be at least 8 characters long and no more than 32 characters\. It must contain at least one uppercase letter, one lowercase letter, and one digit\. It cannot have a single quote\(‘\), double quote\(“\), forward slash\(/\), backward slash\(\\\), @, percent sign \(%\), or a space\.
- The member name must not contain any special characters\.
- Remember the user name and password\. You need them later any time you create users and resources that need to authenticate\.

```
[ec2-user@ip-192-0-2-17 ~]$ aws managedblockchain create-network \
--cli-input-json '{\"Name\":\"OurBlockchainNet\", \"Description\":\"OurBlockchainNetDesc\", \"Framework\":\"HYPERLEDGER_FABRIC\",\"FrameworkVersion\": \"2.2\", \"FrameworkConfiguration\": {\"Fabric\": {\"Edition\": \"STARTER\"}}, \"VotingPolicy\": {\"ApprovalThresholdPolicy\": {\"ThresholdPercentage\": 50, \"ProposalDurationInHours\": 24, \"ThresholdComparator\": \"GREATER_THAN\"}}, “MemberConfiguration”: {\"Name\":\"org1\", \"Description\":\"Org1 first member of network\", \"FrameworkConfiguration\":{\"Fabric\":\n{\"AdminUsername\":\"MyAdminUser\",\"AdminPassword\":\"Password123\"}}, \"LogPublishingConfiguration\": {\"Fabric\":{\"CaLogs\":{\"Cloudwatch\": {\"Enabled\": true}}}}}}'
```

The command returns the Network ID and the Member ID, as shown in the following example:

```
{
    "NetworkId": "n-MWY63ZJZU5HGNCMBQER7IN6OIU",
    "MemberId": "m-K46ICRRXJRCGRNNS4ES4XUUS5A"
}
```

The **Networks** page on the console shows a **Status** of **Available** when the network is ready\. Alternatively, you can use the `list-networks` command, as shown in the following example, to confirm the network status\.

```
aws managedblockchain list-networks
```

The command returns information about the network, including an `AVAILABLE` status\.

```
{
    "Networks": [
        {
            "Id": "n-MWY63ZJZU5HGNCMBQER7IN6OIU",
            "Name": "MyTestNetwork",
            "Description": "MyNetDescription",
            "Framework": "HYPERLEDGER_FABRIC",
            "FrameworkVersion": "2.2",
            "Status": "AVAILABLE",
            "CreationDate": 1541497086.888,
        }
    ]
}
```

# Step 2: Create and Configure the Interface VPC Endpoint<a name="get-started-create-endpoint"></a>

Now that the network is up and running in your VPC, you set up an interface VPC endpoint \(AWS PrivateLink\) for your member\. This allows the Amazon EC2 instance that you use as a Hyperledger Fabric client to interact with the Hyperledger Fabric endpoints that Amazon Managed Blockchain exposes for your member and network resources\. For more information, see [Interface VPC Endpoints \(AWS PrivateLink\)](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-interface.html) in the _Amazon VPC User Guide_\. Applicable charges for interface VPC endpoints apply\. For more information, see [AWS PrivateLink Pricing](https://aws.amazon.com/privatelink/pricing/)\.

The AWS Identity and Access Management \(IAM\) principal \(user\) identity that you use must have sufficient IAM permissions to create an interface VPC endpoint in your AWS account\. For more information, see [Controlling Access \- Creating and Managing VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_IAM.html#vpc-endpoints-iam) in the _Amazon VPC User Guide_\.

You can create the interface VPC endpoint using a shortcut in the Managed Blockchain console\.

**To create an interface VPC endpoint using the Managed Blockchain console**

1. Open the Managed Blockchain console at [https://console\.aws\.amazon\.com/managedblockchain/](https://console.aws.amazon.com/managedblockchain/)\.

1. Choose **Networks**, select your network from the list, and then choose **View details**\.

1. Choose **Create VPC endpoint**\.

1. Choose a **VPC**\.

1. For **Subnets**, choose a subnet from the list, and then choose additional subnets as necessary\.

1. For **Security groups**, choose an EC2 security group from the list, and then choose additional security groups as necessary\. We recommend that you select the same security group that your framework client EC2 instance is associated with\.

1. Choose **Create**\.

# Step 3: Create a Peer Node in Your Membership<a name="get-started-create-peer-node"></a>

Now that your network and the first member are up and running, you can use the Managed Blockchain console or the AWS CLI to create a peer node\. Your member's peer nodes interact with other members' peer nodes on the blockchain to query and update the ledger, and store a local copy of the ledger\.

Use one of the following procedures to create a peer node\.

## To create a peer node using the AWS Management Console<a name="w79aab9c15b7b1"></a>

1. Open the Managed Blockchain console at [https://console\.aws\.amazon\.com/managedblockchain/](https://console.aws.amazon.com/managedblockchain/)\.

1. Choose **Networks**, select the network from the list, and then choose **View details**\.

1. Select a **Member** from the list, and then choose **Create peer node**\.

1. Choose configuration parameters for your peer node according to the guidelines in [Work with Hyperledger Fabric Peer Nodes on Managed Blockchain](managed-blockchain-hyperledger-peer-nodes.md), and then choose **Create peer node**\.

## To create a peer node using the AWS CLI<a name="w79aab9c15b7b3"></a>

- Use the `create-node` command, as shown in the following example\. Replace the value of `--network-id`, `--member-id`, and `AvailabilityZone` as appropriate\.

  ```
  [ec2-user@ip-192-0-2-17 ~]$ aws managedblockchain create-node \
  --node-configuration '{"InstanceType":"bc.t3.small","AvailabilityZone":"us-east-1a"}' \
  --network-id n-MWY63ZJZU5HGNCMBQER7IN6OIU \
  --member-id m-K46ICRRXJRCGRNNS4ES4XUUS5A
  ```

  The command returns output that includes the peer node's `NodeID`, as shown in the following example:

  ```
  {
       "NodeId": "nd-6EAJ5VA43JGGNPXOUZP7Y47E4Y"
  }
  ```

  # Step 4: Create an Amazon EC2 Instance and Set Up the Hyperledger Fabric Client<a name="get-started-create-client"></a>

To complete this step, you launch an Amazon EC2 instance using the Amazon Linux AMI\. Consider the following requirements and recommendations when you create the Hyperledger Fabric client Amazon EC2 instance:

- We recommend that you launch the client Amazon EC2 instance in the same VPC and using the same security group as the VPC Endpoint that you created in [Step 2: Create and Configure the Interface VPC Endpoint](get-started-create-endpoint.md)\. This simplifies connectivity between the Amazon EC2 instance and the Interface VPC Endpoint\.
- We recommend that the EC2 security group shared by the VPC Endpoint and the client Amazon EC2 instance have rules that allow all inbound and outbound traffic between members of the security group\. This also simplifies connectivity\. In addition, ensure that this security group or another security group associated with the client Amazon EC2 instance has a rule that allows inbound SSH connections from a source that includes your SSH client's IP address\. For more information about security groups and required rules, see [Configuring Security Groups for Hyperledger Fabric on Amazon Managed Blockchain](managed-blockchain-security-sgs.md)\.
- Make sure that the client Amazon EC2 instance is configured with an automatically assigned public IP address and that you can connect to it using SSH\. For more information, see [Getting Started with Amazon EC2 Linux Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html) and [Connect to your Linux instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html) in the _Amazon EC2 User Guide for Linux Instances_\.
- Make sure that the service role associated with the EC2 instance allows access to the Amazon S3 bucket where Managed Blockchain certificates are stored and that it has required permissions for working with Managed Blockchain resources\. For more information, see [Example IAM Role Permissions Policy for Hyperledger Fabric Client EC2 Instance](security_iam_hyperledger_ec2_client.md)\.

**Note**  
An AWS CloudFormation template to create a Hyperledger Fabric client is available in [amazon\-managed\-blockchain\-client\-templates repository](https://github.com/awslabs/amazon-managed-blockchain-client-templates) on Github\. For more information, see the [readme\.md](https://github.com/awslabs/amazon-managed-blockchain-client-templates/blob/master/README.md) in that repository\. For more information about using AWS CloudFormation, see [Getting Started](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.Walkthrough.html) in the _AWS CloudFormation User Guide_\.

## Step 4\.1: Install Packages<a name="get-started-client-install-packages"></a>

Your Hyperledger Fabric client needs some packages and samples installed so that you can work with the Hyperledger Fabric resources\. In this step, you install Go, Docker, Docker Compose, and some other utilities\. You also create variables in the `~/.bash_profile` for your development environment\. These are prerequisites for installing and using Hyperledger tools\.

While connected to the Hyperledger Fabric client using SSH, run the following commands to install utilities, install docker, and configure the Docker user to be the default user for the Amazon EC2 instance:

```
sudo yum update -y
```

```
sudo yum install jq telnet emacs docker libtool libtool-ltdl-devel git -y
```

```
sudo service docker start
```

```
sudo usermod -a -G docker ec2-user
```

Log out and log in again for the `usermod` command to take effect\.

Run the following commands to install Docker Compose\.

```
sudo curl -L \
https://github.com/docker/compose/releases/download/1.20.0/docker-compose-`uname \
-s`-`uname -m` -o /usr/local/bin/docker-compose
```

```
sudo chmod a+x /usr/local/bin/docker-compose
```

Run the following commands to install golang\.

```
wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
```

```
tar -xzf go1.14.4.linux-amd64.tar.gz
```

```
sudo mv go /usr/local
```

```
sudo yum install git -y
```

Use a text editor to set up variables such as `GOROOT` and `GOPATH` in your `~/.bashrc` or `~/.bash_profile` and save the updates\. The following example shows entries in `.bash_profile`\.

```
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/.local/bin:$HOME/bin

# GOROOT is the location where Go package is installed on your system
export GOROOT=/usr/local/go

# GOPATH is the location of your work directory
export GOPATH=$HOME/go

# CASERVICEENDPOINT is the endpoint to reach your member's CA
# for example ca.m-K46ICRRXJRCGRNNS4ES4XUUS5A.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.us-east-1.amazonaws.com:30002
export CASERVICEENDPOINT=MyMemberCaEndpoint

# ORDERER is the endpoint to reach your network's orderer
# for example orderer.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.amazonaws.com:30001
export ORDERER=MyNetworkOrdererEndpoint

# Update PATH so that you can access the go binary system wide
export PATH=$GOROOT/bin:$PATH
export PATH=$PATH:/home/ec2-user/go/src/github.com/hyperledger/fabric-ca/bin
```

After you update `.bash_profile`, apply the changes:

```
source ~/.bash_profile
```

After the installation, verify that you have the correct versions installed:

- Docker–17\.06\.2\-ce or later
- Docker\-compose–1\.14\.0 or later
- Go–1\.14\.x

To check the Docker version, run the following command:

```
sudo docker version
```

The command returns output similar to the following:

```
Client:
 Version: 18.06.1-ce
 API version: 1.38
 Go version: go1.14.4
 Git commit: CommitHash
 Built: Tue Oct 2 18:06:45 2018
 OS/Arch: linux/amd64
 Experimental: false

Server:
 Engine:
 Version: 18.06.1-ce
 API version: 1.38 (minimum version 1.12)
 Go version: go1.14.4
 Git commit: e68fc7a/18.06.1-ce
 Built: Tue Oct 2 18:08:26 2018
 OS/Arch: linux/amd64
 Experimental: false
```

To check the version of Docker Compose, run the following command:

```
sudo /usr/local/bin/docker-compose version
```

The command returns output similar to the following:

```
docker-compose version 1.22.0, build f46880fe
docker-py version: 3.4.1
CPython version: 3.6.6
OpenSSL version: OpenSSL 1.1.0f  25 May 2017
```

To check the version of go, run the following command:

```
go version
```

The command returns output similar to the following:

```
go version go1.14.4 linux/amd64
```

## Step 4\.2: Set Up the Hyperledger Fabric CA Client<a name="get-started-client-setup-CA-client"></a>

In this step, you verify that you can connect to the Hyperledger Fabric CA using the VPC endpoint you configured in [Step 2: Create and Configure the Interface VPC Endpoint](get-started-create-endpoint.md)\. You then install the Hyperledger Fabric CA client\. The Fabric CA issues certificates to administrators and network peers\.

To verify connectivity to the Hyperledger Fabric CA, you need the `CAEndpoint`\. Use the `get-member` command to get the CA endpoint for your member, as shown in the following example\. Replace the values of `--network-id` and `--member-id` with the values returned in [Step 1: Create the Network and First Member](get-started-create-network.md)\.

```
aws managedblockchain get-member \
--network-id n-MWY63ZJZU5HGNCMBQER7IN6OIU \
--member-id m-K46ICRRXJRCGRNNS4ES4XUUS5A
```

Use `curl` or `telnet` to verify that the endpoint resolves\. In the following example, the value of the variable `$CASERVICEENDPOINT` is the **CAEndpoint** returned by the `get-member` command\.

```
curl https://$CASERVICEENDPOINT/cainfo -k
```

The command should return output similar to the following:

```
{"result":{"CAName":"abcd1efghijkllmn5op3q52rst","CAChain":"LongStringOfCharacters","Version":"1.4.7-snapshot-"}
,"errors":[],"messages":[],"success":true}
```

Note that Hyperledger Fabric v2\.2 networks should use version 1\.4 of the CA client\.

Alternatively, you can connect to the Fabric CA using Telnet as shown in the following example\. Use the same endpoint in the `curl` example, but separate the endpoint and the port as shown in the following example\.

```
telnet CaEndpoint-Without-Port CaPort
```

The command should return output similar to the following:

```
Trying 10.0.1.228...
Connected to ca.m-K46ICRRXJRCGRNNS4ES4XUUS5A.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.us-east-1.amazonaws.com.
Escape character is '^]'.
```

If you are unable to connect to the Fabric CA, double\-check your network settings to ensure that the client Amazon EC2 instance has connectivity with the VPC Endpoint\. In particular, ensure that the security groups associated with both the VPC Endpoint and the client Amazon EC2 instance have inbound and outbound rules that allow traffic between them\.

Now that you have verified that you can connect to the Hyperledger Fabric CA, run the following commands to configure the CA client\.

**Note**  
If you are working with Hyperledger Fabric v1\.2 networks, you need to install and build the correct client version, which is available at [https://github\.com/hyperledger/fabric\-ca/releases/download/v1\.2\.1/hyperledger\-fabric\-ca\-linux\-amd64\-1\.2\.1\.tar\.gz](https://github.com/hyperledger/fabric-ca/releases/download/v1.2.1/hyperledger-fabric-ca-linux-amd64-1.2.1.tar.gz)\.

```
mkdir -p /home/ec2-user/go/src/github.com/hyperledger/fabric-ca
```

```
cd /home/ec2-user/go/src/github.com/hyperledger/fabric-ca
```

```
wget https://github.com/hyperledger/fabric-ca/releases/download/v1.4.7/hyperledger-fabric-ca-linux-amd64-1.4.7.tar.gz
```

```
tar -xzf hyperledger-fabric-ca-linux-amd64-1.4.7.tar.gz
```

## Step 4\.3: Clone the Samples Repository<a name="get-started-client-clone-samples"></a>

**Note**  
If you are working with Hyperledger Fabric v1\.2 or v1\.4 networks, use `--branch v1.2.0` or `--branch v1.4.7` instead of `--branch v2.2.3` in the following commmands\.

```
cd /home/ec2-user
```

```
git clone --branch v2.2.3 https://github.com/hyperledger/fabric-samples.git
```

## Step 4\.4: Configure and Run Docker Compose to Start the Hyperledger Fabric CLI<a name="get-started-client-configure-peer-cli"></a>

Use a text editor to create a configuration file for Docker Compose named `docker-compose-cli.yaml` in the `/home/ec2-user` directory, which you use to run the Hyperledger Fabric CLI\. You use this CLI to interact with peer nodes that your member owns\. Copy the following contents into the file and replace the `placeholder values` according to the following guidance:

- _MyMemberID_ is the `MemberID` returned by the `aws managedblockchain list-members` AWS CLI command and shown on the member details page of the Managed Blockchain console—for example, `m-K46ICRRXJRCGRNNS4ES4XUUS5A`\.
- _MyPeerNodeEndpoint_ is the `PeerEndpoint` returned by the `aws managedblockchain get-node` command and listed on the node details page of the Managed Blockchain console—for example, nd\-6EAJ5VA43JGGNPXOUZP7Y47E4Y\.m\-K46ICRRXJRCGRNNS4ES4XUUS5A\.n\-MWY63ZJZU5HGNCMBQER7IN6OIU\.managedblockchain\._us\-east\-1_\.amazonaws\.com:_30003_\.

When you subsequently use the `cli` container to run commands—for example, `docker exec cli peer channel create`—you can use the `-e` option to override an environment variable that you establish in the `docker-compose-cli.yaml` file\.

**Note**  
If you are working with Hyperledger Fabric v1\.2 or v1\.4 networks, use `image: hyperledger/fabric-tools:1.2` or `image: hyperledger/fabric-tools:1.4` in the following example instead of `image: hyperledger/fabric-tools:2.2`\.  
In addition for v1\.2, use `CORE_LOGGING_LEVEL=info` instead of `FABRIC_LOGGING_SPEC=info`\.

```
version: '2'
services:
  cli:
    container_name: cli
    image: hyperledger/fabric-tools:2.2
    tty: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - FABRIC_LOGGING_SPEC=info # Set logging level to debug for more verbose logging
      - CORE_PEER_ID=cli
      - CORE_CHAINCODE_KEEPALIVE=10
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem
      - CORE_PEER_LOCALMSPID=MyMemberID
      - CORE_PEER_MSPCONFIGPATH=/opt/home/admin-msp
      - CORE_PEER_ADDRESS=MyPeerNodeEndpoint
    working_dir: /opt/home
    command: /bin/bash
    volumes:
        - /var/run/:/host/var/run/
        - /home/ec2-user/fabric-samples/chaincode:/opt/gopath/src/github.com/
        - /home/ec2-user:/opt/home
```

Run the following command to start the Hyperledger Fabric peer CLI container:

```
docker-compose -f docker-compose-cli.yaml up -d
```

If you restarted or logged out and back in after the `usermod` command in [Step 4\.1: Install Packages](#get-started-client-install-packages), you shouldn't need to run this command with `sudo`\. If the command fails, you can log out and log back in\. Alternatively, you can run the command using `sudo`, as shown in the following example:

```
sudo /usr/local/bin/docker-compose -f docker-compose-cli.yaml up -d
```

# Step 5: Enroll an Administrative User<a name="get-started-enroll-admin"></a>

In this step, you use a pre\-configured certificate to enroll a user with administrative permissions to your member's certificate authority \(CA\)\. To do this, you must create a certificate file\. You also need the endpoint for the CA of your member, and the user name and password for the user that you created in [Step 1: Create the Network and First Member](get-started-create-network.md)\.

## Step 5\.1: Create the Certificate File<a name="get-started-enroll-member-create-cert"></a>

Run the following command to copy the `managedblockchain-tls-chain.pem` to the `/home/ec2-user` directory\. Replace `MyRegion` with the AWS Region you are using—for example, `us-east-1`\.

```
aws s3 cp s3://MyRegion.managedblockchain/etc/managedblockchain-tls-chain.pem  /home/ec2-user/managedblockchain-tls-chain.pem
```

If the command fails with a permissions error, ensure that a service role associated with the EC2 instance allows access to the Amazon S3 bucket location\. For more information see [Example IAM Role Permissions Policy for Hyperledger Fabric Client EC2 Instance](security_iam_hyperledger_ec2_client.md)\.

Run the following command to test that you copied the contents to the file correctly:

```
openssl x509 -noout -text -in /home/ec2-user/managedblockchain-tls-chain.pem
```

The command should return the contents of the certificate in human\-readable format\.

## Step 5\.2: Enroll the Administrative User<a name="get-started-enroll-member-enroll"></a>

Managed Blockchain registers the user identity that you specified when you created the member as an administrator\. In Hyperledger Fabric, this user is known as the _bootstrap identity_ because the identity is used to enroll itself\. To enroll, you need the CA endpoint, as well as the user name and password for the administrator that you created in [Step 1: Create the Network and First Member](get-started-create-network.md)\. For information about registering other user identities as administrators before you enroll them, see [Register and Enroll a Hyperledger Fabric Admin](managed-blockchain-hyperledger-create-admin.md)\.

Use the `get-member` command to get the CA endpoint for your membership as shown in the following example\. Replace the values of `--network-id` and `--member-id` with the values returned in [Step 1: Create the Network and First Member](get-started-create-network.md)\.

```
aws managedblockchain get-member \
--network-id n-MWY63ZJZU5HGNCMBQER7IN6OIU \
--member-id m-K46ICRRXJRCGRNNS4ES4XUUS5A
```

The command returns information about the initial member that you created in the network, as shown in the following example\. Make a note of the `CaEndpoint`\. You also need the `AdminUsername` and password that you created along with the network\.

The command returns output similar to the following:

```
{
    "Member": {
        "NetworkId": "n-MWY63ZJZU5HGNCMBQER7IN6OIU",
        "Status": "AVAILABLE",
        "Description": "MyNetDescription",
        "FrameworkAttributes": {
            "Fabric": {
                "CaEndpoint": "ca.m-K46ICRRXJRCGRNNS4ES4XUUS5A.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.us-east-1.amazonaws.com:30002",
                "AdminUsername": "AdminUser"
            }
        },
        "StatusReason": "Network member created successfully",
        "CreationDate": 1542255358.74,
        "Id": "m-K46ICRRXJRCGRNNS4ES4XUUS5A",
        "Name": "org1"
    }
}
```

Use the CA endpoint, administrator profile, and the certificate file to enroll the member administrator using the `fabric-ca-client enroll` command, as shown in the following example:

```
fabric-ca-client enroll \
-u 'https://AdminUsername:AdminPassword@$CASERVICEENDPOINT' \
--tls.certfiles /home/ec2-user/managedblockchain-tls-chain.pem -M /home/ec2-user/admin-msp
```

An example command with fictitious administrator name, password, and endpoint is shown in the following example:

```
fabric-ca-client enroll \
-u https://AdminUser:Password123@ca.m-K46ICRRXJRCGRNNS4ES4XUUS5A.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.us-east-1.amazonaws.com:30002 \
--tls.certfiles /home/ec2-user/managedblockchain-tls-chain.pem -M /home/ec2-user/admin-msp
```

The command returns output similar to the following:

```
2018/11/16 02:21:40 [INFO] Created a default configuration file at /home/ec2-user/.fabric-ca-client/fabric-ca-client-config.yaml
2018/11/16 02:21:40 [INFO] TLS Enabled
2018/11/16 02:21:40 [INFO] generating key: &{A:ecdsa S:256}
2018/11/16 02:21:40 [INFO] encoded CSR
2018/11/16 02:21:40 [INFO] Stored client certificate at /home/ec2-user/admin-msp/signcerts/cert.pem
2018/11/16 02:21:40 [INFO] Stored root CA certificate at /home/ec2-user/admin-msp/cacerts/ca-abcd1efghijkllmn5op3q52rst-uqz2f2xakfd7vcfewqhckr7q5m-managedblockchain-us-east-1-amazonaws-com-30002.pem
```

**Important**  
It may take a minute or two after you enroll for you to be able to use your administrator certificate to create a channel with the ordering service\.

## Step 5\.3: Copy Certificates for the MSP<a name="get-started-enroll-member-copy-cert"></a>

In Hyperledger Fabric, the Membership Service Provider \(MSP\) identifies which root CAs and intermediate CAs are trusted to define the members of a trust domain\. Certificates for the administrator's MSP are in `/home/ec2-user/admin-msp` in this tutorial\. Because this MSP is for the member administrator, copy the certificates from `signcerts` to `admincerts` as shown in the following example\. The example assumes you are in the `/home/ec2-user` directory when running the command\.

```
cp -r /home/ec2-user/admin-msp/signcerts admin-msp/admincerts
```

# Step 6: Create a Hyperledger Fabric Channel<a name="get-started-create-channel"></a>

In Hyperledger Fabric, a ledger exists in the scope of a channel\. The ledger can be shared across the entire network if every member is operating on a common channel\. A channel also can be privatized to include only a specific set of participants\. Members can be in your AWS account, or they can be members that you invite from other AWS accounts\.

In this step, you set up a basic channel\. Later on in the tutorial, in [Step 8: Invite Another AWS Account to be a Member and Create a Multi\-Member Channel](get-started-joint-channel.md), you go through a similar process to set up a channel that includes another member\.

Wait a minute or two for the administrative permissions from previous steps to propagate, and then perform these tasks to create a channel\.

**Note**  
All Hyperledger Fabric networks on Managed Blockchain support a maximum of 8 channels per network, regardless of network edition\.

## Step 6\.1: Create configtx for Hyperledger Fabric Channel Creation<a name="get-started-create-channel-configtx"></a>

The `configtx.yaml` file contains details of the channel configuration\. For more information, see [Channel Configuration \(configtx\)](https://hyperledger-fabric.readthedocs.io/en/release-2.2/configtx.html) in the Hyperledger Fabric documentation\.

This `configtx.yaml` enables application features associated with Hyperledger Fabric 2\.2\. It is not compatible with Hyperledger Fabric 1\.2 or 1\.4\. For a `configtx.yaml` compatible with Hyperledger Fabric 1\.2 or 1\.4, see [Work with Channels](hyperledger-work-with-channels.md)\.

Use a text editor to create a file with the following contents and save it as `configtx.yaml` on your Hyperledger Fabric client\. Note the following placeholders and values\.

- Replace _MemberID_ with the MemberID you returned previously\. For example _m\-K46ICRRXJRCGRNNS4ES4XUUS5A_\.
- The `MSPDir` is set to the same directory location, `/opt/home/admin-msp`, that you established using the `CORE_PEER_MSPCONFIGPATH` environment variable in the Docker container for the Hyperledger Fabric CLI in [step 4\.4](get-started-create-client.md#get-started-client-configure-peer-cli)\.

**Important**  
This file is sensitive\. Artifacts from pasting can cause the file to fail with marshalling errors\. We recommend using `emacs` to edit it\. You can also use `VI`, but before using `VI`, enter `:set paste`, press `i` to enter insert mode, paste the contents, press escape, and then enter `:set nopaste` before saving\.

```
################################################################################
#
#   ORGANIZATIONS
#
#   This section defines the organizational identities that can be referenced
#   in the configuration profiles.
#
################################################################################
Organizations:
    # Org1 defines an MSP using the sampleconfig. It should never be used
    # in production but may be used as a template for other definitions.
    - &Org1
        # Name is the key by which this org will be referenced in channel
        # configuration transactions.
        # Name can include alphanumeric characters as well as dots and dashes.
        Name: MemberID
        # ID is the key by which this org's MSP definition will be referenced.
        # ID can include alphanumeric characters as well as dots and dashes.
        ID: MemberID
        # SkipAsForeign can be set to true for org definitions which are to be
        # inherited from the orderer system channel during channel creation.  This
        # is especially useful when an admin of a single org without access to the
        # MSP directories of the other orgs wishes to create a channel.  Note
        # this property must always be set to false for orgs included in block
        # creation.
        SkipAsForeign: false
        Policies: &Org1Policies
            Readers:
                Type: Signature
                Rule: "OR('Org1.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('Org1.admin', 'Org1.peer', 'Org1.client')"
            Writers:
                Type: Signature
                Rule: "OR('Org1.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('Org1.admin', 'Org1.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org1.admin')"
        # MSPDir is the filesystem path which contains the MSP configuration.
        MSPDir: /opt/home/admin-msp
        # AnchorPeers defines the location of peers which can be used for
        # cross-org gossip communication. Note, this value is only encoded in
        # the genesis block in the Application section context.
        AnchorPeers:
            - Host: 127.0.0.1
              Port: 7051
################################################################################
#
#   CAPABILITIES
#
#   This section defines the capabilities of fabric network. This is a new
#   concept as of v1.1.0 and should not be utilized in mixed networks with
#   v1.0.x peers and orderers.  Capabilities define features which must be
#   present in a fabric binary for that binary to safely participate in the
#   fabric network.  For instance, if a new MSP type is added, newer binaries
#   might recognize and validate the signatures from this type, while older
#   binaries without this support would be unable to validate those
#   transactions.  This could lead to different versions of the fabric binaries
#   having different world states.  Instead, defining a capability for a channel
#   informs those binaries without this capability that they must cease
#   processing transactions until they have been upgraded.  For v1.0.x if any
#   capabilities are defined (including a map with all capabilities turned off)
#   then the v1.0.x peer will deliberately crash.
#
################################################################################
Capabilities:
    # Channel capabilities apply to both the orderers and the peers and must be
    # supported by both.
    # Set the value of the capability to true to require it.
    # Note that setting a later Channel version capability to true will also
    # implicitly set prior Channel version capabilities to true. There is no need
    # to set each version capability to true (prior version capabilities remain
    # in this sample only to provide the list of valid values).
    Channel: &ChannelCapabilities
        # V2.0 for Channel is a catchall flag for behavior which has been
        # determined to be desired for all orderers and peers running at the v2.0.0
        # level, but which would be incompatible with orderers and peers from
        # prior releases.
        # Prior to enabling V2.0 channel capabilities, ensure that all
        # orderers and peers on a channel are at v2.0.0 or later.
        V2_0: true
    # Orderer capabilities apply only to the orderers, and may be safely
    # used with prior release peers.
    # Set the value of the capability to true to require it.
    Orderer: &OrdererCapabilities
        # V1.1 for Orderer is a catchall flag for behavior which has been
        # determined to be desired for all orderers running at the v1.1.x
        # level, but which would be incompatible with orderers from prior releases.
        # Prior to enabling V2.0 orderer capabilities, ensure that all
        # orderers on a channel are at v2.0.0 or later.
        V2_0: true
    # Application capabilities apply only to the peer network, and may be safely
    # used with prior release orderers.
    # Set the value of the capability to true to require it.
    # Note that setting a later Application version capability to true will also
    # implicitly set prior Application version capabilities to true. There is no need
    # to set each version capability to true (prior version capabilities remain
    # in this sample only to provide the list of valid values).
    Application: &ApplicationCapabilities
        # V2.0 for Application enables the new non-backwards compatible
        # features and fixes of fabric v2.0.
        # Prior to enabling V2.0 orderer capabilities, ensure that all
        # orderers on a channel are at v2.0.0 or later.
        V2_0: true
################################################################################
#
#   CHANNEL
#
#   This section defines the values to encode into a config transaction or
#   genesis block for channel related parameters.
#
################################################################################
Channel: &ChannelDefaults
    # Policies defines the set of policies at this level of the config tree
    # For Channel policies, their canonical path is
    #   /Channel/<PolicyName>
    Policies:
        # Who may invoke the 'Deliver' API
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        # Who may invoke the 'Broadcast' API
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        # By default, who may modify elements at this config level
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
    # Capabilities describes the channel level capabilities, see the
    # dedicated Capabilities section elsewhere in this file for a full
    # description
    Capabilities:
        <<: *ChannelCapabilities
################################################################################
#
#   APPLICATION
#
#   This section defines the values to encode into a config transaction or
#   genesis block for application-related parameters.
#
################################################################################
Application: &ApplicationDefaults
    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:
    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies: &ApplicationDefaultPolicies
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Endorsement:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"

    Capabilities:
        <<: *ApplicationCapabilities
################################################################################
#
#   PROFILES
#
#   Different configuration profiles may be encoded here to be specified as
#   parameters to the configtxgen tool. The profiles which specify consortiums
#   are to be used for generating the orderer genesis block. With the correct
#   consortium members defined in the orderer genesis block, channel creation
#   requests may be generated with only the org member names and a consortium
#   name.
#
################################################################################
Profiles:
    OneOrgChannel:
        <<: *ChannelDefaults
        Consortium: AWSSystemConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *Org1
```

Run the following command to generate the configtx peer block:

```
docker exec cli configtxgen \
-outputCreateChannelTx /opt/home/mychannel.pb \
-profile OneOrgChannel -channelID mychannel \
--configPath /opt/home/
```

**Important**  
Hyperledger Fabric 2\.2 requires that a channel ID contain only lowercase ASCII alphanumeric characters, dots \(\.\), and dashes \(\-\)\. It must start with a letter, and must be fewer than 250 characters\.

## Step 6\.2: Set Environment Variables for the Orderer<a name="get-started-create-channel-environment-variables"></a>

Set the `$ORDERER` environment variable for convenience\. Replace *orderer\.n\-MWY63ZJZU5HGNCMBQER7IN6OIU\.managedblockchain\.amazonaws\.com:*30001\*\* with the `OrderingServiceEndpoint` returned by the `aws managedblockchain get-network` command and listed on the network details page of the Managed Blockchain console\.

```
export ORDERER=orderer.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.amazonaws.com:30001
```

This variable must be exported each time you log out of the client\. To persist the variable across sessions, add the export statement to your `~/.bash_profile` as shown in the following example\.

```
# .bash_profile
...other configurations
export ORDERER=orderer.n-MWY63ZJZU5HGNCMBQER7IN6OIU.managedblockchain.amazonaws.com:30001
```

After updating `.bash_profile`, apply the changes:

```
source ~/.bash_profile
```

## Step 6\.3: Create the Channel<a name="get-started-create-channel-create-channel"></a>

Run the following command to create a channel using the variables that you established and the configtx peer block that you created:

```
docker exec cli peer channel create -c mychannel \
-f /opt/home/mychannel.pb -o $ORDERER \
--cafile /opt/home/managedblockchain-tls-chain.pem --tls
```

**Important**  
It may take a minute or two after you enroll an administrative user for you to be able to use your administrator certificate to create a channel with the ordering service\.

## Step 6\.4: Join Your Peer Node to the Channel<a name="get-started-create-channel-join-peer"></a>

Run the following command to join the peer node that you created earlier to the channel:

```
docker exec cli peer channel join -b mychannel.block \
-o $ORDERER --cafile /opt/home/managedblockchain-tls-chain.pem --tls
```

# Step 7: Install and Run Chaincode<a name="get-started-chaincode"></a>

In this section, you create and install a package for [golang sample chaincode](https://github.com/hyperledger/fabric-samples/blob/release-2.2/chaincode/abstore/go/abstore.go) on your peer node\. You also approve, commit, and verify the chaincode\.

You then use the chaincode's `init` command to initialize values attributed to entities `a` and `b` in the ledger, followed by the `query` command to confirm that initialization was successful\. Next, you use the chaincode's `invoke` command to transfer 10 units from `a` to `b` in the ledger\. Finally, you use the chaincode's `query` command again to confirm that the value attributed to `a` was decremented by 10 units in the ledger\.

## Step 7\.1: Install Vendor Dependencies<a name="get-started-chaincode-install-vendor-dependencies"></a>

Run the following commands to enable _vendoring_ for the Go module dependencies of your example chaincode\.

```
sudo chown -R ec2-user:ec2-user fabric-samples/
cd fabric-samples/chaincode/abstore/go/
GO111MODULE=on go mod vendor
cd -
```

## Step 7\.2: Create the Chaincode Package<a name="get-started-chaincode-create-package"></a>

Run the following command to create the example chaincode package\.

```
docker exec cli peer lifecycle chaincode package ./abstore.tar.gz \
--path fabric-samples/chaincode/abstore/go/ \
--label abstore_1
```

## Step 7\.3: Install the Package<a name="get-started-chaincode-install-package"></a>

Run the following command to install the chaincode package on the peer node\.

```
docker exec cli peer lifecycle chaincode install abstore.tar.gz
```

## Step 7\.4: Verify the Package<a name="get-started-chaincode-verify-package"></a>

Run the following command to verify that the chaincode package is installed on the peer node\.

```
docker exec cli peer lifecycle chaincode queryinstalled
```

The command returns the following if the package is installed successfully\.

```
Installed chaincodes on peer:
Package ID: MyPackageID, Label: abstore_1
```

## Step 7\.5: Approve the Chaincode<a name="get-started-chaincode-approve"></a>

Run the following commands to approve the chaincode definition for your organization\. Replace _MyPackageID_ with the _Package ID_ value returned in the previous step [Step 7\.4: Verify the Package](#get-started-chaincode-verify-package)\.

```
export CC_PACKAGE_ID=MyPackageID
docker exec cli peer lifecycle chaincode approveformyorg \
--orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel --name mycc --version v0 --sequence 1 --package-id $CC_PACKAGE_ID
```

## Step 7\.6: Check Commit Readiness<a name="get-started-chaincode-check-commit-readiness"></a>

Run the following command to check whether the chaincode definition is ready to be committed on the channel\.

```
docker exec cli peer lifecycle chaincode checkcommitreadiness \
--orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel --name mycc --version v0 --sequence 1
```

The command returns `true` if the chaincode is ready to be committed\.

```
Chaincode definition for chaincode 'mycc', version 'v0', sequence '1' on channel 'mychannel' approval status by org:
m-LVQMIJ75CNCUZATGHLDP24HUHM: true
```

## Step 7\.7: Commit the Chaincode<a name="get-started-chaincode-commit"></a>

Run the following command to commit the chaincode definition on the channel\.

```
docker exec cli peer lifecycle chaincode commit \
--orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel --name mycc --version v0 --sequence 1
```

## Step 7\.8: Verify the Chaincode<a name="get-started-chaincode-verify-committed"></a>

You might have to wait a minute or two for the commit to propagate to the peer node\. Run the following command to verify that the chaincode is committed\.

```
docker exec cli peer lifecycle chaincode querycommitted \
--channelID mychannel
```

The command returns the following if the chaincode is committed successfully\.

```
Committed chaincode definitions on channel 'mychannel':
Name: mycc, Version: v0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
```

## Step 7\.9: Initialize the Chaincode<a name="get-started-chaincode-initialize"></a>

Run the following command to initialize the chaincode\.

```
docker exec cli peer chaincode invoke \
--tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel \
--name mycc -c '{"Args":["init", "a", "100", "b", "200"]}'
```

The command returns the following when the chaincode is initialized\.

```
2021-12-20 19:23:05.434 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 0ad Chaincode invoke successful. result: status:200
```

## Step 7\.10: Query the Chaincode<a name="get-started-chaincode-query"></a>

You might need to wait a brief moment for the initialization from the previous command to complete before you run the following command to query a value\.

```
docker exec cli peer chaincode query \
--tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel \
--name mycc -c '{"Args":["query", "a"]}'
```

The command should return the value of `a`, which you initialized with a value of `100`\.

## Step 7\.11: Invoke the Chaincode<a name="get-started-chaincode-invoke"></a>

In the previous steps, you initialized the key `a` with a value of `100` and queried to verify\. Using the `invoke` command in the following example, you subtract `10` from that initial value\.

```
docker exec cli peer chaincode invoke \
--tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel \
--name mycc -c '{"Args":["invoke", "a", "b", "10"]}'
```

The command returns the following when the chaincode is invoked\.

```
2021-12-20 19:23:22.977 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 0ad Chaincode invoke successful. result: status:200
```

Lastly, you again query the value of `a` using the following command\.

```
docker exec cli peer chaincode query \
--tls --cafile /opt/home/managedblockchain-tls-chain.pem \
--channelID mychannel \
--name mycc -c '{"Args":["query", "a"]}'
```

The command should return the new value `90`\.

# Step 8: Invite Another AWS Account to be a Member and Create a Multi\-Member Channel<a name="get-started-joint-channel"></a>

Now that you have a Hyperledger Fabric network set up using Amazon Managed Blockchain, with an initial member in your AWS account and a VPC endpoint with a service name, you are ready to invite additional members\. You invite additional members by creating a proposal for an invitation that existing members vote on\. Since the blockchain network at this point consists of only one member, the first member always has the only vote on the invitation proposal for the second member\. In the steps that follow, the network creator has an initial member named `org1` and the invited member is named `org2`\. For proof of concept, you can create an invitation proposal for an additional member in the same AWS account that you used to create the network, or you can create an invitation proposal for a different AWS account\.

After the invitation proposal is approved, the invited account can create a member\. Invited members are free to reject the invitation or ignore it until the invitation proposal expires\. The invited account needs the network ID and VPC endpoint service name of the blockchain network to create a member\. For more information, see [Work with Invitations](accept-invitation.md)\. The invited account also needs to fulfill the prerequisites listed in [Prerequisites and Considerations](get-started-prerequisites.md)\.

## Step 8\.1: Create an Invitation Proposal<a name="get-started-joint-channel-invite-account"></a>

Create a proposal to invite an AWS account to create a member and join the network according to the following procedures\. You need the AWS account ID of the member you want to invite\. You can also invite your own account to create an additional member\. If you are using the CLI, you also need the Network ID and Member ID that you created in [Step 1: Create the Network and First Member](get-started-create-network.md)\.

### To create an invitation proposal using the AWS Management Console<a name="w79aab9c25b7b5b1"></a>

1. Open the Managed Blockchain console at [https://console\.aws\.amazon\.com/managedblockchain/](https://console.aws.amazon.com/managedblockchain/)\.

1. From the navigation pane, choose **Networks**, and then choose the network to which you want to invite an AWS account\.

1. Choose **Proposals** and then choose **Propose invitation**\.

1. For **Submit proposal as**, choose the member in your account that submits the proposal\.
   **Note**  
   The member who submits the proposal must also vote on it\. A Yes vote is not automatically assumed\.

1. Enter an optional **Description **\. The description appears to other members\. It's a good way to communicate key points or a reminder about the proposal before they vote\.

1. For each AWS account that you want to invite, enter the account number in the space provided\. Choose **Add** to enter additional accounts\.

1. Choose **Create**\.

### To create an invitation proposal using the AWS CLI<a name="w79aab9c25b7b5b3"></a>

- Type a command similar to the following\. Replace the value of `Principal` with the AWS account ID that you want to invite\. Replace the value of `--member-id` with the value for the member in your account that submits the proposal\.

  ```
  [ec2-user@ip-192-0-2-17 ~]$ aws managedblockchain create-proposal \
  --actions Invitations=[{Principal=123456789012}] \
  --network-id n-MWY63ZJZU5HGNCMBQER7IN6OIU \
  --member-id m-K46ICRRXJRCGRNNS4ES4XUUS5A
  ```

  The command returns the proposal ID, as shown in the following example:

  ```
  {
      "ProposalId": "p-ZR7KUD2YYNESLNG6RQ33X3FUFE"
  }
  ```

## Step 8\.2: Vote Yes on the Proposal<a name="get-started-joint-channel-cast-vote"></a>

After you create the invitation proposal, use the first member that you created to vote Yes and approve the proposal\. You must do this within the duration defined by the network voting policy\.

1. Open the Managed Blockchain console at [https://console\.aws\.amazon\.com/managedblockchain/](https://console.aws.amazon.com/managedblockchain/)\.

1. From the navigation pane, choose **Networks**, and then choose the **Network** for which the proposal was made\.

1. Choose **Proposals**\.

1. Under **Active**, choose the **Proposal ID** to vote on\.

1. Under **Vote on proposal**, select the member in your account to vote as\. If your account has multiple members, each member gets a vote\.

1. Choose **Yes** to vote to approve the proposal\. Voting yes is a requirement for the second member to be created in the next step\. Choosing **No** rejects the proposal and an invitation is not created\.

1. Choose to **Confirm** your vote\.

## Step 8\.3: Create the New Member<a name="get-started-joint-channel-invite-member"></a>

To accept an invitation to create a member and join a network, the steps are similar whether you are creating a member in a Managed Blockchain network in a different AWS account or your own AWS account\. You first create the member as shown in the following procedures\. If you use the AWS CLI, make sure that you have the relevant information, including the Network ID and the Invitation ID that the network sent to your account\. When you create a member, you specify the name that identifies your member on the network\. You also specify the admin user and password to authenticate to your member certificate authority \(CA\)\.

### To accept an invitation to create a member and join a network using the AWS Management Console<a name="w79aab9c25c11b5b1"></a>

1. Open the Managed Blockchain console at [https://console\.aws\.amazon\.com/managedblockchain/](https://console.aws.amazon.com/managedblockchain/)\.

1. From the navigation pane, choose **Invitations**\.

1. Select the invitation that you want to accept from the list, and then choose **Accept invitation**\. To view more information about the network you are invited to join, choose the network **Name** from the list

1. Under **Create member and join network**, configure your network member according to the following guidelines:

   1. Enter a **Member name** that will be visible to all members and an optional **Description**\.

   1. Under **Hyperledger Fabric certificate authority \(CA\) configuration** specify a username and password to be used as the administrator on the Hyperledger Fabric CA\. Remember the user name and password\. You need them later any time that you create users and resources that need to authenticate\.

1. Choose **Create member and join network**\.

### To accept an invitation to create a member and join a network using the AWS CLI<a name="w79aab9c25c11b5b3"></a>

- Use the `create-member` command similar to the example below\. Replace the value of `--network-id` with the Network ID that you are joining and `--invitation-id` with the Invitation ID sent to your account from the network\.

  ```
  aws managedblockchain create-member \
  --network-id n-MWY63ZJZU5HGNCMBQER7IN6OIU \
  --invitation-id i-XL9MDD6LVWWDNA9FF94Y4TFTE \
  --member-configuration 'Name=org2,Description=MyMemberDesc,\
  FrameworkConfiguration={Fabric={AdminUsername=MyAdminUsername,\
  AdminPassword=Password123}}'
  ```

  The command returns output similar to the following:

  ```
  {
  "MemberId": "m-J46DNSFRTVCCLONS9DT5TTLS2A"
  }
  ```

### Additional Steps to Configure a Member<a name="w79aab9c25c11b7"></a>

After you create the member, perform the following steps to configure the member\. As you perform the steps, replace values with those specific to your member configuration, including the Member ID returned by the previous command\. The Network ID and `OrderingServiceEndpoint` are the same for all members\.

- [Step 2: Create and Configure the Interface VPC Endpoint](get-started-create-endpoint.md)

  This step is only required if you are creating the second member in a different AWS account\.

- [Step 3: Create a Peer Node in Your Membership](get-started-create-peer-node.md)
- [Step 4: Create an Amazon EC2 Instance and Set Up the Hyperledger Fabric Client](get-started-create-client.md)

  If you are creating an additional member in the same AWS account, and you already have a Hyperledger Fabric client, you can skip most of these steps\. However, you should verify connectivity to the Hyperledger Fabric CA as described in [Step 4\.2: Set Up the Hyperledger Fabric CA Client](get-started-create-client.md#get-started-client-setup-CA-client), using the new CA endpoint for the new member\.

- [Step 5: Enroll an Administrative User](get-started-enroll-admin.md)

## Step 8\.4: Share Artifacts and Information with the Network Creator<a name="get-started-joint-channel-artifact-exchange"></a>

Before a shared channel can be created, the following artifacts and information need to be shared with `org1` by `org2`:

- **org1 needs the org2 administrative certificate**—This certificate is saved the `/home/ec2-user/admin-msp/admincerts` directory on org2's Hyperledger Fabric client after [Step 5: Enroll an Administrative User](get-started-enroll-admin.md)\. This is referenced in the following steps as `Org2AdminCerts`
- **org1 needs the org2 root CA**—This certificate is saved to org2's `/home/ec2-user/admin-msp/cacerts` directory on org2's Hyperledger Fabric client after the same step as previous\. This is referenced in the following steps as `Org2CACerts`
- **org1 needs the `Endpoint` of the peer node that will join the channel**—This `Endpoint` value is output by the `get-node` command after [Step 3: Create a Peer Node in Your Membership](get-started-create-peer-node.md) is complete\.

## Step 8\.5: The Channel Creator \(org1\) Creates Artifacts for org2's MSP<a name="get-started-joint-channel-create-org2msp"></a>

In the following example, the channel creator is org1\. The CA administrator for org1 copies the certificates from the step above to a location on the Hyperledger Fabric client computer\. The Membership Service Provider \(MSP\) uses the certificates to authenticate the member\.

On the channel creator's Hyperledger Fabric client, use the following commands to create directories to store the certificates, and then copy the certificates from the previous step to the new directories:

```
mkdir /home/ec2-user/org2-msp
 mkdir /home/ec2-user/org2-msp/admincerts
 mkdir /home/ec2-user/org2-msp/cacerts

cp Org2AdminCerts /home/ec2-user/org2-msp/admincerts
cp Org2CACerts /home/ec2-user/org2-msp/cacerts
```

Org1 needs org2's member ID\. You can get this by running the `list-members` command on org1's Hyperledger Fabric client as shown in the following example:

```
aws managedblockchain list-members \
--network-id n-MWY63ZJZU5HGNCMBQER7IN6OIU
```

The channel creator \(org1\) should verify that the required artifacts for channel creation are saved on the Hyperledger Fabric client as shown in the following list:

- Org1 MSP artifacts:
  - /home/ec2\-user/admin\-msp/signcerts/_certname_\.pem
  - /home/ec2\-user/admin\-msp/admincerts/_certname_\.pem
  - /home/ec2\-user/admin\-msp/cacerts/_certname_\.pem
  - /home/ec2\-user/admin\-msp/keystore/_keyname_\_sk
- Org2 MSP artifacts
  - /home/ec2\-user/org2\-msp/admincerts/_certname_\.pem
  - /home/ec2\-user/org2\-msp/cacerts/_certname_\.pem
- The TLS CA cert used for the Region:
  - /home/ec2\-user/managedblockchain\-tls\-chain\.pem
- Addresses of all peer nodes to join the channel for both org1 and org2\.
- The respective member IDs of org1 and org2\.
- A `configtx.yaml` file, which you create in the following step, saved to the `/home/ec2-user` directory on the channel creator's Hyperledger Fabric client\.
  **Note**  
  If you created this configtx file earlier, delete the old file, rename it, or replace it\.

## Step 8\.6: Create configtx for the Multi\-Member Channel<a name="get-started-joint-channel-channel-configtx"></a>

The `configtx.yaml` file contains details of the channel configuration\. For more information, see [Channel Configuration \(configtx\)](https://hyperledger-fabric.readthedocs.io/en/release-2.2/configtx.html) in the Hyperledger Fabric documentation\.

The channel creator creates this file on the Hyperledger File client\. If you compare this file to the file created in [Step 6\.1: Create configtx for Hyperledger Fabric Channel Creation](get-started-create-channel.md#get-started-create-channel-configtx), you see that this `configtx.yaml` specifies two members in the channel\.

Use a text editor to create a file with the following contents and save it as `configtx.yaml` on your Hyperledger File client\.

- Replace _Org1MemberID_ with the MemberID of the first member that you created when you [created the network](get-started-create-network.md)\. For example, _m\-K46ICRRXJRCGRNNS4ES4XUUS5A_\.
- For `&Org1`, the `MSPDir` is set to the same directory location, `/opt/home/admin-msp`, that you established using the `CORE_PEER_MSPCONFIGPATH` environment variable in the Docker container for the Hyperledger Fabric CLI in [step 4\.4](get-started-create-client.md#get-started-client-configure-peer-cli) above\.
- Replace _Org2MemberID_ with the MemberID of the second member that you created in [step 8\.3](#get-started-joint-channel-invite-member)\. For example, _m\-J46DNSFRTVCCLONS9DT5TTLS2A_\.
- For `&Org2`, the `MSPDir` is set to the same directory location, `/opt/home/org2-msp`, that you created and copied artifacts to in [step 8\.5](#get-started-joint-channel-create-org2msp)\.

**Important**  
This file is sensitive\. Artifacts from pasting can cause the file to fail with marshalling errors\. We recommend using `emacs` to edit it\. You can also use `VI`, but before using `VI`, enter `:set paste`, press `i` to enter insert mode, paste the contents, press escape, and then enter `:set nopaste` before saving\.

```
################################################################################
#
#   ORGANIZATIONS
#
#   This section defines the organizational identities that can be referenced
#   in the configuration profiles.
#
################################################################################
Organizations:
    # Org1 defines an MSP using the sampleconfig. It should never be used
    # in production but may be used as a template for other definitions.
    - &Org1
        # Name is the key by which this org will be referenced in channel
        # configuration transactions.
        # Name can include alphanumeric characters as well as dots and dashes.
        Name: Org1MemberID
        # ID is the key by which this org's MSP definition will be referenced.
        # ID can include alphanumeric characters as well as dots and dashes.
        ID: Org1MemberID
        # SkipAsForeign can be set to true for org definitions which are to be
        # inherited from the orderer system channel during channel creation.  This
        # is especially useful when an admin of a single org without access to the
        # MSP directories of the other orgs wishes to create a channel.  Note
        # this property must always be set to false for orgs included in block
        # creation.
        SkipAsForeign: false
        Policies: &Org1Policies
            Readers:
                Type: Signature
                Rule: "OR('Org1.member', 'Org2.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('Org1.admin', 'Org1.peer', 'Org1.client')"
            Writers:
                Type: Signature
                Rule: "OR('Org1.member', 'Org2.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('Org1.admin', 'Org1.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org1.admin')"
        # MSPDir is the filesystem path which contains the MSP configuration.
        MSPDir: /opt/home/admin-msp
        # AnchorPeers defines the location of peers which can be used for
        # cross-org gossip communication. Note, this value is only encoded in
        # the genesis block in the Application section context.
        AnchorPeers:
            - Host: 127.0.0.1
              Port: 7051
    - &Org2
        Name: Org2MemberID
        ID: Org2MemberID
        SkipAsForeign: false
        Policies: &Org2Policies
            Readers:
                Type: Signature
                Rule: "OR('Org2.member', 'Org1.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('Org1.admin', 'Org1.peer', 'Org1.client')"
            Writers:
                Type: Signature
                Rule: "OR('Org2.member', 'Org1.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('Org1.admin', 'Org1.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org2.admin')"
        # MSPDir is the filesystem path which contains the MSP configuration.
        MSPDir: /opt/home/org2-msp
        # AnchorPeers defines the location of peers which can be used for
        # cross-org gossip communication. Note, this value is only encoded in
        # the genesis block in the Application section context.
        AnchorPeers:
            - Host: 127.0.0.1
              Port: 7052
################################################################################
#
#   CAPABILITIES
#
#   This section defines the capabilities of fabric network. This is a new
#   concept as of v1.1.0 and should not be utilized in mixed networks with
#   v1.0.x peers and orderers.  Capabilities define features which must be
#   present in a fabric binary for that binary to safely participate in the
#   fabric network.  For instance, if a new MSP type is added, newer binaries
#   might recognize and validate the signatures from this type, while older
#   binaries without this support would be unable to validate those
#   transactions.  This could lead to different versions of the fabric binaries
#   having different world states.  Instead, defining a capability for a channel
#   informs those binaries without this capability that they must cease
#   processing transactions until they have been upgraded.  For v1.0.x if any
#   capabilities are defined (including a map with all capabilities turned off)
#   then the v1.0.x peer will deliberately crash.
#
################################################################################
Capabilities:
    # Channel capabilities apply to both the orderers and the peers and must be
    # supported by both.
    # Set the value of the capability to true to require it.
    # Note that setting a later Channel version capability to true will also
    # implicitly set prior Channel version capabilities to true. There is no need
    # to set each version capability to true (prior version capabilities remain
    # in this sample only to provide the list of valid values).
    Channel: &ChannelCapabilities
        # V2.0 for Channel is a catchall flag for behavior which has been
        # determined to be desired for all orderers and peers running at the v2.0.0
        # level, but which would be incompatible with orderers and peers from
        # prior releases.
        # Prior to enabling V2.0 channel capabilities, ensure that all
        # orderers and peers on a channel are at v2.0.0 or later.
        V2_0: true
    # Orderer capabilities apply only to the orderers, and may be safely
    # used with prior release peers.
    # Set the value of the capability to true to require it.
    Orderer: &OrdererCapabilities
        # V1.1 for Orderer is a catchall flag for behavior which has been
        # determined to be desired for all orderers running at the v1.1.x
        # level, but which would be incompatible with orderers from prior releases.
        # Prior to enabling V2.0 orderer capabilities, ensure that all
        # orderers on a channel are at v2.0.0 or later.
        V2_0: true
    # Application capabilities apply only to the peer network, and may be safely
    # used with prior release orderers.
    # Set the value of the capability to true to require it.
    # Note that setting a later Application version capability to true will also
    # implicitly set prior Application version capabilities to true. There is no need
    # to set each version capability to true (prior version capabilities remain
    # in this sample only to provide the list of valid values).
    Application: &ApplicationCapabilities
        # V2.0 for Application enables the new non-backwards compatible
        # features and fixes of fabric v2.0.
        # Prior to enabling V2.0 orderer capabilities, ensure that all
        # orderers on a channel are at v2.0.0 or later.
        V2_0: true
################################################################################
#
#   CHANNEL
#
#   This section defines the values to encode into a config transaction or
#   genesis block for channel related parameters.
#
################################################################################
Channel: &ChannelDefaults
    # Policies defines the set of policies at this level of the config tree
    # For Channel policies, their canonical path is
    #   /Channel/<PolicyName>
    Policies:
        # Who may invoke the 'Deliver' API
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        # Who may invoke the 'Broadcast' API
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        # By default, who may modify elements at this config level
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
    # Capabilities describes the channel level capabilities, see the
    # dedicated Capabilities section elsewhere in this file for a full
    # description
    Capabilities:
        <<: *ChannelCapabilities
################################################################################
#
#   APPLICATION
#
#   This section defines the values to encode into a config transaction or
#   genesis block for application-related parameters.
#
################################################################################
Application: &ApplicationDefaults
    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:
    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies: &ApplicationDefaultPolicies
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Endorsement:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"

    Capabilities:
        <<: *ApplicationCapabilities
################################################################################
#
#   PROFILES
#
#   Different configuration profiles may be encoded here to be specified as
#   parameters to the configtxgen tool. The profiles which specify consortiums
#   are to be used for generating the orderer genesis block. With the correct
#   consortium members defined in the orderer genesis block, channel creation
#   requests may be generated with only the org member names and a consortium
#   name.
#
################################################################################
Profiles:
    TwoOrgChannel:
        <<: *ChannelDefaults
        Consortium: AWSSystemConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *Org1
                - *Org2
```

Run the following command to generate the configtx peer block:

```
docker exec cli configtxgen \
-outputCreateChannelTx /opt/home/ourchannel.pb \
-profile TwoOrgChannel -channelID ourchannel \
--configPath /opt/home/
```

## Step 8\.7: Create the Channel<a name="get-started-joint-channel-create-channel"></a>

The channel creator \(org1\) uses the following command on their Hyperledger Fabric client to submit the channel to the orderer, which creates the channel `ourchannel`\. The command example assumes that Docker environment variables have been configured as described in [Step 4\.4: Configure and Run Docker Compose to Start the Hyperledger Fabric CLI](get-started-create-client.md#get-started-client-configure-peer-cli) and that the `$ORDERER` environment variable has been set on the client\.

```
docker exec cli peer channel create -c ourchannel \
-f /opt/home/ourchannel.pb -o $ORDERER \
--cafile /opt/home/managedblockchain-tls-chain.pem --tls
```

## Step 8\.8: Get Channel Genesis Block<a name="get-started-joint-channel-get-genesis-block"></a>

Both org1 and org2 need to run the following command on their respective Hyperledger Fabric clients to join their peer nodes to the channel\. For more information about the `peer channel` command, see [peer channel](https://hyperledger-fabric.readthedocs.io/en/release-2.2/commands/peerchannel.html) in Hyperledger Fabric documentation\.

```
docker exec cli peer channel fetch oldest /opt/home/ourchannel.block \
-c ourchannel -o $ORDERER \
--cafile /opt/home/managedblockchain-tls-chain.pem --tls
```

## Step 8\.9: Join Peer Nodes to the Channel<a name="get-started-joint-channel-invite-join-peer"></a>

Both org1 and org2 need to run the following command on their respective Hyperledger Fabric clients to join their peer nodes to the channel\. For more information about the `peer channel` command, see [peer channel](https://hyperledger-fabric.readthedocs.io/en/release-2.2/commands/peerchannel.html) in Hyperledger Fabric documentation\.

```
docker exec cli peer channel join -b /opt/home/ourchannel.block \
-o $ORDERER --cafile /opt/home/managedblockchain-tls-chain.pem --tls
```

Optionally, after you join a peer to a channel, you can set up the peer node as an _anchor peer_\. Anchor peers support the gossip protocol, which is required for some features of Hyperledger Fabric, such as private data collections and service discovery\. For more information, see [Add an Anchor Peer to a Channel](hyperledger-anchor-peers.md)\.

## Step 8\.10: Install Chaincode<a name="get-started-joint-channel-invite-install-chaincode"></a>

Both org1 and org2 run the following commands on their respective Hyperledger Fabric clients to install example chaincode on their respective peer nodes:

1. Install the example chaincode package on the peer node\.

   ```
   docker exec cli peer lifecycle chaincode install abstore.tar.gz
   ```

1. Verify that the chaincode package is installed on the peer node\.

   ```
   docker exec cli peer lifecycle chaincode queryinstalled
   ```

   The command returns the following if the package is installed successfully\.

   ```
   Installed chaincodes on peer:
   Package ID: MyPackageID, Label: abstore_1
   ```

1. Approve the chaincode definition for the organization\. Replace _MyPackageID_ with the Package ID value returned in the previous step\.

   ```
   export CC_PACKAGE_ID=MyPackageID
   docker exec cli peer lifecycle chaincode approveformyorg \
   --orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem \
   --channelID ourchannel --name myjointcc --version v0 --sequence 1 --package-id $CC_PACKAGE_ID
   ```

1. Check the commit readiness of the chaincode definition\.

   ```
   docker exec cli peer lifecycle chaincode checkcommitreadiness \
   --orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem \
   --channelID ourchannel --name myjointcc --version v0 --sequence 1
   ```

   The command returns `true` if the chaincode is ready to be committed\.

1. Commit the chaincode definition on the channel\.

   ```
   docker exec cli peer lifecycle chaincode commit \
   --orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem \
   --channelID ourchannel --name myjointcc --version v0 --sequence 1
   ```

## Step 8\.11: Instantiate Chaincode<a name="get-started-joint-channel-invite-instantiate"></a>

The channel creator \(org1\) runs the following command to instantiate the chaincode with an endorsement policy that requires both org1 and org2 to endorse all transactions\. Replace _Member1ID_ with the member ID of org1 and _Member2ID_ with the member ID of org2\. You can use the `list-members` command to get them\.

```
docker exec cli peer chaincode instantiate -o $ORDERER \
-C ourchannel -n myjointcc -v v0 \
-c '{"Args":["init","a","100","b","200"]}' \
--cafile /opt/home/managedblockchain-tls-chain.pem --tls \
-P "AND ('Member1ID.member','Member2ID.member')"
```

You may need to wait a brief moment for the instantiation from the previous step to complete before you run the following command to query a value:

```
docker exec cli peer chaincode query -C ourchannel \
-n myjointcc -c '{"Args":["query","a"]}'
```

The command should return the value of `a`, which you instantiated to a value of `100`\.

## Step 8\.12: Invoke Chaincode<a name="get-started-joint-channel-invite-invoke"></a>

With the channel created and configured with both members, and the chaincode instantiated with values and an endorsement policy, channel members can invoke chaincode\. This example command is similar to the example in [Step 7\.11: Invoke the Chaincode](get-started-chaincode.md#get-started-chaincode-invoke)\. However, the command uses the `--peerAddresses` option to specify the endpoints of peer nodes that belong to members in the endorsement policy\. The example specifies _Org2PeerNodeEndpoint_ in addition to _Org1PeerEndpoint_\.

```
docker exec cli peer chaincode invoke \
-C ourchannel -n myjointcc -c '{"Args":["invoke","a","b","10"]}' \
--peerAddresses Org1PeerEndpoint \
--tlsRootCertFiles /opt/home/managedblockchain-tls-chain.pem \
--peerAddresses Org2PeerNodeEndpoint \
--tlsRootCertFiles /opt/home/managedblockchain-tls-chain.pem \
-o $ORDERER --cafile /opt/home/managedblockchain-tls-chain.pem --tls
```

When we query again using the following command:

```
docker exec cli peer chaincode query -C ourchannel \
-n myjointcc -c '{"Args":["query","a"]}'
```

The command should return the value of `a` as the new value `90`\.
