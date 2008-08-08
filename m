From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 2/4] autofs4 - track uid and gid of last mount requester
Date: Fri, 08 Aug 2008 11:13:47 +0800
Message-ID: <1218165228.17093.48.camel@raven.themaw.net>
References: <20080807114002.4142.30417.stgit@web.messagingengine.com>
	 <20080807114012.4142.83607.stgit@web.messagingengine.com>
	 <20080807134650.a6a51f7d.akpm@linux-foundation.org>
	 <20080807221558.GA27863@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080807221558.GA27863@us.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, autofs@linux.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org


On Thu, 2008-08-07 at 17:15 -0500, Serge E. Hallyn wrote:
> Quoting Andrew Morton (akpm@linux-foundation.org):
> > On Thu, 07 Aug 2008 19:40:14 +0800
> > Ian Kent <raven@themaw.net> wrote:
> > 
> > > Patch to track the uid and gid of the last process to request a mount
> > > for on an autofs dentry.
> > 
> > pet peeve: changelog should not tell the reader that this is a "patch".
> > Because when someone is reading the changelog in the git repository,
> > they hopefully already know that.
> > 
> > > Signed-off-by: Ian Kent <raven@themaw.net>
> > > 
> > > ---
> > > 
> > >  fs/autofs4/autofs_i.h |    3 +++
> > >  fs/autofs4/inode.c    |    2 ++
> > >  fs/autofs4/waitq.c    |   34 ++++++++++++++++++++++++++++++++++
> > >  3 files changed, 39 insertions(+), 0 deletions(-)
> > > 
> > > 
> > > diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
> > > index ea024d8..fa76d18 100644
> > > --- a/fs/autofs4/autofs_i.h
> > > +++ b/fs/autofs4/autofs_i.h
> > > @@ -63,6 +63,9 @@ struct autofs_info {
> > >  	unsigned long last_used;
> > >  	atomic_t count;
> > >  
> > > +	uid_t uid;
> > > +	gid_t gid;
> > > +
> > >  	mode_t	mode;
> > >  	size_t	size;
> > >  
> > > diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
> > > index 9ca2d07..9408507 100644
> > > --- a/fs/autofs4/inode.c
> > > +++ b/fs/autofs4/inode.c
> > > @@ -53,6 +53,8 @@ struct autofs_info *autofs4_init_ino(struct autofs_info *ino,
> > >  		atomic_set(&ino->count, 0);
> > >  	}
> > >  
> > > +	ino->uid = 0;
> > > +	ino->gid = 0;
> > >  	ino->mode = mode;
> > >  	ino->last_used = jiffies;
> > >  
> > > diff --git a/fs/autofs4/waitq.c b/fs/autofs4/waitq.c
> > > index 6d87bb1..7c60c0b 100644
> > > --- a/fs/autofs4/waitq.c
> > > +++ b/fs/autofs4/waitq.c
> > > @@ -457,6 +457,40 @@ int autofs4_wait(struct autofs_sb_info *sbi, struct dentry *dentry,
> > >  
> > >  	status = wq->status;
> > >  
> > > +	/*
> > > +	 * For direct and offset mounts we need to track the requestrer
> > 
> > typo which I'll fix.
> > 
> > > +	 * uid and gid in the dentry info struct. This is so it can be
> > > +	 * supplied, on request, by the misc device ioctl interface.
> > > +	 * This is needed during daemon resatart when reconnecting
> > > +	 * to existing, active, autofs mounts. The uid and gid (and
> > > +	 * related string values) may be used for macro substitution
> > > +	 * in autofs mount maps.
> 
> Hi Ian,
> 
> could you say just a few more words on these macro substitution?
> 
> I think your use of uids can completely ignore user namespaces, but it
> depends on who does the macro substitutions and how...

Suppose we have an autofs map entry in /etc/auto.master:
/test   /etc/auto.test

and in /etc/auto.test

im1  /om1 server:/dir1 \
     /om2/$USER server2:/dir2

Then if this is automounted and the daemon is sent a SIGKILL and started
again we need the uid number that was used when this was mounted to
re-construct the offsets (/om2/$USER in this case needs the
substitution). The uid is used to lookup the user name.

Can you point me in the right direction wrt. to namespaces on this
please Serge? We didn't really get to the bottom of it last time I
think.

> 
> thanks,
> -serge
> 
> > > +	 */
> > > +	if (!status) {
> > > +		struct autofs_info *ino;
> > > +		struct dentry *de = NULL;
> > > +
> > > +		/* direct mount or browsable map */
> > > +		ino = autofs4_dentry_ino(dentry);
> > > +		if (!ino) {
> > > +			/* If not lookup actual dentry used */
> > > +			de = d_lookup(dentry->d_parent, &dentry->d_name);
> > > +			if (de)
> > > +				ino = autofs4_dentry_ino(de);
> > > +		}
> > > +
> > > +		/* Set mount requester */
> > > +		if (ino) {
> > > +			spin_lock(&sbi->fs_lock);
> > > +			ino->uid = wq->uid;
> > > +			ino->gid = wq->gid;
> > > +			spin_unlock(&sbi->fs_lock);
> > > +		}
> > > +
> > > +		if (de)
> > > +			dput(de);
> > > +	}
> > > +
> > 
> > Please remind me again why autofs's use of current->uid and
> > current->gid is not busted in the presence of PID namespaces, where
> > these things are no longer system-wide unique?
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

