From: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Tue, 31 Jul 2007 20:34:47 +0900
Message-ID: <46AF1E57.3030209@suse.de>
References: <1182446577.8138.29.camel@localhost>
	<46ADDC7F.1090306@sw.ru>	<46ADE24E.8020502@suse.de>
	<46ADEE35.8000109@sw.ru>	<46ADF003.3010100@suse.de>
	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com>
	<46AEAF79.6080404@suse.de>	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com>
	<46AEBA87.6000400@suse.de>	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com>
	<46AEEF75.2030101@suse.de>	<46AEEFA6.4000901@suse.de>	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>	<46AF15F6.6010202@suse.de>
	<m11weorf3l.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11weorf3l.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
>>> +	do {
>>> +		/* Find the first ancestor I have not looked up */
>>> +		cur = sd;
>>> +		while (cur->s_parent != dentry->d_fsdata)
>>>  			cur = cur->s_parent;
>>>  
>>>  		/* look it up */
>>>  		dput(parent_dentry);
>> Shouldn't this be done after looking up the child?
> Yes and that is what this is.  Delaying it a little longer
> made the conditionals easier to write and verify for correctness.

Right, missed the next line.

>>> +		parent_dentry = dentry;
>>> +		name.name = cur->s_name;
>>> +		name.len = strlen(cur->s_name);
>>> +		dentry = d_hash_and_lookup(parent_dentry, &name);
>>> +		if (dentry)
>>> +			continue;
>>> +		if (!create)
>>> +			goto out;
>> Probably missing dentry = NULL?
> d_hash_and_lookup sets dentry, and we can't get here if (dentry != NULL)

Yes.

>> One thing I'm worried about is that dentry can now be looked up without
>> holding i_mutex.  In sysfs proper, there's no synchronization problem
>> but I'm not sure whether we're willing to cross that line set by vfs.
>> It might come back and bite our asses hard later.
> 
> It's a reasonable concern.  I'm wondering if there are any precedents
> set by distributed filesystems.  Because in a sense that is what
> we are.

Yeah, that's the weird thing about sysfs.  sysfs interface acts as a
different access point to the filesystem making it virtually distributed.

> As for crossing that line I don't know what to say it makes the
> code a lot cleaner, and if we are merged into the kernel at
> least it will be visible if someone rewrites the vfs.
> 
> If sysfs_mutex nested the other way things would be easier,
> and we could grab all of the i_mutexes we wanted.  I wonder if we can
> be annoying in sysfs_lookup and treat that as the lock inversion
> case using mutex_trylock etc.  And have sysfs_mutex be on the
> outside for the rest of the cases?

The problem with treating sysfs_lookup as inversion case is that vfs
layer grabs i_mutex outside of sysfs_lookup.  Releasing i_mutex from
inside sysfs_lookup would be a hacky layering violation.

Then again, the clean up which can come from the new sysfs_looukp_dentry
is very significant.  I'll think about it a bit more.

Thanks.

-- 
tejun
