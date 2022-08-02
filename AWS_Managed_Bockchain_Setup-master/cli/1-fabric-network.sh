#!/bin/bash

echo Pre-requisities
echo installing jq
sudo yum -y install jq

echo Updating AWS CLI to the latest version
sudo pip install awscli --upgrade

token=$(uuidgen)
echo Creating Fabric network $NETWORKNAME
echo Executing command: aws managedblockchain create-network --region $REGION \
    --client-request-token $token \
    --name "${NETWORKNAME}" \
    --description "NGO Fabric network"
    --framework "HYPERLEDGER_FABRIC"
    --framework-version "${NETWORKVERSION}" \
    --voting-policy "ApprovalThresholdPolicy={ThresholdPercentage=20,ProposalDurationInHours=24,ThresholdComparator=GREATER_THAN}" \
    --framework-configuration 'Fabric={Edition=STARTER}' \
    --member-configuration "Name=\"${MEMBERNAME}\",Description=\"NGO Fabric member\",FrameworkConfiguration={Fabric={AdminUsername=${ADMINUSER},AdminPassword=${ADMINPWD}}}"

result=$(aws managedblockchain create-network --region $REGION \
    --client-request-token $token \
    --name ${NETWORKNAME} \
    --description "NGO Fabric network"
    --framework HYPERLEDGER_FABRIC
    --framework-version ${NETWORKVERSION} \
    --voting-policy "ApprovalThresholdPolicy={ThresholdPercentage=20,ProposalDurationInHours=24,ThresholdComparator=GREATER_THAN}" \
    --framework-configuration 'Fabric={Edition=STARTER}' \
    --member-configuration "Name=\"${MEMBERNAME}\",Description=\"NGO Fabric member\",FrameworkConfiguration={Fabric={AdminUsername=${ADMINUSER},AdminPassword=${ADMINPWD}}}")

echo Result is: $result
networkID=$(jq -r '.NetworkId' <<< $result)
memberID=$(jq -r '.MemberId'<<< $result)
echo Network ID: $networkID
echo Member ID: $memberID

echo Waiting for network to become ACTIVE
while (true); do
    STATUS=$(aws managedblockchain get-network --endpoint-url $ENDPOINT --region $REGION --network-id $networkID --query 'Network.Status' --output text)
    if  [[ "$STATUS" == "AVAILABLE" ]]; then
        echo Status of Fabric network $NETWORKNAME with ID $networkID is $STATUS
        break
    else
        echo Status of Fabric network $NETWORKNAME with ID $networkID is $STATUS. Sleeping for 30s
        sleep 30s
    fi
done

VpcEndpointServiceName=$(aws managedblockchain get-network --endpoint-url $ENDPOINT --region $REGION --network-id $networkID --query 'Network.VpcEndpointServiceName' --output text)
OrderingServiceEndpoint=$(aws managedblockchain get-network --endpoint-url $ENDPOINT --region $REGION --network-id $networkID --query 'Network.FrameworkAttributes.Fabric.OrderingServiceEndpoint' --output text)
CaEndpoint=$(aws managedblockchain get-member --endpoint-url $ENDPOINT --region $REGION --network-id $networkID --member-id $memberID --query 'NetworkMember.FrameworkAttributes.Fabric.CaEndpoint' --output text)
echo Useful information
echo
echo Network ID: $networkID
echo Member ID: $memberID
echo Ordering Service Endpoint: $OrderingServiceEndpoint
echo Vpc Endpoint Service Name: $VpcEndpointServiceName
echo CA Service Endpoint: $CaEndpoint

# Export these values
export NETWORKID=$networkID
export MEMBERID=$memberID
export ORDERINGSERVICEENDPOINT=$OrderingServiceEndpoint
export VPCENDPOINTSERVICENAME=$VpcEndpointServiceName
export CASERVICEENDPOINT=$CaEndpoint
