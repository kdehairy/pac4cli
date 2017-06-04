PYTHON ?= python3
PORT ?= 3128

env: requirements.txt
	virtualenv -p $(PYTHON) env
	env/bin/pip install -r requirements.txt
	PYTHON=`pwd`/env/bin/python make -C pacparser/src install-pymod

run:
	env/bin/python main.py -F DIRECT -p $(PORT)

check:
	./testrun.sh $(PORT)

install:
	systemctl stop pac4cli.service || true
	virtualenv -p $(PYTHON) /opt/pac4cli
	/opt/pac4cli/bin/pip install -r requirements.txt
	PYTHON=/opt/pac4cli/bin/python make -C pacparser/src install-pymod
	install -m 644 main.py proxy.py /opt/pac4cli
	install -m 644 pac4cli.service /lib/systemd/system
	install -m 755 -o root -g root trigger-pac4cli /etc/NetworkManager/dispatcher.d
	install -m 755 pac4cli.sh /etc/profile.d
	systemctl enable pac4cli.service
	systemctl start pac4cli.service

uninstall:
	systemctl stop pac4cli.service
	systemctl disable pac4cli.service
	rm -rf /opt/pac4cli
	rm -f /lib/systemd/system/pac4cli.service
	rm -f /etc/network/if-up.d/trigger-pac4cli
	rm -f /etc/network/if-down.d/trigger-pac4cli
	/etc/profile.d/pac4cli.sh
