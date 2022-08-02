#!/bin/bash


echo Creating VPC - TODO. Create the VPC, subnets, security group, EC2 client node, VPC endpoint
echo Create a keypair

echo Searching for existing keypair named $NETWORKNAME-keypair
keyname=$(aws ec2 describe-key-pairs --key-names $NETWORKNAME-keypair --region $REGION --query 'KeyPairs[0].KeyName' --output text)
if  [[ "$keyname" == "$NETWORKNAME-keypair" ]]; then
    echo Keypair $NETWORKNAME-keypair already exists. Please choose another keypair name by editing this script
    exit 1
fi
 
echo Creating a keypair named $NETWORKNAME-keypair. The .pem file will be in your $HOME directory
aws ec2 create-key-pair --key-name $NETWORKNAME-keypair --region $REGION --query 'KeyMaterial' --output text > ~/$NETWORKNAME-keypair.pem
if [ $? -gt 0 ]; then
    echo Keypair $NETWORKNAME-keypair could not be created
    exit $?
fi

chmod 400 ~/$NETWORKNAME-keypair.pem
sleep 10

echo Create the VPC, the Fabric client node and the VPC endpoints
aws cloudformation deploy --stack-name $NETWORKNAME-fabric-client-node --template-file fabric-client-node.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides KeyName=$NETWORKNAME-keypair BlockchainVpcEndpointServiceName=$VPCENDPOINTSERVICENAME \
--region $REGION
