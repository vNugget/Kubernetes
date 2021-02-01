# Backup and Restore Kubernetes Applications Using velero

## Create an S3 bucket and set permissions

```json
{
  "Id": "Policy1612005814976",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1612005810869",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:s3:::<BUCKET>","arn:aws:s3:::<BUCKET>/*" ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::<xxxxxxxxx>:user/<xxxx>"
        ]
      }
    }
  ]
}
```

## Download and install velero

```bash
mkdir velero;cd velero
wget https://github.com/vmware-tanzu/velero/releases/download/v1.5.3/velero-v1.5.3-linux-amd64.tar.gz
tar xzvf velero-v1.5.3-linux-amd64.tar.gz;cd velero-v1.5.3-linux-amd64
```

## Setup velero credentials and install

```bash
vi credentials-velero

[default]
aws_access_key_id = <aws_access_key_id>
aws_secret_access_key = <aws_secret_access_key>


### install velero

./velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.1.0 \
    --bucket <BUCKET> \
    --backup-location-config region=ca-central-1 \
    --use-volume-snapshots=false \
    --secret-file ./credentials-velero \
    --use-restic
```
## Create app from yaml

`kubectl apply -f ../../my-app.yaml`

## Copy index file and test
`scp -i ../../kubemaster.privkey ../../index.html  vagrant@192.168.1.52:/k8s/webapp`

## backup the deployed app
```bash
kubectl annotate pod web-0 backup.velero.io/backup-volumes=www
./velero backup create webapp --selector app=nginx
./velero backup describe webapp
./velero backup get
```

## Delete the app
```bash
kubectl delete -f ../../my-app.yaml
ssh -i ../../kubemaster.privkey  vagrant@192.168.1.52 rm /k8s/webapp/index.html
```
## Restore the app
```bash
./velero restore create --from-backup webapp
kubectl get svc
```
