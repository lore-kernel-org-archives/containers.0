From: Amos Kong <akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cgroup: fix device deny of DEV_ALL
Date: Fri, 18 May 2012 16:19:12 +0800
Message-ID: <20120518081912.16779.21065.stgit@t>
References: <CAFeW=pZ8Y7ycxjxro7zBMqdtaCOYs4RmoxtDrsN8+mqLhOL--g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFeW=pZ8Y7ycxjxro7zBMqdtaCOYs4RmoxtDrsN8+mqLhOL--g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtosatti-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

@ mount -t cgroup -o devices none /cgroup
@ mkdir /cgroups/devices
@ ls -l /dev/dm-3
 brw-rw----. 1 root disk 253, 3 Oct 14 19:03 /dev/dm-3
@ echo 'b 253:3 rw' > devices.deny
but I can still write it by 'dd if=/dev/zero of=/dev/dm-3'

In devcgroup_create(), we create a new whitelist, and add first
entry which type is 'DEV_ALL'. Execute "# echo 'b 253:3 rw' >
devices.deny", dev_whitelist_rm() will update access of first
entry to 1(m), but type of first entry is still 'DEV_ALL'.

Execute dd cmd to write device, __devcgroup_inode_permission()
will be called, permission checking will pass if entry type
is 'DEV_ALL'. So write operation of 'dd' is not denied.

Currently 'access' is updated by not be used, this patch updated
the type,major,minor of first entry, then permission checking
would work.

Signed-off-by: Amos Kong <akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 security/device_cgroup.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index c43a332..d16b4bc 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -146,6 +146,11 @@ static void dev_whitelist_rm(struct dev_cgroup *dev_cgroup,
 
 remove:
 		walk->access &= ~wh->access;
+		if (walk->type == DEV_ALL) {
+			walk->type = wh->type;
+			walk->major = wh->major;
+			walk->minor = wh->minor;
+		}
 		if (!walk->access) {
 			list_del_rcu(&walk->list);
 			kfree_rcu(walk, rcu);
