From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [cgroup or VFS ?]  WARNING: at fs/namespace.c:636	mntput_no_expire+0xac/0xf2()
Date: Tue, 10 Feb 2009 13:47:40 +0800
Message-ID: <499114FC.6090307@cn.fujitsu.com>
References: <49617D35.4040805@cn.fujitsu.com> <20090209004046.3ce1dde0.akpm@linux-foundation.org> <498FEE24.5030407@cn.fujitsu.com> <20090209110348.GV28946@ZenIV.linux.org.uk> <20090209115818.GX28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753420AbZBJFsZ@vger.kernel.org>
In-Reply-To: <20090209115818.GX28946@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, containers@lists.osdl.org, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

Al Viro wrote:
> On Mon, Feb 09, 2009 at 11:03:48AM +0000, Al Viro wrote:
>> 	BTW, a trivial note - kfree(root) in your ->kill_sb() is done
>> earlier than it's nice to do.  Shouldn't affect the problem, though.
> 

Do you mean kfree(root) should be called after kill_litter_super()?
I don't see the point here..

> 	Other probably irrelevant notes:
> 
>                 memcpy(start, cgrp->dentry->d_name.name, len);
>                 cgrp = cgrp->parent;
>                 if (!cgrp)
>                         break;
>                 dentry = rcu_dereference(cgrp->dentry);
> 
> in cgroup_path().  Why don't we need rcu_dereference on both?
> Moreover, shouldn't that be
>                 memcpy(start, dentry->d_name.name, len);
> anyway, seeing that we'd just looked at dentry->d_name.len?

We are right, dentry-> but not cgrp->dentry-> should be used.

> 
> In cgroup_rmdir():
>         spin_lock(&cgrp->dentry->d_lock);
>         d = dget(cgrp->dentry);
>         spin_unlock(&d->d_lock);
> 
>         cgroup_d_remove_dir(d);
>         dput(d);
> Er?  Comments, please...  Unless something very unusual is going on,
> either that d_lock is pointless or dget() is rather unsafe.
> 

The code was inherited from cpuset. I doubted it's redundant, but
I was not confident enough to remove it.

> cgroups_clone()
>         /* Now do the VFS work to create a cgroup */
>         inode = parent->dentry->d_inode;
> 
>         /* Hold the parent directory mutex across this operation to
>          * stop anyone else deleting the new cgroup */
>         mutex_lock(&inode->i_mutex);
> Can the parent be in process of getting deleted by somebody else?  If yes,
> we are in trouble here.
> 
> BTW, that thing in cgroup_path()...  What guarantees that cgroup_rename()
> won't hit between getting len and doing memcpy()?
> 

cgroup_path() was inherited from cpuset's cpuset_path(), and I think it's
true it races with rename.

> That said, cgroup seems to be completely agnostic wrt anything happening
> on vfsmount level, so I really don't see how it gets to that WARN_ON().
> Hell knows; I really want to see the sequence of events - it might be
> something like fscking up ->s_active handling with interesting results
> (cgroup code is certainly hitting it in not quite usual ways), it may be
> genuine VFS-only race.  Need more data...
> 
