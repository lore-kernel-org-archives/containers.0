From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH resend] vfs: Add ->statfs callback for pipefs
Date: Wed, 24 Aug 2011 12:30:50 +0400
Message-ID: <20110824083050.GI29452@sun>
References: <20110824080924.GG29452@sun>
 <20110824012328.f7bfc68a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110824012328.f7bfc68a.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 24, 2011 at 01:23:28AM -0700, Andrew Morton wrote:
> On Wed, 24 Aug 2011 12:09:24 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > From: Pavel Emelyanov <xemul@parallels.com>
> > 
> > This is done to make it possible to distinguish pipes
> > from fifos when opening one via /proc/<pid>/fd/ link.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> > Reviewed-by: Tejun Heo <tj@kernel.org>
> > Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> > ---
> >  fs/pipe.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > Any objections to this one? It was a part of a patchset
> > but can be treated independently so I'm re-sending it alone.
> > 
> > Index: linux-2.6.git/fs/pipe.c
> > ===================================================================
> > --- linux-2.6.git.orig/fs/pipe.c
> > +++ linux-2.6.git/fs/pipe.c
> > @@ -1254,6 +1254,7 @@ out:
> >  
> >  static const struct super_operations pipefs_ops = {
> >  	.destroy_inode = free_inode_nonrcu,
> > +	.statfs = simple_statfs,
> >  };
> >  
> >  /*
> 
> OK, I give up - how does it work?
> 
> <goes off and reads the kernel>
> 
> So it appears that the statfs call would previously return -ENOSYS, but
> with this change the statfs will succeed and userspace can then inspect
> f_type.  Yes?  I will fix your changelog by adding a description along these
> lines.

Yes, it allows to distinguish pipes from anything else. Initially this patch was
a part of early rfc on checkpoint/restore facility (mostly implemented in
userspace). So we need to distinguish somehow pipes when we dump data from
/proc/pid/fd. That's the main reason. BUT since this patch can be used without
any other c/r bits and can be treated separately I've sent it alone without
any mention of c/r at all.

> 
> And I'll ask you to fix it further by telling us why we want to do
> this?  The kernel has had this issue for a long time - why does it now
> matter?

	Cyrill
