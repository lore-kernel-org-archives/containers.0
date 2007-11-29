From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 2/4] mqueue namespace : add unshare support
Date: Thu, 29 Nov 2007 02:52:46 -0800
Message-ID: <20071129025246.a0d03eef.akpm@linux-foundation.org>
References: <20071128163728.177495768@fr.ibm.com>
	<20071128164349.196734045@fr.ibm.com>
	<474DA61B.5030301@openvz.org>
	<474E944C.4020809@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761598AbXK2KxJ@vger.kernel.org>
In-Reply-To: <474E944C.4020809@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

On Thu, 29 Nov 2007 11:28:28 +0100 Cedric Le Goater <clg@fr.ibm.com> wrote:

> >> Index: 2.6.24-rc3-mm2/include/linux/sched.h
> >> ===================================================================
> >> --- 2.6.24-rc3-mm2.orig/include/linux/sched.h
> >> +++ 2.6.24-rc3-mm2/include/linux/sched.h
> >> @@ -27,6 +27,7 @@
> >>  #define CLONE_NEWUSER		0x10000000	/* New user namespace */
> >>  #define CLONE_NEWPID		0x20000000	/* New pid namespace */
> >>  #define CLONE_NEWNET		0x40000000	/* New network namespace */
> >> +#define CLONE_NEWMQ		0x80000000	/* New posix mqueue namespace */
> > 
> > That's it :) We've run out of clone flags on 32-bit platforms :(
> 
> yes. 
> 
> I have been giving some thoughts to a clone2() to extend the flags

There appears to be little alternative.

> but
> andrew is preparing to recycle CLONE_DETACHED and CLONE_STOPPED for
> 2.6.26. Some we might have some more time in front of us.

CLONE_DETACHED proved to be in use.  There are no reports of anyone using
CLONE_STOPPED though.
