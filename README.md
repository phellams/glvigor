# <img width="25" src="https://raw.githubusercontent.com/sgkens/resources/main/modules/glvigor/dist/v1/glvigor-icon-x128.png"/>  **glvigor**


<!--license-->
<a href="https://github.com/sgkens/glvigor/blob/main/LICENSE">
<img src="https://img.shields.io/badge/license-mit-blue?style=for-the-badge&logo=unlicense&label=License&logoColor=rgba(255%2C255%2C255 245%2C245%2C245%2C1)&labelColor=rgba(255%2C165%2C0 255%2C69%2C0%2C1)&color=rgba(178%2C34%2C34%2C1)"></a><!--Code-Factor-->
<a href="https://www.codefactor.io/repository/github/sgkens/glvigor">
<img src="https://img.shields.io/codefactor/grade/github/sgkens/glvigor?style=for-the-badge&logo=codefactor&label=codefactor&logoColor=255%2C255%2C255 245%2C245%2C245%2C1&labelColor=rgba(255%2C165%2C0 255%2C69%2C0%2C1)&color=rgba(178%2C34%2C34%2C1)"></a><!--coverage-->
<a href="https://coveralls.io/github/sgkens/glvigor">
<img src="https://img.shields.io/coverallsCoverage/github/sgkens/glvigor?style=for-the-badge&logo=coveralls&label=coveralls&logoColor=rgba(255%2C255%2C255 245%2C245%2C245%2C1)&labelColor=rgba(255%2C165%2C0 255%2C69%2C0%2C1)&color=rgba(178%2C34%2C34%2C1)"></a>

GLViger offers a comprehensive set of cmdlets for managing key resources on a GitLab instance. With this module, you can create, view, update, remove, and search for *issues*, *merge requests*, *projects*, *groups*, and *labels* through the GitLab API. Additionally, the module includes cmdlets for handling Git-related functions, such as *viewing*, *adding*, and removing *mirrors*, as well as updating the *origin*.

# Features

🟣 ***Gitlab API***
 - Search gitlab resources *`projects`*, *`issues`*, *`merge_requests`*, *`milestones`*, *`snippet_titles`*, *`users`*, *`blobs`*, *`commits`*, and *`notes`*.
 - ***Create/Edit/View/Delete*** Mirror configuration for projects, endpoint support: *`gitlab`*, *`gitea`*, *`gitlalen SE(CE|EE)`*
 - ***Create/Edit/View/Delete***  Issues, supported types `issue`, `incident`, and `task`.
   - Filter by `State`, `Milestone`, `labels`
 - ***Create/Edit/View/Delete*** Projects
 - ***Create/Edit/View/Delete*** groups
 - ***Create/Edit/View/Delete*** labels
 - ***Create/Edit/View/Delete*** merge_requests

🔵 ***Git***
 - Retrieve and update git origin, returns non-mirrored origin as a `pscustomobject`
 - Configure local remote mirrors, mirror endpoint support: *gitlab*, *gitea*, *gitlalen SE(CE|EE)*

## ⚡Type Accelerators or Aliases
|🔹═Function Cmdlet|⚡═Accelerator Alias|
|-|-|
|♾|⚡|

# Install module

📦 Installing from Package Repositories or `.nupkg` files see [***Releases***](https://)

🛖 Installing from git repository:

1. 📥 Cone Repository.
    ```bash
    git clone https://gitlab.com/sgkens/coforge.git
    ``` 
2. 🗃 Importing the module\library.
    ```powershell
    # class methods and type Accelerators(cmdlets/functions)
     using module path\to\coforge\lib\coforge.psm1` 

    # or

    # Importing as you would a standard powershell module, 
    Import-Module -Name "path\to\coforge\"
    ```

# Cmdlets

### 🟢 Request-GitlabAuth
Sends a request to the specified GitLab API endpoint, retrieves specified user data, if authenticated sets the `$global:_glvigor.auth` object.
|🔹═Function Cmdlet ⚡═Accelerator Alias  |
|-|
|🔹`Request-GitLabAuth [[-Hostname] <String>] [[-APIKey] <String>]`|
|⚡`glvauth [[-h] <String>] [[-a] <String>]`|

```powershell
# using $env:gitlab_host & $env:gitlab_api_key
Request-GitLabAuth

# using params
Request-GitLabAuth -Hostname 'gitlab.mydomain.com' -apikey 'klhf7asf7mlknhbalkjsf8a7sf'
```
*🔻returns*:  `void`

Examples:


## *API*

--Request-GitlabAuth
Sends a request to the specified gitlab api endpoint return user data generating a global auth object.

--Search-Gitlab
<kbd>requires</kbd> git
Sends a request to the search gitlab api endpoint, supported -types `projects`, `issues`, `merge-requests`, `groups`

# Build

# Package Repositories

# Releases

## 📑 License

This project is © licensed under the [MIT License](LICENSE).
