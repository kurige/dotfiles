
# TODO: Write brief description on how to aquire the following two values:
local _EC2_PREALLOCATED_PUBLIC_IP=xyz  # Pre-configured elastic IP we want to point to our newly created instance
local _EC2_SECURITY_GROUP_ID=xyz          # The 'anything-goes' group

gamebox-up () {
  # Get the current lowest price for the GPU machine we want (we'll be bidding a cent above)
  echo -n "Getting lowest g2.2xlarge bid... "
  PRICE=$( aws ec2 describe-spot-price-history --instance-types g2.2xlarge --product-descriptions "Windows" --start-time `date +%s` | jq --raw-output '.SpotPriceHistory[].SpotPrice' | sort | head -1 )
  echo $PRICE

  echo -n "Looking for the ec2-gaming AMI... "
  AMI_SEARCH=$( aws ec2 describe-images --owner self --filters Name=name,Values=ec2-gaming )
  if [ $( echo "$AMI_SEARCH" | jq '.Images | length' ) -eq "0" ]; then
    echo "not found. You must use gaming-down.sh after your machine is in a good state."
    exit 1
  fi
  AMI_ID=$( echo $AMI_SEARCH | jq --raw-output '.Images[0].ImageId' )
  echo $AMI_ID

  echo -n "Creating spot instance request... "
  SPOT_INSTANCE_ID=$( aws ec2 request-spot-instances --spot-price $( bc <<< "$PRICE + 0.01" ) --launch-specification "
    {
      \"SecurityGroupIds\": [\"$_EC2_SECURITY_GROUP_ID\"],
      \"ImageId\": \"$AMI_ID\",
      \"InstanceType\": \"g2.2xlarge\"
    }" | jq --raw-output '.SpotInstanceRequests[0].SpotInstanceRequestId' )
  echo $SPOT_INSTANCE_ID

  echo -n "Waiting for instance to be launched... "
  aws ec2 wait spot-instance-request-fulfilled --spot-instance-request-ids "$SPOT_INSTANCE_ID"

  INSTANCE_ID=$( aws ec2 describe-spot-instance-requests --spot-instance-request-ids "$SPOT_INSTANCE_ID" | jq --raw-output '.SpotInstanceRequests[0].InstanceId' )
  echo "$INSTANCE_ID"

  echo "Removing the spot instance request..."
  aws ec2 cancel-spot-instance-requests --spot-instance-request-ids "$SPOT_INSTANCE_ID" > /dev/null

  echo -n "Getting ip address... "
  IP=$( aws ec2 describe-instances --instance-ids "$INSTANCE_ID" | jq --raw-output '.Reservations[0].Instances[0].PublicIpAddress' )
  echo "$IP"

  echo -n "(Re)associating EIP with new instance..."
  aws ec2 associate-address --public-ip "$_EC2_PREALLOCATED_PUBLIC_IP" --instance-id "$INSTANCE_ID"
  echo "$_EC2_PREALLOCATED_PUBLIC_IP"

  echo "Waiting for server to become available..."
  while ! ping -c1 $_EC2_PREALLOCATED_PUBLIC_IP &>/dev/null; do sleep 5; done
}

# TODO: Check for a `--fast` flag to skip AMI creation (in case there's nothing to save)
gamebox-down () {
  # Verify that the gaming stane actually exists (and that there's only one)
  echo -n "Finding your gaming instance... "
  INSTANCES=$( aws ec2 describe-instances --filters Name=instance-state-code,Values=16 Name=instance-type,Values=g2.2xlarge )
  if [ $( echo "$INSTANCES" | jq '.Reservations | length' ) -ne "1" ]; then
    echo "didnt find exactly one instance!"
    exit
  fi
  INSTANCE_ID=$( echo "$INSTANCES" | jq --raw-output '.Reservations[0].Instances[0].InstanceId' )
  echo "$INSTANCE_ID"

  # Only allow one ec2-gaming AMI to exist
  echo -n "Checking if an AMI 'ec2-gaming' already exists... "
  AMIS=$( aws ec2 describe-images --owner self --filters Name=name,Values=ec2-gaming )
  if [ $( echo "$AMIS" | jq '.Images | length' ) -ne "0" ]; then
    AMI_ID=$( echo "$AMIS" | jq --raw-output '.Images[0].ImageId' )
    echo "yes, $AMI_ID"
    echo "Deregistering that AMI..."
    aws ec2 deregister-image --image-id $AMI_ID
    echo "Deleting AMI's backing Snapshot..."
    aws ec2 delete-snapshot --snapshot-id $( echo "$AMIS" | jq --raw-output '.Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' )
  else
    echo "no"
  fi

  # Create an AMI from the existing instance (so we can restore it next time)
  echo -n "Starting AMI creation... "
  AMI_ID=$( aws ec2 create-image --instance-id "$INSTANCE_ID" --name "ec2-gaming" | jq --raw-output '.ImageId' )
  echo "$AMI_ID"

  echo "Waiting for AMI to be created before terminating instance..."
  if ! aws ec2 wait image-available --image-id "$AMI_ID"; then 
    echo "AMI never finished being created! Instance not terminated!";
    exit
  fi

  # Now that an image has been created terminate the instance
  echo "Terminating gaming instance..."
  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null
}

gamebox-status () {
  # TODO
}

# Syntactic sugar to avoid the `-` when calling gamebox commands. With this
# function, you can write `gamebox-up` as `gamebox up`.
gamebox () {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "gamebox: Please give a command to run." >&2
    return 1
  fi
  shift

  if functions "gamebox-$cmd" > /dev/null; then
    "gamebox-$cmd" "$@"
    echo "All done!"
  else
    echo "gamebox: Unknown command: $cmd" >&2
  fi
}