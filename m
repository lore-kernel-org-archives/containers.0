From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: RE: Containers HOWTO?  (Where do I start?)
Date: Wed, 8 Dec 2010 21:17:45 +0000
Message-ID: <7E28E74ACE78074AAD1BDD3E455CF874942D@US-EXCH1.sw.swsoft.com>
References: <7E28E74ACE78074AAD1BDD3E455CF87493D3@US-EXCH1.sw.swsoft.com>,
	<20101208150239.GC8316@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101208150239.GC8316-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

> A few places to start since you want to start from the ground up:
>
> 1. man clone

Yup, got that one already.

> 2. man pivot_root

I wrote the busybox switch_root implementation, which meant I had to
really _understand_ the full horror of the pivot_root implementation
and why it _wasn't_ switch_root (examining every process in the system
so you can move their chroot entry for kernel threads and daemons is
really ugly, but you can't unmount a filesystem that has processes
pinning it).  Although come to think of it I thought kernel threads were
parked in initramfs these days?  (Doesn't initrd overmount initramfs?
Now I have to go look at what the code's doing again...)

But how does pivot_root enter into this when you haven't got an initrd to
free?  I thought when you killed a container's init process that killed all
the children and freed the resources, so how does pivot_root enter
into this?  (You don't reparent existing processes, you span new ones,
right?)

> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=tree;f=Documentation/cgroups;h=8c6b3f6c41a929f8db38b51a39442387ecbd5986;hb=HEAD

Ah, _that_ is what i was looking for.  Documentation/cgroups.

I'll look at #3 and #5 after reading that.

Thanks,

Rob
