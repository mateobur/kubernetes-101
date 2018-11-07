#!/bin/sh

cat <<- 'EOF' > "redis-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: redis
  labels:
    name: redis-deployment
    app: example-voting-app
spec:
  replicas: 1
  selector:
    matchLabels:
     name: redis
     role: redisdb
     app: example-voting-app
  template:
    spec:
      containers:
        - name: redis
          image: redis:alpine
          resources:
            limits:
              memory: 64Mi
            requests:
              memory: 32Mi
    metadata:
      labels:
        name: redis
        role: redisdb
        app: example-voting-app
EOF

cat <<- 'EOF' > "redis-service.yaml"
apiVersion: v1
kind: Service
metadata: 
  labels: 
    name: redis
  name: redis
spec: 
  ports:
    - port: 6379
      targetPort: 6379
  selector:
    name: redis 
    app: example-voting-app
    role: redisdb
EOF

cat <<- 'EOF' > "db-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: db
  labels:
    name: db-deployment
    app: example-voting-app
spec:
  replicas: 1
  selector:
    matchLabels:
     name: db
     role: sqldb
     app: example-voting-app
  template:
    spec:
      containers:
        - name: db
          image: postgres:9.4
          resources:
            limits:
              memory: 256Mi
              cpu: "0.5"
            requests:
              memory: 128Mi
    metadata:
      labels:
        name: db
        role: sqldb
        app: example-voting-app
EOF

cat <<- 'EOF' > "db-service.yaml"
apiVersion: v1
kind: Service
metadata: 
  labels: 
    name: db
  name: db
spec: 
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    name: db
    app: example-voting-app
    role: sqldb
EOF

cat <<- 'EOF' > "vote-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: vote
  labels:
    name: vote-deployment
    app: example-voting-app
spec:
  replicas: 1
  selector:
    matchLabels:
     name: vote
     role: voteapp
     app: example-voting-app
  template:
    spec:
      containers:
        - name: vote
          image: bencer/example-voting-app-vote:statsd-5
          resources:
            limits:
              memory: 128Mi
            requests:
              memory: 64Mi
    metadata:
      labels:
        name: vote
        role: voteapp
        app: example-voting-app
EOF

cat <<- 'EOF' > "vote-service.yaml"
apiVersion: v1
kind: Service
metadata: 
  labels: 
    name: vote
  name: vote
spec: 
  ports:
    - port: 80 
      targetPort: 80
  selector:
    name: vote
    app: example-voting-app
    role: voteapp
EOF

cat <<- 'EOF' > "result-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: result
  labels:
    name: result-deployment
    app: example-voting-app
spec:
  replicas: 3
  selector:
    matchLabels:
     name: result
     role: resultapp
     app: example-voting-app
  template:
    spec:
      containers:
        - name: result
          image: bencer/example-voting-app-result:metrics-3
          resources:
            limits:
              memory: 64Mi
            requests:
              memory: 32Mi
              cpu: "250m"
    metadata:
      labels:
        name: result
        role: resultapp
        app: example-voting-app
EOF

cat <<- 'EOF' > "result-service.yaml"
apiVersion: v1
kind: Service
metadata: 
  labels: 
    name: result
  name: result
spec: 
  ports:
    - port: 80 
      targetPort: 80
  selector:
    name: result
    app: example-voting-app
    role: resultapp
EOF

cat <<- 'EOF' > "worker-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: worker
  labels:
    name: worker-deployment
    app: example-voting-app
spec:
  replicas: 1
  selector:
    matchLabels:
     name: worker
     role: workerapp
     app: example-voting-app
  template:
    spec:
      containers:
        - name: worker
          image: bencer/example-voting-app-worker:jmx-1
          resources:
            limits:
              memory: 128Mi
            requests:
              memory: 64Mi
    metadata:
      labels:
        name: worker
        role: workerapp
        app: example-voting-app
EOF

cat <<- 'EOF' > "voter-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: voter
  labels:
    name: voter-deployment
    app: example-voting-app
spec:
  replicas: 1
  selector:
    matchLabels:
     name: voter
     role: voterapp
     app: example-voting-app
  template:
    spec:
      containers:
        - name: voter
          image: bencer/example-voting-app-voter:0.1
          env:
            - name: VOTE
              value: "vote.example-voting-app.svc.cluster.local"
            - name: PORT
              value: "80"
          resources:
            limits:
              memory: 64Mi
            requests:
              memory: 32Mi
    metadata:
      labels:
        name: voter
        role: voterapp
        app: example-voting-app
EOF

cat <<- 'EOF' > "observer-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: observer
  labels:
    name: observer-deployment
    app: example-voting-app
spec:
  replicas: 1
  selector:
    matchLabels:
     name: observer
     role: observerapp
     app: example-voting-app
  template:
    spec:
      containers:
        - name: observer
          image: bencer/recurling:0.1
          env:
            - name: URL
              value: "result.example-voting-app.svc.cluster.local"
            - name: SLEEP
              value: "5"
          resources:
            limits:
              memory: 64Mi
            requests:
              memory: 32Mi
    metadata:
      labels:
        name: observer
        role: observerapp
        app: example-voting-app
EOF

kubectl create namespace example-voting-app
kubectl create -f redis-deployment.yaml --namespace example-voting-app
kubectl create -f redis-service.yaml --namespace example-voting-app
kubectl create -f db-deployment.yaml --namespace example-voting-app
kubectl create -f db-service.yaml --namespace example-voting-app
kubectl create -f vote-deployment.yaml --namespace example-voting-app
kubectl create -f vote-service.yaml --namespace example-voting-app
kubectl create -f result-deployment.yaml --namespace example-voting-app
kubectl create -f result-service.yaml --namespace example-voting-app
kubectl create -f worker-deployment.yaml --namespace example-voting-app
kubectl create -f voter-deployment.yaml --namespace example-voting-app
kubectl create -f observer-deployment.yaml --namespace example-voting-app
rm redis-deployment.yaml redis-service.yaml db-deployment.yaml db-service.yaml vote-deployment.yaml vote-service.yaml result-deployment.yaml result-service.yaml worker-deployment.yaml voter-deployment.yaml observer-deployment.yaml
