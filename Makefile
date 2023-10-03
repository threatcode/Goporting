all: release

build: build_goporting

install_dependency:
	sudo apt update
	# Nodejs
	node --version || (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && bash -c "source ${HOME}/.nvm/nvm.sh && nvm install 14.19.0 && npm install -g yarn")
	# Golang
	axel --version || sudo apt install -y axel 
	unar --version || sudo apt install -y unar
	git --version || sudo apt install -y git
	go-bindata --version || sudo apt install -y go-bindata
	go version || (sudo axel https://go.dev/dl/go1.17.7.linux-amd64.tar.gz && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz)
	go env -w GO111MODULE=on
	go env -w GOPROXY=https://goproxy.cn,direct
	# upx
	sudo apt install -y upx

prepare: 
	bash -c "[[ -d termites ]] || mkdir termites"
	bash -c "[[ -d build ]] || mkdir build"

build_frontend: prepare
	echo "Building frontend"
	cd web/frontend && bash -c "source ${HOME}/.nvm/nvm.sh && yarn install && NODE_OPTIONS='--max-old-space-size=1024' yarn build"
	echo "Building ttyd"
	cd web/ttyd && bash -c "source ${HOME}/.nvm/nvm.sh && yarn install && NODE_OPTIONS='--max-old-space-size=1024' yarn build"

build_termite: prepare
	echo "Building termite"
	# echo -e "Building termite_linux_amd64"
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w " -trimpath -o ./build/termite/termite_linux_amd64 cmd/termite/main.go
	# echo -e "Building termite_linux_arm"
	env GOOS=linux GOARCH=arm GOARM=5 go build -ldflags="-s -w " -trimpath -o ./build/termite/termite_linux_arm cmd/termite/main.go

collect_assets: build_frontend build_termite
	echo "Collecting assets files"
	go-bindata -pkg assets -o ./internal/util/assets/assets.go ./assets/config.example.yml ./assets/template/rsh/... ./web/ttyd/dist/... ./web/frontend/build/... ./build/termite/...

dev:
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w " -trimpath -o ./build/termite/termite_linux_amd64 cmd/termite/main.go
	go-bindata -pkg assets -o ./internal/util/assets/assets.go ./assets/config.example.yml ./assets/template/rsh/... ./web/ttyd/dist/... ./web/frontend/build/... ./build/termite/...
	go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting cmd/goporting/main.go

build_goporting: collect_assets
	echo "Building goporting"
	go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting cmd/goporting/main.go

release: install_dependency collect_assets
	# Linux
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting_linux_amd64 cmd/goporting/main.go
	env GOOS=linux GOARCH=arm64 go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting_linux_arm64 cmd/goporting/main.go
	# MacOS
	env GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting_darwin_amd64 cmd/goporting/main.go
	env GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting_darwin_arm64 cmd/goporting/main.go
	# Windows
	env GOOS=windows GOARCH=amd64 go build -ldflags="-s -w " -trimpath -o ./build/goporting/goporting_windows_amd64.exe cmd/goporting/main.go
	find build -type f -executable | xargs upx

clean:
	rm -rf build
	rm -rf internal/util/assets/assets.go
	rm -rf web/frontend/build
	rm -rf web/ttyd/build
