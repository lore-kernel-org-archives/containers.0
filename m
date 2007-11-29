From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [patch -mm 2/4] mqueue namespace : add unshare support
Date: Thu, 29 Nov 2007 07:57:28 -0600
Message-ID: <20071129135727.GA3343@sergelap.austin.ibm.com>
References: <20071128163728.177495768@fr.ibm.com> <20071128164349.196734045@fr.ibm.com> <474DA61B.5030301@openvz.org> <474E944C.4020809@fr.ibm.com> <20071129025246.a0d03eef.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932135AbXK2N6O@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071129025246.a0d03eef.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cedric Le Goater <clg@fr.ibm.com>, Linux Containers <containers@lists.osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Thu, 29 Nov 2007 11:28:28 +0100 Cedric Le Goater <clg@fr.ibm.com> wrote:
> 
> > >> Index: 2.6.24-rc3-mm2/include/linux/sched.h
> > >> ===================================================================
> > >> --- 2.6.24-rc3-mm2.orig/include/linux/sched.h
> > >> +++ 2.6.24-rc3-mm2/include/linux/sched.h
> > >> @@ -27,6 +27,7 @@
> > >>  #define CLONE_NEWUSER		0x10000000	/* New user namespace */
> > >>  #define CLONE_NEWPID		0x20000000	/* New pid namespace */
> > >>  #define CLONE_NEWNET		0x40000000	/* New network namespace */
> > >> +#define CLONE_NEWMQ		0x80000000	/* New posix mqueue namespace */
> > > 
> > > That's it :) We've run out of clone flags on 32-bit platforms :(
> > 
> > yes. 
> > 
> > I have been giving some thoughts to a clone2() to extend the flags
> 
> There appears to be little alternative.

Just thinking aloud, but

given the concerns with the safety and sanity of unsharing only partial
namespaces, and before much userspace is depending on any of
	CLONE_NEWUTS,CLONE_NEWIPC,CLONE_NEWUSER,CLONE_NEWNET,CLONE_NEWMQUEUE

maybe we should have traditional clone only support CLONE_NEWNS (since
it's the most useful on its own) and CLONE_NEWCONTAINER, where
CLONE_NEWCONTAINER always unshares all the namespaces we know about.

Then clone2 can allow more finegrained choice of namespaces.  It takes
the exact same clone_flags as clone(), but instead of parent_tidptr
and child_tidptr args it has a ns_unshare flag which specifies which
namespaces to unshare.

-serge

> > but
> > andrew is preparing to recycle CLONE_DETACHED and CLONE_STOPPED for
> > 2.6.26. Some we might have some more time in front of us.
> 
> CLONE_DETACHED proved to be in use.  There are no reports of anyone using
> CLONE_STOPPED though.
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
