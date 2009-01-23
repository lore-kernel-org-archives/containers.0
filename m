From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: commit 7534432dcc3c654a8671b6b0cdffd1dbdbc73074
Date: Thu, 22 Jan 2009 17:26:37 -0800
Message-ID: <1232673997.8007.183.camel@localhost>
References: <20090122184754.GA17511@us.ibm.com>
	<6599ad830901221507x796c154ck5fe4f95cc3eb8e0e@mail.gmail.com>
	<6599ad830901221535w6c723eb6xd0adced0ff6a1fb6@mail.gmail.com>
	<6599ad830901221626o2fd5025fib3c1c6d182e52e63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830901221626o2fd5025fib3c1c6d182e52e63-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-01-22 at 16:26 -0800, Paul Menage wrote:
> On Thu, Jan 22, 2009 at 3:35 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > On Thu, Jan 22, 2009 at 3:07 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> >>> mount -t cgroup -o freezer,ns none /cgroup
> >>
> >> This command should have failed with EBUSY, since freezer is already
> >> part of an existing hierarchy. So I think it's a red herring in this
> >> problem.
> >
> > But in fact taking out this line does stop the crash. So it's a bug in
> > the error handling when you try to mount a hierarchy with a subsystem
> > that's already busy elsewhere.
> 
> It's due to root_count getting out of sync with reality. It gets
> incremented in cgroup_get_sb() after we've done all error checking,
> but decremented in cgroup_kill_sb, which can be called on a superblock
> that we tried to create but then gave up on. I guess the fix is to
> increment root_count as soon as we have the superblock.
> 
> Paul

	I see what you mean. I am still mystified how rcu_read_lock() around
the cgroup iterator in cgroupstats_build() hid/prevented the problem
though :/.

	Incrementing the root_count early dissociates root_count and the
addition to root list, doesn't it? How about only decrementing the count
if we're on the list as in the patch below?

Cheers,
	-Matt Helsley

Subject: [PATCH][RFC] Fix incorrect root_count decrement when recovering
from error in cgroup_get_sb()

We may be recovering from an error in cgroup_get_sb() that occured prior
to adding the new hierarchy root to the roots list. Check if root was
added to roots and only decrement if it has been.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
Totally untested. Need to check that &root->root_list is empty whenever
root is off the roots list.

 kernel/cgroup.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6.29-rc1/kernel/cgroup.c
===================================================================
--- linux-2.6.29-rc1.orig/kernel/cgroup.c
+++ linux-2.6.29-rc1/kernel/cgroup.c
@@ -1115,8 +1115,11 @@ static void cgroup_kill_sb(struct super_
 	}
 	write_unlock(&css_set_lock);
 
-	list_del(&root->root_list);
-	root_count--;
+	if (!list_empty(&root->root_list)) {
+		list_del(&root->root_list);
+		root_count--;
+	} /* else we're recovering from an error in cgroup_get_sb() and hadn't added to
+	     the root list yet */
 
 	mutex_unlock(&cgroup_mutex);
