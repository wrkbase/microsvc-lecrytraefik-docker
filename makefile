SHELL=/bin/bash

DOMAIN ?= piebill.com
EMAIL ?= wkbase@gmail.com

# Start all User, Payment and Report Micro-Services on native Ubuntu/Linux OS
start-native:
	echo "Starting all 3 Micro-Services..."
	$(MAKE) up-user
	sed -i -e 's/(URL_DOKR_USER)/(URL_NATV_USER)/' payment/app.py
	$(MAKE) up-payment
	sed -i -e 's/(URL_DOKR_PAYMENT)/(URL_NATV_PAYMENT)/' report/app.py
	$(MAKE) up-report
	echo "All 3 Services are up and Running..."


# Start all User, Payment, Report and Traefik Micro-Services in Docker Containers running on Ubuntu/Linux OS
start-docker:
	export DOMAIN=${DOMAIN}
	export EMAIL=${EMAIL}
	echo "Starting all 3 Micro-Services..."
	sed -e "s/DOMAIN_NAME/${DOMAIN}/" docker-compose.ORG > docker-compose.yml
	sed -i -e 's/(URL_NATV_PAYMENT)/(URL_DOKR_PAYMENT)/' report/app.py
	sed -i -e 's/(URL_NATV_USER)/(URL_DOKR_USER)/' payment/app.py
	sed -i -e 's/(URL_NATV_PAYMENT)/(URL_DOKR_PAYMENT)/' report/app.py
	sudo rm -rf log; mkdir -p log
	docker compose -f ./docker-compose.yml up -d
	echo "All 3 Services are up and Running..."

# Kill all User, Payment and Report Micro-Services on Ubuntu/Linux OS
kill:
	pkill flask || true # true for makefile to proceed ignoring $?=1 exit status

status:
	ps -ef | grep flask
	pgrep flask || true

clean-logs-docker:
	sudo rm -rf log; mkdir -p log

clean-native: kill
	find . -name "__pycache*"  -exec rm -rf '{}' \; -print || true

# Remove all User, Payment, Report and Traefik Micro-Services in Docker Containers running on  Ubuntu/Linux OS
clean-docker: kill clean-logs-docker
	find . -name "__pycache*"  -exec rm -rf '{}' \; -print
	rm -f docker-compose.yml
	docker images ls -a ; docker container ls -la ; docker volume ls ; docker network ls; docker ps -a
	docker stop $$(docker ps -qa) || true # true for makefile to proceed ignoring $?=1 exit status
	docker container ls -la | awk '{print $$1}' | grep -v "CONTAINER" | xargs docker container rm || true
	docker images -a | awk '{print $$3}' | grep -v "IMAGE" | xargs docker image remove || true
	docker volume rm $$(docker volume ls -q) ;  docker image prune -af
	docker container prune -af ; docker volume prune -af ; docker system prune -af
	docker images ls -a ; docker container ls -la ; docker volume ls ; docker network ls; docker ps -a

clean-all: clean-native clean-docker
	echo "Cleaned both Native/Local and Docker Deployments"

# Test User, Payment and Report Micro-Services on native Ubuntu/Linux OS
test-native:
	curl http://127.0.0.1:5001/user; echo
	curl http://127.0.0.1:5002/payment; echo
	curl http://127.0.0.1:5003/report; echo

# Test User, Payment, Report and Traefik Micro-Services in Docker Containers running on Ubuntu/Linux OS
test-docker:
	curl -k https://${DOMAIN}:443; echo
	curl -k https://${DOMAIN}:443/user; echo
	curl -k https://${DOMAIN}:443/payment; echo
	curl -k https://${DOMAIN}:443/report; echo
	curl -k https://127.0.0.1:443/report; echo
	echo "Last one https://127.0.0.1:443/report should give: 404 page not found "; echo

# Startup User Micro-Service on native Ubuntu/Linux OS
up-user:
	flask --app user/app.py run --host 0.0.0.0 --port 5001 &
	echo "Waiting for deployment of User Micro-Services to finish"
	# ps -ef | grep flask | grep "user/app.py"
	for i in $$(seq 1 10); do \
		test $$( ps -ef | grep flask | \
			grep "user/app.py" | \
			awk '{print $$11}' | grep "app.py"  | wc -l 2> /dev/null ) -eq 1 && break; \
		sleep 1; \
	done

# Startup Payment Micro-Service on native Ubuntu/Linux OS
up-payment: up-user
	flask --app payment/app.py  run --host 0.0.0.0 --port 5002 &
	echo "Waiting for deployment of Payment Micro-Services to finish"
	# ps -ef | grep flask | grep "user/app.py"
	for i in $$(seq 1 10); do \
		test $$( ps -ef | grep flask | \
			grep "user/app.py\|payment/app.py" | \
			awk '{print $$11}' | grep "app.py"  | wc -l 2> /dev/null ) -eq 2 && break; \
		sleep 1; \
	done

# Startup Report Micro-Service on native Ubuntu/Linux OS
up-report: up-user up-payment
	flask --app report/app.py  run --host 0.0.0.0 --port 5003 &
	echo "Waiting for deployment of Report Micro-Services to finish"
	# ps -ef | grep flask | grep "user/app.py"
	for i in $$(seq 1 10); do \
		test $$( ps -ef | grep flask | \
			grep "user/app.py\|payment/app.py\|report/app.py" | \
			awk '{print $$11}' | grep "app.py"  | wc -l 2> /dev/null ) -eq 3 && break; \
		sleep 1; \
	done

