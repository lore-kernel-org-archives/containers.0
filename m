From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [dm-devel] clone() with CLONE_NEWNET breaks kobject_uevent_env()
Date: Fri, 19 Aug 2011 11:39:20 -0700
Message-ID: <m1vctt2qlj.fsf@fess.ebiederm.org>
References: <4E4CDF44.5080109@redhat.com> <m17h69sr03.fsf@fess.ebiederm.org>
	<4E4E395B.7070106@redhat.com> <m1liup4oes.fsf@fess.ebiederm.org>
	<4E4E503B.3050406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E4E503B.3050406@redhat.com> (Milan Broz's message of "Fri, 19
	Aug 2011 13:59:55 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Milan Broz <mbroz@redhat.com>
Cc: device-mapper development <dm-devel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kay Sievers <kay.sievers@vrfy.org>, "David S. Miller" <davem@davemloft.net>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Milan Broz <mbroz@redhat.com> writes:

> On 08/19/2011 01:43 PM, Eric W. Biederman wrote:
>> Milan Broz <mbroz@redhat.com> writes:
>> 
>>> On 08/19/2011 11:13 AM, Eric W. Biederman wrote:
>>>> Milan Broz <mbroz@redhat.com> writes:
>>>>
>>>> I think the proper fix is to remove the error return from
>>>> kobject_uevent_env and kobject_uevent, and make it harder to get calling
>>>> of this function wrong.  Possibly in conjunction with that tag all of
>>>> the memory allocations of kobject_uevent_env with GFP_NOFAIL or
>>>> something so the memory allocator knows that this path is totally
>>>> not able to deal with failure.
>>>>
>>>> Is kobject_uevent_env anything except an asynchronous best effort
>>>> notification to user-space that a device has come or gone?
>>>
>>> Unfortunately it is for device-mapper. libdevmapper
>>> depends on information that uevent was sent because udev rules uses
>>> semaphore to inform that some action was taken.
>>> So if dm-ioctl returns flag that uevent was not sent, it fallback
>>> to different error path (otherwise it waits for completion forever).
>>> (TBH I am more and more convinced this was not quite clever concept.)
>> 
>> If I understand your description and the code right the guarantee that
>> you need is that kobject_uevent will return success only if it has
>> queued a packet in every listening netlink socket.
>
> I think so. IOW success == event was sent to all active listeners.
>
>> We already ignore ENOBUFS so the guarantee you appear to need in
>> libdevmapper does not appear to be present in kobject_uevent.
>> 
>> Does the libdevmapper code work despite getting a spurious failure?
>
> BTW I do not see ENOBUFS but ESRCH (from netlink_broadcast_filtered).
>
> If spurious failure is that event is sent (even partially) but it reports
> failure, it is the exact situation I see now - libdevmapper will try
> to decrement system semaphore which is already removed from udev rules.
>
> Final state is correct, just it prints ugly warnings. IOW it recovers
> from this situation correctly.

Then I guess this is fixable in kobject_uevent_env.  I'm not certain
it is smart to support this case but it appears supportable.

> But Kay's suggestion to use netlink_has_listeners() seems like good
> idea. IOW if there is no listener, it should skip quietly and not
> fail the whole call...

In the case of ESRCH I completely agree.

We are currently ignoring errors in the semantically more interesting
case when netlink_broadcast does not deliver the packet to one of the
listening netlink sockets.

How does this patch look?
---

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 70af0a7..7da5ef3 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -139,6 +139,7 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 	u64 seq;
 	int i = 0;
 	int retval = 0;
+	bool delivery_failed;
 #ifdef CONFIG_NET
 	struct uevent_sock *ue_sk;
 #endif
@@ -251,6 +252,7 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 	if (retval)
 		goto exit;
 
+	delivery_failure = false;
 #if defined(CONFIG_NET)
 	/* send netlink message */
 	mutex_lock(&uevent_sock_mutex);
@@ -281,14 +283,15 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 							    0, 1, GFP_KERNEL,
 							    kobj_bcast_filter,
 							    kobj);
-			/* ENOBUFS should be handled in userspace */
-			if (retval == -ENOBUFS)
-				retval = 0;
+			if (retval && (retval != -ESRCH))
+				delivery_failure = true;
 		} else
-			retval = -ENOMEM;
+			delivery_failure = true;
 	}
 	mutex_unlock(&uevent_sock_mutex);
 #endif
+	if (delivery_failure)
+		retval = -ENOBUFS;
 
 	/* call uevent_helper, usually only enabled during early boot */
 	if (uevent_helper[0] && !kobj_usermode_filter(kobj)) {
