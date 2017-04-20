#!/bin/bash
PROJECTS=(src/Warden.Watchers.MsSql)
for PROJECT in ${PROJECTS[*]}
do
  dotnet restore $PROJECT
  dotnet build $PROJECT
done


