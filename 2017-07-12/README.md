## Microsoft drops by to talk PowerShell and DSC

Portland PowerShell User Group - 12 July 2017

Michael Green ([@migreene](https://twitter.com/migreene)), Joey Aiello ([@joeyaiello](https://twitter.com/joeyaiello)) and Mark Gray ([@markg_msft](https://twitter.com/markg_msft)) dropped by to talk about all things PowerShell and DSC

Notes
---
What is a cmdlet? vs functions? modules etc.
modules script cmdlets - c# vs script benefits etc.
How do I approach a cmdlet design?
Powershell best practices for IT Pros (vs Devs)  - Source Control (pipeline whitepaper?)
aka.ms/trpm  (The Release Pipeline)
- Leverage your Dev teams and follow them!
- Learn about testing (Pester for PS)
  - For Ops - Operational Validation Framework (OVF)
  - Watchmen (Brandon Olin)

Cool new PS projects (github.com/powershell)
- Phosphor: Cross platform autogen UI for PS
- Plaster: Templating for PS (similar to yeoman)
- PSScriptAnalyzer: Linter for PS (integrated into VS Code PS extension)
- PSSwagger: (coming) Autogen PS Cmdlet from a Swagger spec (REST API - typically JSON)
- PlatyPs: Help text for PS

PSake - Community unit build task runner (similar to rake, bake, cake, fake)
      - Also InvokeBuild

Using Credentials
PS for SQL is different for "regular" PS. Ideas?
What am I missing with PS on linux
Timelines for PowerShell 6?

DOCS!

DSC Modules - Class based - WHere are they going vs MOF based


What we didn't get to:
---
Package management and Choco - official MS direction?

What's your favourite cmdlet?
Future of DSC
Where does SCCM and SCOM fit into DSC
AWS?
ARM Templates / provisioning / boot strapping DSC and agents
How stable is using PS with Azure (DSC Resource or Azure SDK or Both)
DSC - How about integration guidelines e.g. Puppet/Chef/Ansible
