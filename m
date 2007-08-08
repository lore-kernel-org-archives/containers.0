From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/25] sysfs: Introduce sysfs_rename_mutex
Date: Wed, 08 Aug 2007 02:28:52 -0600
Message-ID: <m13ayufn0b.fsf@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com>
	<m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>
	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<46B97C94.8090209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761464AbXHHIbh@vger.kernel.org>
In-Reply-To: <46B97C94.8090209@gmail.com> (Tejun Heo's message of "Wed, 08 Aug
	2007 17:19:32 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

> Hello, Eric.
>
> Eric W. Biederman wrote:
>> Looking carefully at the rename code we have a subtle dependency
>> that the structure of sysfs not change while we are performing
>> a rename.  If the parent directory of the object we are renaming
>> changes while the rename is being performed nasty things could
>> happen when we go to release our locks.
>> 
>> So introduce a sysfs_rename_mutex to prevent this highly
>> unlikely theoretical issue.
>
> Yeah, it's a theoretical issue.  Rename/move implementation has always
> depended on the parent structure not changing beneath it, but it's nice
> to tighten up loose ends.
>
>> +DEFINE_MUTEX(sysfs_rename_mutex);
>
> Probably doesn't really matter but wouldn't a rwsem fit better?

Maybe.  I didn't feel any loss in when I was writing the code.
Very few code paths actually seem to care.

>> @@ -774,7 +775,7 @@ static struct dentry *__sysfs_get_dentry(struct
> super_block *sb, struct sysfs_di
>>   *	down from there looking up dentry for each step.
>>   *
>>   *	LOCKING:
>> - *	Kernel thread context (may sleep)
>> + *	mutex_lock(sysfs_rename_mutex)

Well this is weird in that it should be on sysfs_get_dentry
more then __sysfs_get_dentry but otherwise it's ok.

> LOCKING describes what locks should be held when entering the function,
> so proper description would be something like...
>
> 	Kernel thread context, grabs sysfs_rename_mutex

For rename_dir and move_dir yes.  I was updating the rules
for sysfs_get_dentry.  Which really wants it's parents to
hold that lock.

Eric
