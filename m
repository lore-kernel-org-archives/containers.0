From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 0/7] CGroup API: More structured API for CGroups control
	files
Date: Fri, 15 Feb 2008 12:44:18 -0800
Message-ID: <20080215204418.535025000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


This set of patches makes the Control Groups API more structured and
self-describing.

1) Allows control files to be associated with data types such as
"u64", "string", "map", etc. These types show up in a new cgroup.api
file in each cgroup directory, along with a user-readable
string. Files that use cgroup-provided data accessors have these file
types inferred automatically.

2) Moves various files in cpusets and the memory controller from using
custom-written file handlers to cgroup-defined handlers

3) Adds the "cgroup." prefix for existing cgroup-provided control
files (tasks, release_agent, releasable, notify_on_release). Given
than we've already had 2.6.24 go out without this prefix, I guess this
could be a little contentious - but it seems like a good move to
prevent name clashes in the future. (Note that this doesn't affect
mounting the legacy cpuset filesystem, since the compatibility layer
disables all prefixes when mounted with filesystem type "cpuset"). If
people object too strongly, we could just make this the case for *new*
cgroup API files, but I think this is a case where consistency would
be better than compatibility - I'd be surprised if anyone has written
major legacy apps yet that rely on 2.6.24 cgroup control file names.


There are various motivations for this:

1) We said at Kernel Summit '07 that the cgroup API wouldn't be
allowed to spiral into an arbitrary mess of ad-hoc APIs. Having simple
ways to represent common data types makes this easier. (E.g. one
standard way to report a map of string,u64 pairs to userspace.)

2) People were divided on the issue of binary APIs versus ASCII APIs
for control groups. Compatibility with the existing cpusets system,
and ease of experimentation, were two important reasons for going with
the current. ASCII API. But by having structured control files, we can
open the path towards having more efficient binary APIs for simpler
and more efficient programmatic access too, without any additional
modifications required from the subsystems themselves.

My plans for this potential binary API are a little hazy at this
point, but they might go something like opening a cgroup.bin file in a
cgroup directory, and writing the names of the control files that you
were interested in; then a read on that file handle would return the
contents of the given control files in a single read in a simple
binary format. (Better suggestions are welcome). Regardless, getting a
good typing/structure on the control files is an important first step
if we want to go in that direction.

3) The memory controller currently has files with the "_in_bytes"
suffix, on the grounds that otherwise it's not obvious to a new user
what they represent. By moving the description to a auto-generated API
file, we can remove this (IMO) inelegant suffix.


--
