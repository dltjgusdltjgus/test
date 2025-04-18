eksctl version
# 0.207.0

aws --version
# aws-cli/2.23.11 Python/3.9.21 Linux/6.1.131-143.221.amzn2023.x86_64 source/x86_64.amzn.2023

aws configure 
# AWS Access Key ID [None]: 
# AWS Secret Access Key [None]: 
# Default region name [None]:  
# Default output format [None]:  

TOKEN=$(curl -X PUT \
"http://169.254.169.254/latest/api/token" -H \
"X-aws-ec2-metadata-token-ttl-seconds: 21600")

##메타데이터에서 자동으로 가져오기
export AWS_REGION=$(curl -H \
"X-aws-ec2-metadata-token: $TOKEN" -s \
http://169.254.169.254/latest/dynamic/instance-identity/document \
| jq -r '.region')
##수동으로 입력
export AWS_REGION=ap-northeast-2
echo $AWS_REGION
# ap-northeast-2
echo "export AWS_REGION=${AWS_REGION}" | \
tee -a ~/.bash_profile
# export AWS_REGION=ap-northeast-2
aws configure set default.region ${AWS_REGION}

##메타데이터에서 자동으로 가져오기
export ACCOUNT_ID=$(curl -H \
"X-aws-ec2-metadata-token: $TOKEN" -s \
http://169.254.169.254/latest/dynamic/instance-identity/document | \
jq -r '.accountId')
##수동으로 입력
export ACCOUNT_ID=390844776196
echo $ACCOUNT_ID
# 390844776196
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | \
tee -a ~/.bash_profile
# export ACCOUNT_ID=390844776196
aws ecr create-repository \
--repository-name demo-flask-backend \
--image-scanning-configuration scanOnPush=true \
--region ${AWS_REGION}
aws ecr get-login-password --region ${AWS_REGION} | \
 docker login --username AWS --password-stdin \
 $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

cd amazon-eks-flask/
docker build -t \
390844776196.dkr.ecr.ap-northeast-2.amazonaws.com/demo-flask-backend:latest .

docker push \
$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/demo-flask-backend:latest

eksctl create iamidentitymapping \
  --cluster eks-demo \
  --arn ${rolearn} \
  --group system:masters \
  --username admin






























