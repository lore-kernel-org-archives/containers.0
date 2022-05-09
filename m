Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FAEA1865
	for <containers@lists.linux.dev>; Mon,  9 May 2022 20:36:20 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id 3A8D89E3; Mon,  9 May 2022 15:36:18 -0500 (CDT)
Date: Mon, 9 May 2022 15:36:18 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org,
	zohar@linux.ibm.com, christian.brauner@ubuntu.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	jpenumak@redhat.com, Christian Brauner <brauner@kernel.org>,
	John Johansen <john.johansen@canonical.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Micah Morton <mortonm@chromium.org>,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	Jarkko Sakkinen <jarkko@kernel.org>
Subject: Re: [PATCH v12 01/26] securityfs: rework dentry creation
Message-ID: <20220509203618.GA31408@mail.hallyn.com>
References: <20220420140633.753772-1-stefanb@linux.ibm.com>
 <20220420140633.753772-2-stefanb@linux.ibm.com>
 <20220509195414.GA30894@mail.hallyn.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220509195414.GA30894@mail.hallyn.com>
User-Agent: Mutt/1.9.4 (2018-02-28)

On Mon, May 09, 2022 at 02:54:14PM -0500, Serge E. Hallyn wrote:
> On Wed, Apr 20, 2022 at 10:06:08AM -0400, Stefan Berger wrote:
> > From: Christian Brauner <brauner@kernel.org>
> > 
> > When securityfs creates a new file or directory via
> > securityfs_create_dentry() it will take an additional reference on the
> > newly created dentry after it has attached the new inode to the new
> > dentry and added it to the hashqueues.
> > If we contrast this with debugfs which has the same underlying logic as
> > securityfs. It uses a similar pairing as securityfs. Where securityfs
> > has the securityfs_create_dentry() and securityfs_remove() pairing,
> > debugfs has the __debugfs_create_file() and debugfs_remove() pairing.
> > 
> > In contrast to securityfs, debugfs doesn't take an additional reference
> > on the newly created dentry in __debugfs_create_file() which would need
> > to be put in debugfs_remove().
> > 
> > The additional dget() isn't a problem per se. In the current
> > implementation of securityfs each created dentry pins the filesystem via
> 
> Is 'via' an extra word here or is there a missing word?
> 
> I'll delay the rest of my response as the missing word may answer my
> remaining question :)
> 
> > until it is removed. Since it is virtually guaranteed that there is at
> > least one user of securityfs that has created dentries the initial
> > securityfs mount cannot go away until all dentries have been removed.
> > 
> > Since most of the users of the initial securityfs mount don't go away
> > until the system is shutdown the initial securityfs won't go away when
> > unmounted. Instead a mount will usually surface the same superblock as
> > before. The additional dget() doesn't matter in this scenario since it
> > is required that all dentries have been cleaned up by the respective
> > users before the superblock can be destroyed, i.e. superblock shutdown
> > is tied to the lifetime of the associated dentries.
> > 
> > However, in order to support ima namespaces we need to extend securityfs
> > to support being mounted outside of the initial user namespace. For
> > namespaced users the pinning logic doesn't make sense. Whereas in the
> > initial namespace the securityfs instance and the associated data
> > structures of its users can't go away for reason explained earlier users
> > of non-initial securityfs instances do go away when the last users of
> > the namespace are gone.
> > 
> > So for those users we neither want to duplicate the pinning logic nor
> > make the global securityfs instance display different information based
> > on the namespace. Both options would be really messy and hacky.
> > 
> > Instead we will simply give each namespace its own securityfs instance
> > similar to how each ipc namespace has its own mqueue instance and all
> > entries in there are cleaned up on umount or when the last user of the
> > associated namespace is gone.
> > 
> > This means that the superblock's lifetime isn't tied to the dentries.
> > Instead the last umount, without any fds kept open, will trigger a clean
> > shutdown. But now the additional dget() gets in the way. Instead of
> > being able to rely on the generic superblock shutdown logic we would
> > need to drop the additional dentry reference during superblock shutdown
> > for all associated users. That would force the use of a generic
> > coordination mechanism for current and future users of securityfs which
> > is unnecessary. Simply remove the additional dget() in
> > securityfs_dentry_create().
> > 
> > In securityfs_remove() we will call dget() to take an additional
> > reference on the dentry about to be removed. After simple_unlink() or
> > simple_rmdir() have dropped the dentry refcount we can call d_delete()
> > which will either turn the dentry into negative dentry if our earlier
> > dget() is the only reference to the dentry, i.e. it has no other users,
> > or remove it from the hashqueues in case there are additional users.
> > 
> > All of these changes should not have any effect on the userspace
> > semantics of the initial securityfs mount.
> > 
> > Signed-off-by: Christian Brauner <brauner@kernel.org>
> > Cc: John Johansen <john.johansen@canonical.com>
> > Cc: Matthew Garrett <mjg59@srcf.ucam.org>
> > Cc: Micah Morton <mortonm@chromium.org>
> > Cc: Kentaro Takeda <takedakn@nttdata.co.jp>
> > Cc: James Morris <jmorris@namei.org>
> > Cc: Jarkko Sakkinen <jarkko@kernel.org>
> > Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> > Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>
> > ---
> >  security/inode.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/security/inode.c b/security/inode.c
> > index 6c326939750d..13e6780c4444 100644
> > --- a/security/inode.c
> > +++ b/security/inode.c
> > @@ -159,7 +159,6 @@ static struct dentry *securityfs_create_dentry(const char *name, umode_t mode,
> >  		inode->i_fop = fops;
> >  	}
> >  	d_instantiate(dentry, inode);
> > -	dget(dentry);
> >  	inode_unlock(dir);
> >  	return dentry;
> >  
> > @@ -302,10 +301,12 @@ void securityfs_remove(struct dentry *dentry)
> >  	dir = d_inode(dentry->d_parent);
> >  	inode_lock(dir);
> >  	if (simple_positive(dentry)) {
> > +		dget(dentry);
> >  		if (d_is_dir(dentry))
> >  			simple_rmdir(dir, dentry);

Hm, so I realize your patch isn't introducing this, but is the
fact that we ignore the possible -ENOTEMPTY return value of
simple_rmdir() not a problem?

> >  		else
> >  			simple_unlink(dir, dentry);
> > +		d_delete(dentry);

I'm mostly trying to convince myself that the fact that there is not
a matching dput being removed (to match the dget being removed above)
is ok.  I do think it is, but that belief seems to dictate that right
now dentries must never be being released.

Otherwise, it seems like there must be cases where the next dput could
be called on a dentry that has been freed.

> >  		dput(dentry);
> >  	}
> >  	inode_unlock(dir);
> > -- 
> > 2.34.1
