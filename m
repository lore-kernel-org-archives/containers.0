From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] autofs4 - track uid and gid of last mount requester
Date: Fri, 8 Aug 2008 10:23:22 -0500
Message-ID: <20080808152322.GA16816@us.ibm.com>
References: <20080807114002.4142.30417.stgit@web.messagingengine.com> <20080807114012.4142.83607.stgit@web.messagingengine.com> <20080807134650.a6a51f7d.akpm@linux-foundation.org> <20080807221558.GA27863@us.ibm.com> <1218165228.17093.48.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1218165228.17093.48.camel@raven.themaw.net>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Ian Kent <raven@themaw.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, autofs@linux.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Quoting Ian Kent (raven@themaw.net):
> 
> On Thu, 2008-08-07 at 17:15 -0500, Serge E. Hallyn wrote:
> > Quoting Andrew Morton (akpm@linux-foundation.org):
> > > On Thu, 07 Aug 2008 19:40:14 +0800
> > > Ian Kent <raven@themaw.net> wrote:
> > > 
> > > > Patch to track the uid and gid of the last process to request a mount
> > > > for on an autofs dentry.
> > > 
> > > pet peeve: changelog should not tell the reader that this is a "patch".
> > > Because when someone is reading the changelog in the git repository,
> > > they hopefully already know that.
> > > 
> > > > Signed-off-by: Ian Kent <raven@themaw.net>
> > > > 
> > > > ---
> > > > 
> > > >  fs/autofs4/autofs_i.h |    3 +++
> > > >  fs/autofs4/inode.c    |    2 ++
> > > >  fs/autofs4/waitq.c    |   34 ++++++++++++++++++++++++++++++++++
> > > >  3 files changed, 39 insertions(+), 0 deletions(-)
> > > > 
> > > > 
> > > > diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
> > > > index ea024d8..fa76d18 100644
> > > > --- a/fs/autofs4/autofs_i.h
> > > > +++ b/fs/autofs4/autofs_i.h
> > > > @@ -63,6 +63,9 @@ struct autofs_info {
> > > >  	unsigned long last_used;
> > > >  	atomic_t count;
> > > >  
> > > > +	uid_t uid;
> > > > +	gid_t gid;
> > > > +
> > > >  	mode_t	mode;
> > > >  	size_t	size;
> > > >  
> > > > diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
> > > > index 9ca2d07..9408507 100644
> > > > --- a/fs/autofs4/inode.c
> > > > +++ b/fs/autofs4/inode.c
> > > > @@ -53,6 +53,8 @@ struct autofs_info *autofs4_init_ino(struct autofs_info *ino,
> > > >  		atomic_set(&ino->count, 0);
> > > >  	}
> > > >  
> > > > +	ino->uid = 0;
> > > > +	ino->gid = 0;
> > > >  	ino->mode = mode;
> > > >  	ino->last_used = jiffies;
> > > >  
> > > > diff --git a/fs/autofs4/waitq.c b/fs/autofs4/waitq.c
> > > > index 6d87bb1..7c60c0b 100644
> > > > --- a/fs/autofs4/waitq.c
> > > > +++ b/fs/autofs4/waitq.c
> > > > @@ -457,6 +457,40 @@ int autofs4_wait(struct autofs_sb_info *sbi, struct dentry *dentry,
> > > >  
> > > >  	status = wq->status;
> > > >  
> > > > +	/*
> > > > +	 * For direct and offset mounts we need to track the requestrer
> > > 
> > > typo which I'll fix.
> > > 
> > > > +	 * uid and gid in the dentry info struct. This is so it can be
> > > > +	 * supplied, on request, by the misc device ioctl interface.
> > > > +	 * This is needed during daemon resatart when reconnecting
> > > > +	 * to existing, active, autofs mounts. The uid and gid (and
> > > > +	 * related string values) may be used for macro substitution
> > > > +	 * in autofs mount maps.
> > 
> > Hi Ian,
> > 
> > could you say just a few more words on these macro substitution?
> > 
> > I think your use of uids can completely ignore user namespaces, but it
> > depends on who does the macro substitutions and how...
> 
> Suppose we have an autofs map entry in /etc/auto.master:
> /test   /etc/auto.test
> 
> and in /etc/auto.test
> 
> im1  /om1 server:/dir1 \
>      /om2/$USER server2:/dir2
> 
> Then if this is automounted and the daemon is sent a SIGKILL and started
> again we need the uid number that was used when this was mounted to
> re-construct the offsets (/om2/$USER in this case needs the
> substitution). The uid is used to lookup the user name.

Based on that I can't quite tell whether there is any security property
that could be violated by uid 500 'tricking' the autofs daemon into
doing something for uid 0.  It sounds like it could be annoying but
not a security violation?

> Can you point me in the right direction wrt. to namespaces on this
> please Serge? We didn't really get to the bottom of it last time I
> think.

Well user namespaces are still being implemented, in fact at some level
still being designed.  So it doesn't hurt to consider the right thing
to do right off the bat, but unlike the pid namespaces this really shouldn't
be hurting anyone right now.

User namespaces will be hierarchical - like pid namespaces, except
somewhat differently.  If user 500 in userns 0 creates a new user
namespace, then each userid in the new user namespace is also
'owned' by (500,0).  Our hope is that we can make the userns
core such that unprivileged users can safely unshare a new pid
namespace.  So for that reason, I suspect we'll want to handle
user namespace much like I just suggested handling pid namespaces.

1. For each 'system container', that is, a process set with its
own network stack, its own devices, etc, we'll want separate
autofs daemons.  That's simple enough - apart from determining
what qualifies as a 'system container'.  Here I think that will
depend on how autofs talks to the userspace daemon, and what
needs to be isolated in order to prevent a surreptitious admin
in one system container from having its autofs daemon talk to
another.

2. Within a system container, I think we'll want the autofs
daemon to store a pointer to its user namespace.  When an
autofs4_wait happens, the wq uses the full current->user
to look up the task's uid within the autofs daemon's own user
namespace, and it uses for macro expansions.

That prevents unprivileged user hallyn from creating a new
user namespace and trying to fool autofs into expanding
macros for uid 0.

Note that certainly for now and probably a long time coming,
you do need privilege to clone(CLONE_NEWUSER) so this isn't
urgent.

thanks,
-serge
