# Copyright 2026 Factory-X Consortia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# It is expected that this docker is executed in the context of repository root.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /repo/src

# Copy everything else and build
COPY src/ /repo/src/
COPY LICENSE.TXT /repo/LICENSE.txt
RUN dotnet publish -c Release -o /out/AasxServerBlazor AasxServerBlazor

FROM mcr.microsoft.com/dotnet/aspnet:8.0 as base
RUN apt-get update && apt-get install -y libgdiplus fonts-dejavu-core fonts-freefont-ttf
COPY --from=build-env /out/AasxServerBlazor/ /AasxServerBlazor/
#COPY content-for-demo/ /AasxServerBlazor/
WORKDIR /AasxServerBlazor
ENTRYPOINT ["dotnet", "AasxServerBlazor.dll"]
