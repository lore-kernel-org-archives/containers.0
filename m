From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: OLS Mini-Summit Proposal for Containers
Date: Thu, 31 Jan 2008 09:38:30 -0600
Message-ID: <20080131153830.GA28470@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: info-Gr7syQlKEaBFgBK04Mzu/R2eb7JE58TQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

== Title ==

Linux Kernel Containers Developer Summit

== Topic ==

Namespaces, containers, cgroups, resource management, and container
checkpoint/restart.

== Description ==

Development for namespaces and cgroups is well underway in the
mainline kernel. To keep momentum going and keep the loosely
knit teams of developers well-coordinated, a physical meeting in
which to discuss future development plans is needed.
Additionally, we are at a point where crucial decisions about
the nature of a "container object" and about the checkpoint/restart
design need to be made.

A final set of topics will be decided upon through mailing lists
ahead of time, but potential topics include:

* Handling filesystem/namespace synchronization
* Handling of /proc and /sysfs within containers
* Additional needed namespaces (i.e. device namespace)
* Nature of a 'container' -- kernel object or userspace fiction
* Cgroup implementation
* Additional cgroups and their design
* Resource management
* How to initiate and synchronize checkpoint/restart
* How to enter a 'container'

== Moderators ==

* Namespaces/containers: Serge Hallyn, Cedric Le Goater
* Cgroups and resource management: Paul Menage, Balbir Singh
* Checkpoint/restart: Dave Hansen, Cedric Le Goater

== Expected Time Required ==

One day.

== Number of Attendees ==

Approximately 30.

== Technical Requirements ==

* Projector and screen
* Whiteboard
* Network access
* Power for laptops
* doughnuts and croissants for participants
