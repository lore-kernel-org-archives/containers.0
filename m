From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow
	directory	support.
Date: Tue, 31 Jul 2007 01:59:38 -0600
Message-ID: <m1bqdtt34l.fsf@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost>
	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>
	<20070622001328.GA14113@suse.de>
	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>
	<20070625212339.GA13398@kroah.com>
	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>
	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>
	<46A3B449.3090409@gmail.com> <20070722202508.GA18018@suse.de>
	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
	<46A425F9.1030008@gmail.com> <46AD8E92.7080002@suse.de>
	<46ADDC7F.1090306@sw.ru> <46ADE24E.8020502@suse.de>
	<46ADEE35.8000109@sw.ru> <46ADF003.3010100@suse.de>
	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com> <46AEAF79.6080404@suse.de>
	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com> <46AEBA87.6000400@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46AEBA87.6000400-l3A5Bk7waGM@public.gmane.org> (Tejun Heo's message of "Tue, 31 Jul
	2007 13:28:55 +0900")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> What do we use inode->i_mutex for?  I think we might be able
>> to kill that.
>> 
>> I'm starting to wonder if we can completely remove sysfs
>> from grabbing inode->i_mutex.
>
> i_mutex is grabbed when dentry and inode locking requires it.  It's not
> used to protect sysfs internal data structure anymore.  I don't think we
> can remove i_mutex grabbing without violating dentry/inode locking rules.

Not entirely no.  I think we can remove i_mutex from protecting dentry
tree modifications.

>>>> At first glance sysfs_assoc_lock looks just as bad.
>>> I think sysfs_assoc_lock is okay.  It's tricky tho.  Why do you think
>>> it's bad?
>> 
>> I'm still looking.  I just have a weird vibe so far.  sysfs_get_dentry
>> is really nasty with respect to locking.
>
> Yes, sysfs_get_dentry() is pretty hairy.  I wish I could use
> path_lookup() there but can't allocate memory for path name because
> looking up must succeed when it's called from removal path if dentry
> already exists.  Also, lookup_one_len_kern() bypasses security checks
> and there's no equivalent path_lookup() like function which does that.

We can use d_hash_and_lookup and that helps a lot.  I have attached
my in-progress rewrite of sysfs_get_dentry.  It's a little less
efficient but a whole lot easier to maintain.

> Locking rule aruond sysfs_assoc_lock is tricky.  It's mainly used to
> avoid race condition between sysfs_d_iput() vs. dentry creation, node
> removal, etc.  As long as sysfs_assoc_lock is held, sd->s_dentry can be
> dereferenced but you also need dcache_lock to determine whether the
> dentry is alive (dentry->d_inode != NULL) or in the process of being
> killed.  There were two or three race conditions around dentry
> reclamation in the past and several discussion threads about them.

I think I have figured out how to safely remove s_dentry entirely from
sysfs_dirent and that winds up removing a lot of subtle and nasty locking.
I'm hoping to have a good patch series after another couple of hours of
work.

struct dentry *__sysfs_get_dentry(struct sysfs_dirent *sd, int create)
{
	struct sysfs_dirent *cur;
	struct dentry *parent_dentry, *dentry;
	struct qstr name;
	struct inode *inode;

	parent_dentry = NULL;
	dentry = dget(sysfs_sb->s_root);

	do {
		/* Find the first ancestor I have not looked up */
		cur = sd;
		while (cur->s_parent != dentry->d_fsdata)
			cur = cur->s_parent;

		/* look it up */
		dput(parent_dentry);
		parent_dentry = dentry;
		name.name = cur->s_name;
		name.len = strlen(cur->s_name);
		dentry = d_hash_and_lookup(parent_dentry, &name);
		if (dentry)
			continue;
		if (!create)
			goto out;
		dentry = d_alloc(parent_dentry, &name);
		if (!dentry) {
			dentry = ERR_PTR(-ENOMEM);
			goto out;
		}
		inode = sysfs_get_inode(cur);
		if (!inode) {
			dput(dentry);
			dentry = ERR_PTR(-ENOMEM);
			goto out;
		}
		d_instantiate(dentry, inode);
		sysfs_attach_dentry(cur, dentry);
	} while (cur != sd);

out:	
	dput(parent_dentry);
	return dentry;
}

struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
{
	struct dentry *dentry;

	mutex_lock(&sysfs_mutex);
	dentry = __sysfs_get_dentry(sd, 1);
	mutex_unlock(&sysfs_mutex);
	return dentry;
}

Eric
