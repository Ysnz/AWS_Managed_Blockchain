#!/bin/bash


echo Create the Fabric Peer node
token=$(uuidgen)
echo Creating Fabric peer for network $networkname
result=$(aws managedblockchain create-node --endpoint-url $ENDPOINT --region $REGION \
        --client-request-token $token \
        --node-configuration '{"InstanceType":"bc.t3.small","AvailabilityZone":"us-east-1a"}' \
        --network-id $NETWORKID \
        --member-id $MEMBERID)
  
nodeID=$(jq -r '.NodeId' <<< $result)
echo Peer Node ID: $nodeID

echo Waiting for peer node to become HEALTHY
while (true); do
    STATUS=$(aws managedblockchain get-node --endpoint-url $ENDPOINT --region $REGION --network-id $NETWORKID --member-id $MEMBERID --node-id $nodeID --query 'Node.Status' --output text)
    if  [[ "$STATUS" == "AVAILABLE" ]]; then
        echo Status of Fabric node $nodeID is $STATUS
        break
    else
        echo Status of Fabric node $nodeID is $STATUS. Sleeping for 30s
        sleep 30s
    fi
done

AvailabilityZone=$(aws managedblockchain get-node --endpoint-url $ENDPOINT --region $REGION --network-id $NETWORKID --member-id $MEMBERID --node-id $nodeID --query 'Node.AvailabilityZone' --output text)
endpoint=$(aws managedblockchain get-node --endpoint-url $ENDPOINT --region $REGION --network-id $NETWORKID --member-id $MEMBERID --node-id $nodeID --query 'Node.Endpoint' --output text)
echo Useful information
echo
echo Node ID: $nodeID
echo Peer Service Endpoint: $endpoint

# Export these values
export PEERNODEID=$nodeID
export PEERSERVICEENDPOINT=$endpoint