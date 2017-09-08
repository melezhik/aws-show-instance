id=$(config id)


aws ec2 describe-instances --instance-id $id \
--query 'Reservations[*].Instances[*].{
ID:InstanceId,St:State,Time:LaunchTime,IP:PrivateIpAddress,Tags:Tags,Devices:BlockDeviceMappings }' | perl -n -MJSON -e '
$json.=$_;
  END {
    my $ii = decode_json($json);
    for $i (map {$_->[0]} @$ii){
      write();
    }
  }


format STDOUT  =
ID                        IP                  Time                  State
--------------------------------------------------------------------------------------
@<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<< @>>>>>>>>>>>>>>>>>>   @<<<<<<<<<<<<<<<<< ~
$i->{ID},  $i->{IP}||'Null', $i->{Time}, join "/", ($i->{St}{Code}, $i->{St}{Name})
--------------------------------------------------------------------------------------
Tags:
@*
join "\n", map { ($_->{Key})." : ".($_->{Value}) } @{$i->{Tags}}
--------------------------------------------------------------------------------------
EBS:
@*
join "\n", map { ($_->{DeviceName})." => ".( $_->{Ebs}->{VolumeId} ) } grep {$_->{Ebs}} @{$i->{Devices}}
--------------------------------------------------------------------------------------
.

'
