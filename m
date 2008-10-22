From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
	sysfs entries
Date: Wed, 22 Oct 2008 17:21:44 +0200
Message-ID: <20081022152144.351965414__8078.32378563962$1224689167$gmane$org@theryb.frec.bull.fr>
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
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org


Support for network namespaces in mainline is pretty complete for
some time now, but there is still this issue with sysfs that prevents 
more people to use it easily.

Reminder for those not aware of the netns/sysfs issue:

With network namespaces, the kernel must be able to support net devices
with the same name in different network namespaces: the most obvious 
example being the loopback device, which exists in every namespace. 
The remaining place where this doesn't work yet is sysfs.

In the last 12 months, Eric Biederman proposed different approaches
to support this and sent several patchsets to implement what he calls
"sysfs tagged directories". But unfortunately, there is still no 
agreement on the patchset and its implementation.

See last round of comments there: 
http://thread.gmane.org/gmane.linux.kernel/735612/focus=740050

So, currently testing network namespaces on a mainline kernel is a
pain and involves either to disable sysfs completely (argh) or to find
and manually apply Eric's latest patchset (was in gregkh's tree for a 
short time, but unfortunately it was dumped out a few a weeks ago).


This patchset explores an alternative suggested by Serge Hallyn
to  *temporarily*  fix this issue. It introduces the modifications 
needed to register in sysfs, the network devices belonging to child
network namespaces with a suffix appended to their name to avoid 
potential conflicts.

http://thread.gmane.org/gmane.linux.kernel/735612/focus=741757

Network devices from the initial network namespace are untouched.
Their representation in sysfs (/sys/class/net/, ...) is unchanged.

Network devices from sub-network namespaces appear in sysfs
with a name that looks like this: device_name@netns_id
eg: lo@3, eth0@4e

See last patch of the series for the details.

Then, if needed in the child network namespace, we can filter 
/sys/class/net contents with, for example:

* mount -t tmpfs /sys/class/net 
* and  manually link the right devices from /sys/devices/virtual/net
  (ln -s ../../devices/virtual/net/lo@1 lo)

This is less elegant than Eric's approach, but is quite simple and 
doesn't touch sysfs core code.

This patch applies on top of net-next-2.6.

Benjamin

-- 
