SOURCE_DIRECTORY := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

ARTIFACT_PATH := $(SOURCE_DIRECTORY)artifacts
PROJECT_PATH := src/NoSln
TOOL_PATH := $(SOURCE_DIRECTORY)tools
MINVER_VERSION := 1.0.0-beta.4
VERSION_FILE := $(TOOL_PATH)/version
PATH := $(PATH):$(TOOL_PATH)
CONFIGURATION ?= Release
NUGET_SOURCE ?= "https://api.nuget.org/v3/index.json"
NUGET_API_KEY ?= ""

clean:
	dotnet clean -c $(CONFIGURATION) $(PROJECT_PATH) && rm -rf $(TOOL_PATH) && rm -rf $(ARTIFACT_PATH) && rm -rf *.sln

minver: clean
	dotnet tool install --tool-path $(TOOL_PATH) minver-cli --version $(MINVER_VERSION)
	$(TOOL_PATH)/minver > $(VERSION_FILE)

build: minver
	dotnet pack -c $(CONFIGURATION) -o $(ARTIFACT_PATH) -p:Version=`cat $(VERSION_FILE)` $(PROJECT_PATH)
	dotnet tool install --add-source $(ARTIFACT_PATH) --tool-path $(TOOL_PATH) dotnet-nosln --version `cat $(VERSION_FILE)`

test: build
	dotnet nosln -D -o nosln.sln
	dotnet test -c $(CONFIGURATION)
	dotnet nosln -D src/ -o $(ARTIFACT_PATH)/src.sln
	dotnet nosln -D examples/ -o $(ARTIFACT_PATH)/examples.sln
	dotnet nosln -DFT -I 'tests/**/*' -o $(ARTIFACT_PATH)/tests.sln

install: build
	dotnet tool install --add-source $(ARTIFACT_PATH) -g dotnet-nosln --version `cat $(VERSION_FILE)`

uninstall:
	dotnet tool uninstall -g dotnet-nosln

push: test
	dotnet nuget push `ls $(ARTIFACT_PATH)/*.nupkg` -s $(NUGET_SOURCE) -k $(NUGET_API_KEY)

all: test

.DEFAULT_GOAL := build