# 구독관리 서비스 배포 가이드
이 가이드는 구독관리 서비스의 Front, Backend, Spring Cloud 서버를 배포하는 방법을 안내 합니다.   

## 배포 가이드 클론
Docker, Docker Compose, Kubectl이 설치된 작업 머신에 배포 가이드를 클론합니다.  
이 작업 머신은 k8s cluster에 애플리케이션을 배포할 수 있도록 환경이 구성되어 있어야 합니다.  

```
mkdir -p ~/install/subride && cd ~/install/subride
git clone https://github.com/cna-bootcamp/subride-deploy.git
```

## 내용 수정
### 환경변수 .env 파일
- FRONT_HOST: Backend application에 API를 요청하는 Front 주소. CORS설정을 위해 필요.   
- MYSQL, RabbitMQ 관련 환경변수: 이 값을 변경하면 k8s배포 시 mysql.yaml, rabbitmq.yaml도 수정해야 함      
> Tip
  사실 이 변수는 로컬에서 container로 실행할 때 필요한 값이라, k8s배포만 한다면 수정 안해도 됨.  

### Jar생성 정의 파일 build.yml
Docker Compose로 Spring Cloud와 Subride backend application의 jar파일을 생성하는   
정의 파일입니다.   
이 파일에서 수정할 내용은 없습니다.   

### Image 빌드 및 Container 배포 정의 파일 docker-compose.yml   
이 파일에는 Container image를 빌드하고, 현재 머신에 container로 application을 실행하는   
방법이 정의되어 있습니다.   
우리는 k8s에서 배포할 것이므로 image 빌드 부분만 사용합니다.   

- 공통 수정 내용: image 경로를 본인의 것으로 변경  
- config: environment하위의 'GIT'으로 시작하는 Config 저장소 관련 변수 수정

### 배포 yaml 파일
- mysql.yaml: Helm chart로 배포하기 위한 custom values
  - storageClass: Dynamic provisioning이 설정된 Storage class명으로 지정  
  - auth 항목 밑의 설정. 이 값은 .env와 일치해야 함. replicationPassword는 적절히 지정. 
- rabbitmq.yaml: 
  - 환경변수 RABBITMQ_DEFAULT_USER, RABBITMQ_DEFAULT_PASS를 .env와 동일하게 지정. 
  - namespace를 배포할 namespace로 변경.  
- subride하위의 yaml
  - 공통 수정: namespace, ingress host, image경로를 일괄적으로 수정(아래 예제 참조)
    모든 yaml에 대해 수행함. 아래는 namespace를 'ondal'로,  
    ingress domain을 'cna.com'으로, 
    image 경로에서 organization과 tag를 바꾸는 예시임.  
    ```
    sed -i'' "s/namespace:.*/namespace: ondal/g" config.yaml
    sed -i'' "s/msa.edutdc.com/cna.com/g" config.yaml

    ```

    image 경로 변경은 아래 예제를 참조하며, 각 파일마다 경로명은 바꿔야 함
    ```
    sed -i'' "s@docker.io/hiondal/.*:.*@docker.io/ondal/config:2.0.0@g" config.yaml
    ```


  - config.yaml
    - ConfigMap의 'GIT_'으로 시작하는 Config 저장소 관련 변수 수정
    - Secret의 'GIT_TOKEN'값 수정
  - member.yaml
    - ConfigMap의 FRONT_HOST
    - FRONT_HOST: Backend application에 API를 요청하는 Front 주소. CORS설정을 위해 필요.  
      ```
      FRONT_HOST: http://subride-front.msa.edutdc.com,http://localhost:3000
      ```
    - ConfigMap의 RABBITMQ_USERNAME: rabbitmq.yaml에서 지정한 값과 동일해야 함
    - Secret의 RABBITMQ_PASSWORD: rabbitmq.yaml에서 지정한 값과 동일해야 함
    - Secret의 DB_PASSWORD: mysql.yaml에서 지정한 값과 동일해야 함
  - scg.yaml
    - ConfigMap의 'ALLOWED_ORIGINS'. Backend application에 API를 요청하는 Front 주소. CORS설정을 위해 필요.   

## Jar파일 Build


## Container image Build/Push


## k8s에 배포


  
