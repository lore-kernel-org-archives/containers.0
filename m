From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Tue, 31 Jul 2007 05:23:58 -0600
Message-ID: <m11weorf3l.fsf@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost> <46ADDC7F.1090306@sw.ru>
	<46ADE24E.8020502@suse.de> <46ADEE35.8000109@sw.ru>
	<46ADF003.3010100@suse.de> <m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com> <46AEAF79.6080404@suse.de>
	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com> <46AEBA87.6000400@suse.de>
	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com> <46AEEF75.2030101@suse.de>
	<46AEEFA6.4000901@suse.de>
	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
	<46AF15F6.6010202@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46AF15F6.6010202-l3A5Bk7waGM@public.gmane.org> (Tejun Heo's message of "Tue, 31 Jul
	2007 19:59:02 +0900")
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
>> Currently sysfs_get_dentry is very hairy and requires all kinds
>> of locking magic.  This patch rewrites sysfs_get_dentry to
>> not use the cached sd->s_dentry, and instead simply lookup
>> and create dcache entries.
>
> I wanted to kill sd->s_dentry from the beginning.  The obstacle was
> actually the shadow directory support, ironic.
>
>> +	struct qstr name;
>> +	struct inode *inode;
>>  
>> +	parent_dentry = NULL;
>> +	dentry = dget(sysfs_sb->s_root);
>>  
>> +	do {
>> +		/* Find the first ancestor I have not looked up */
>> +		cur = sd;
>> +		while (cur->s_parent != dentry->d_fsdata)
>>  			cur = cur->s_parent;
>>  
>>  		/* look it up */
>>  		dput(parent_dentry);
>
> Shouldn't this be done after looking up the child?
Yes and that is what this is.  Delaying it a little longer
made the conditionals easier to write and verify for correctness.

>> +		parent_dentry = dentry;
>> +		name.name = cur->s_name;
>> +		name.len = strlen(cur->s_name);
>> +		dentry = d_hash_and_lookup(parent_dentry, &name);
>> +		if (dentry)
>> +			continue;
>> +		if (!create)
>> +			goto out;
>
> Probably missing dentry = NULL?
d_hash_and_lookup sets dentry, and we can't get here if (dentry != NULL)

>> +		dentry = d_alloc(parent_dentry, &name);
>> +		if (!dentry) {
>> +			dentry = ERR_PTR(-ENOMEM);
>> +			goto out;
>>  		}
>> +		inode = sysfs_get_inode(cur);
>> +		if (!inode) {
>>  			dput(dentry);
>> +			dentry = ERR_PTR(-ENOMEM);
>> +			goto out;
>>  		}
>> +		d_instantiate(dentry, inode);
>> +		sysfs_attach_dentry(cur, dentry);
>> +	} while (cur != sd);
>>  
>> +out:
>> +	dput(parent_dentry);
>> +	return dentry;
>> +}
>>  
>> @@ -750,6 +725,12 @@ static struct dentry * sysfs_lookup(struct inode *dir,
> struct dentry *dentry,
>>  	struct inode *inode;
>>  
>>  	mutex_lock(&sysfs_mutex);
>> +
>> +	/* Guard against races with sysfs_get_dentry */
>> +	result = d_hash_and_lookup(dentry->d_parent, &dentry->d_name);
>> +	if (result)
>> +		goto out;
>> +
>
> Hmmm... This is tricky but probably better than the previous hairy
> sysfs_get_dentry().  I think it would be worthwhile to comment about
> creating dentry/inode behind vfs's back in __sysfs_get_dentry().

Yes. Good point.  That is sufficiently non-intuitive and non-obvious
to deserve a comment.

> One thing I'm worried about is that dentry can now be looked up without
> holding i_mutex.  In sysfs proper, there's no synchronization problem
> but I'm not sure whether we're willing to cross that line set by vfs.
> It might come back and bite our asses hard later.

It's a reasonable concern.  I'm wondering if there are any precedents
set by distributed filesystems.  Because in a sense that is what
we are.

As for crossing that line I don't know what to say it makes the
code a lot cleaner, and if we are merged into the kernel at
least it will be visible if someone rewrites the vfs.

If sysfs_mutex nested the other way things would be easier,
and we could grab all of the i_mutexes we wanted.  I wonder if we can
be annoying in sysfs_lookup and treat that as the lock inversion
case using mutex_trylock etc.  And have sysfs_mutex be on the
outside for the rest of the cases?

Anyway back to bed with me.  I've been dreaming up to many silly
ways to abuse the dcache...

Eric
