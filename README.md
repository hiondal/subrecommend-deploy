# Subrecommend deploy with k8s

## 준비
- 작업할 VM 로그인
  ```
  ssh user00
  ```
  ssh 로그인 설정은 [여기](https://github.com/cna-bootcamp/cna-handson/blob/main/prepare/%EB%A1%9C%EC%BB%AC%EA%B0%9C%EB%B0%9C%ED%99%98%EA%B2%BD%EA%B5%AC%EC%84%B1.md#ssh-login-%EC%84%A4%EC%A0%95)를 참고 하세요. 


- 작업 디렉토리 작성 후 이동
  ```
  mkdir -p ~/work && cd ~/work
  ```
- 배포 필요 파일 다운로드
  ```
  git clone https://github.com/hiondal/subrecommend-deploy.git
  ```
  ```
  cd subrecommend-deploy
  ```

## 소스 다운로드 
만약 subride-front만 수정해도 된다면, 즉 SCG주소만 변경하는 경우라면,  
subride-front.git만 clone하십시오.   
```
git clone https://github.com/hiondal/subride-front.git
```

다른 서비스도 새로 image를 만들어야 한다면 모두 clone 하십시오.  
```
git clone https://github.com/hiondal/sc.git
```
```
git clone https://github.com/hiondal/subrecommend.git
```


## Build jar
SC, Subrecommend의 jar를 새로 생성합니다.  
subride-front의 image만 만드는 경우는 불필요 합니다.  
```
docker-compose -f buildjar.yml up
```

## Build image
.env 파일 내용 수정  
```
#Image Organization: Organization 수정 필요 
IMAGE_ORG=hiondal
IMAGE_VERSION=2.0.0

#SCG:맨 앞의 user명 수정. 
SCG_FQDN=http://user00.scg.msa.edutdc.com
```

```
docker-compose build
```

만약 subride-front만 수정해도 된다면, 즉 SCG주소만 변경하는 경우라면,  
아래와 같이 build-front.yml파일을 이용하세요.  
```
docker-compose -f build-front.yml build
```

## Push image
```
docker-compose push
```

만약 subride-front만 push 하는 경우는,  
아래와 같이 build-front.yml파일을 이용하세요.  
```
docker-compose -f build-front.yml push
```

## 배포 준비  
배포할 namespace로 이동합니다. 아직 namespace를 생성 안했으면 생성 후 이동합니다.  
```
kubectl create ns {namespace}
kubens {namespace}
```

## 배포: MySQL
MySQL은 helm chart로 배포 합니다.  

helm chart registry 추가  
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

mysql-helm-values.yaml파일 내용을 상황에 맞게 수정합니다.  
수정이 필요한 지 체크할 항목은 아래와 같습니다. 
- storageClass: Dynamic provisioning이 설정된 Storage class명
- auth.rootPassword, root.password: Database 암호

helm chart로 배포 합니다.  
```
helm upgrade mysql -i -f mysql-helm-values.yaml bitnami/mysql
```

## 배포 yaml 수정 

deploy디렉토리에 있는 배포 yaml을 수정합니다.   
update-yaml.sh을 실행하고 namespace, image organization, image tag를 지정합니다.  
```
./update-yaml.sh
```
이 shell은 아래 수행을 합니다. 
- 각 yaml파일에서 namespace와 ingress host를 변경합니다. 
- 각 파일에서 image full path를 변경 합니다.  

config.yaml의 ConfigMap과 Secret 정의에서 Git 관련 설정값을 변경 합니다.  
GIT_URL, GIT_USERNAME, GIT_TOKEN
```
vi deploy/config.yaml
```

## 배포 
image pulling을 위한 Secret객체 생성  
```
kubectl create secret docker-registry dockerhub --docker-server=docker.io --docker-username={userid} --docker-password={password}
```

yaml파일이 있는 deploy디렉토리를 지정하여 한꺼번에 배포합니다.  
```
kubectl apply -f deploy
```

모든 Pod가 실행될때까지 기다립니다.  
```
kubectl get po -w
```

subride-front 주소를 확인합니다.  
```
kubectl get ing
```

브라우저에서 front 주소로 접근 하여 테스트 합니다.  
ID/PW는 아무거나 상관없습니다.  


---

## 객체 삭제 하기 
MySQL 관련 객체 삭제  
```
helm delete mysql
kubectl delete pvc --all
```

구독추천 서비스 관련 객체 삭제  
```
kubectl delete -f deploy 
```


