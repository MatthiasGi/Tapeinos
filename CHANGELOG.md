## Changelog

### v0.2.2 (2015-05-24)
Bugfixes:

* Login-routes can now be accessed by email-addresses with more complex contents than only word-characters (e.g. hyphens).
* Precompilation of assets now also includes the pdf-stylesheet.

### v0.2.1 (2015-05-18)
* Added favicons in different sizes.
* Banned bots from scanning the application.

### v0.2.0 (2015-05-18)
New features:

* Servers can now be identified by custom shortnames.
* All Mailers are now outsourced in asychronous jobs.
* Data sets in the administrative interface are now searchable and sortable.
* The whole UI is completly revamped for mobile.
* This localized about-page was added to help the user keep track of all changes.
* Login-paths inside of messages are much more intelligent.
* Global configuration is stored and managed by the application on a file-basis.
* A setup-wizard now guides new administrators through the process of preparing everything for the users.
* Messages can now be targetted to an individual group.
* The UI is richer with help- and confirmation-messages.
* Administrators can simulate servers.
* The administrative interface is much more friendlier.
* It is now saved seperatly, which server has already enrolled for which plan. This allows for telling servers, which plans they didn't participate in and telling the administrator, how many and which servers are still missing.
* A new user-role, root, the super-duper-administrator, was introduced.
* The application is now able to handle the current timezone.
* All plans can be exported in pdfs and sent automagically via messages.
* Tapeinos has it's own icon.

Bugfixes:

* Triggering the login-page from within an administrative page rendered the wrong layout.
* The navbar exactly knows, which controller is active and displays your proper location.

### v0.1.0 (2015-03-17)
* First release with basic functionality.
