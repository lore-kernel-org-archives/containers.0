From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 20/25] sysfs: Rename Support multiple superblocks
Date: Wed, 08 Aug 2007 10:35:38 -0600
Message-ID: <m1lkcmc7c5.fsf@ebiederm.dsl.xmission.com>
References: <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com>
	<20070808093505.GL13674@htj.dyndns.org>
	<m1643qdo7e.fsf@ebiederm.dsl.xmission.com>
	<46B9E660.6030702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46B9E660.6030702-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Tejun Heo's message of "Thu, 09 Aug
	2007 00:50:56 +0900")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Yeah, I think using -ENOENT is better; otherwise, my little head feels
> like exploding.  :-)  

Ok.  I think I know the feeling.

> More importantly, sysfs_get_dentry() seems like it
> would deference ERR_PTR() value.  No?

I'm confused where you are referring to but I will try answer
this.

__sysfs_get_dentry always returns a dentry or NULL if it can't
find the dentry.


I have quoted my final version of sysfs_get_dentry below for discussion.

> struct dentry *sysfs_get_dentry(struct super_block *sb, struct sysfs_dirent *sd)
> {
> 	struct sysfs_dirent *cur;
> 	struct dentry *parent_dentry, *dentry;
> 
> 	/* Bail if this sd won't show up in this superblock */
> 	if (sd->s_parent && sd->s_parent->s_flags & SYSFS_FLAG_TAGGED) {
> 		const void *tag;
> 		tag = sysfs_lookup_tag(sd->s_parent, sb);
> 		if (sd->s_tag.tag != tag)
> 			return NULL;
> 	}

This is the only location where could return NULL the early check
if this operation is possible.

> 	/* Find the first parent which has valid dentry.
> 	 */
> 	dentry = NULL;
> 	cur = sd;
> 	while (!(dentry = __sysfs_get_dentry(sb, cur))) {
> 		if (cur->s_flags & SYSFS_FLAG_REMOVED) {
> 			dentry = ERR_PTR(-ENOENT);
> 			break;
> 		}
> 		cur = cur->s_parent;
> 	}

Here we depend on the fact that sysfs_root is pointed to
by sb->s_root so we know it will always have a dentry.

> 	/* from the found dentry, look up depth times */
> 	while (dentry->d_fsdata != sd) {
> 		/* Find the first ancestor I have not looked up */
> 		cur = sd;
> 		while (cur->s_parent != dentry->d_fsdata)
> 			cur = cur->s_parent;
> 
> 		/* look it up */
> 		parent_dentry = dentry;
> 		dentry = sysfs_add_dentry(parent_dentry, cur);
> 		dput(parent_dentry);
> 
> 		if (IS_ERR(dentry))
> 			break;
> 	}
> 	return dentry;
> }

Eric
