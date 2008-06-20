From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch -mm 0/4] mqueue namespace
Date: Thu, 19 Jun 2008 20:00:51 -0700
Message-ID: <m11w2syfmk.fsf@frodo.ebiederm.org>
References: <20071128163728.177495768@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755137AbYFTDLg@vger.kernel.org>
In-Reply-To: <20071128163728.177495768@fr.ibm.com>> (Cedric Le Goater's
	message of "Wed, 28 Nov 2007 17:37:28 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg@fr.ibm.com> writes:

> Hello ! 
>
> Here's a small patchset introducing a new namespace for POSIX
> message queues. 
>
> Nothing really complex a part from the mqueue filesystem which 
> needed some special care

This looks stalled.  I have a brainstorm that might takes a totally
different perspective on things.

The only reason we don't just allow multiple mounts of mqueuefs to
solve this problem is because there is a kernel syscall on the path.

If we just hard coded a mount point into the kernel and required user
space to always mount mqueuefs there the problem would be solved.

hard coding a mount point is unfortunately violates the unix rule
of separating mechanism and policy.

One way to fix that is to add a hidden directory to the mnt namespace.
Where magic in kernel filesystems can be mounted.  Only visible
with a magic openat flag.  Then:

fd = openat(AT_FDKERN, ".", O_DIRECTORY)
fchdir(fd);
umount("./mqueue", MNT_DETACH);
mount(("none", "./mqueue", "mqueue", 0, NULL);

Would unshare the mqueue namespace.

Implemented for plan9 this would solve a problem of how do you get
access to all of it's special filesystems.  As only bind mounts
and remote filesystem mounts are available.  For linux thinking about
it might shake the conversation up a bit.

Eric
