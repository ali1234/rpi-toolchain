TARGET:=arm-linux-gnueabihf
VERSION:=$(shell git describe --always --dirty)
NAME:=raspbian-$(VERSION)
TOOLCHAIN:=toolchain-$(NAME)-x86_64-$(TARGET)
SRC:=src-$(NAME)
URL:=https://github.com/ali1234/rpi-toolchain/issues/new?body=Version:%20$(VERSION)

export DEB_TARGET_MULTIARCH=$(TARGET)

all: $(TOOLCHAIN).tar.xz.asc $(SRC).tar.xz.asc

%.tar.xz.asc: %.tar.xz
	sha256sum $< > $@

.config: ct-ng-config
	sed -E  -e 's|^(CT_TOOLCHAIN_PKGVERSION)=.*|\1=\"$(NAME)\"|' \
	 		-e 's|^(CT_TOOLCHAIN_BUGURL)=.*|\1=\"$(NAME)\"|' ct-ng-config > .config

result/success: .config
	ct-ng build && touch result/success

$(TOOLCHAIN).tar.xz: result/success
	rm -rf --one-file-system result/$(TOOLCHAIN)
	mkdir result/$(TOOLCHAIN)
	rsync -av result/$(TARGET)/* result/$(TOOLCHAIN)
	ct-ng --version > result/$(TOOLCHAIN)/ct-ng-version
	cp .config result/$(TOOLCHAIN)/ct-ng-config
	tar Jcf $(TOOLCHAIN).tar.xz --directory result $(TOOLCHAIN)

$(SRC).tar.xz: result/success
	ct-ng --version > src/ct-ng-version
	cp .config src/ct-ng-config
	tar Jcf $(SRC).tar.xz src

saveconfig:
	sed -E  -e 's|^(CT_TOOLCHAIN_PKGVERSION)=.*|\1=\"\"|' \
	 		-e 's|^(CT_TOOLCHAIN_BUGURL)=.*|\1=\"\"|' .config > ct-ng-config

menuconfig: .config
	ct-ng menuconfig

clean:
	rm -rf build result build.log .config .config.old
	rm -rf $(TOOLCHAIN).tar.xz $(TOOLCHAIN).tar.xz.asc $(SRC).tar.xz $(SRC).tar.xz.asc

reallyclean: clean
	rm -rf *.tar.xz *.tar.xz.asc

indocker:
	docker build -t rpi-toolchain .
	docker create -it --name rpi-toolchain-tmp rpi-toolchain
	docker start rpi-toolchain-tmp
	docker exec -it rpi-toolchain-tmp make
	docker cp rpi-toolchain-tmp:/home/toolchain/rpi-toolchain/$(TOOLCHAIN).tar.xz .
	docker cp rpi-toolchain-tmp:/home/toolchain/rpi-toolchain/$(TOOLCHAIN).tar.xz.asc .
	docker cp rpi-toolchain-tmp:/home/toolchain/rpi-toolchain/$(SRC).tar.xz .
	docker cp rpi-toolchain-tmp:/home/toolchain/rpi-toolchain/$(SRC).tar.xz.asc .
	docker cp rpi-toolchain-tmp:/home/toolchain/rpi-toolchain/build.log .
	docker rm -f rpi-toolchain-tmp
