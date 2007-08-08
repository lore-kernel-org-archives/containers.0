From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 17/25] sysfs: Rewrite rename in terms of sysfs dirents
Date: Wed, 08 Aug 2007 09:32:20 -0600
Message-ID: <m1ejiedou3.fsf@ebiederm.dsl.xmission.com>
References: <m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>
	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>
	<20070808085133.GI13674@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936085AbXHHPdW@vger.kernel.org>
In-Reply-To: <20070808085133.GI13674@htj.dyndns.org> (Tejun Heo's message of
	"Wed, 8 Aug 2007 17:51:33 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

>>  int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
>>  {
>> -	struct sysfs_dirent *sd;
>> +	struct sysfs_dirent *sd = kobj->sd;
>>  	struct dentry *parent = NULL;
>>  	struct dentry *old_dentry = NULL, *new_dentry = NULL;
>>  	const char *dup_name = NULL;
>> @@ -863,42 +863,41 @@ int sysfs_rename_dir(struct kobject * kobj, const char
> *new_name)
>>  
>>  	mutex_lock(&sysfs_rename_mutex);
>>  
>> +	error = 0;
>> +	if (strcmp(sd->s_name, new_name) == 0)
>> +		goto out;	/* nothing to rename */
>> +
>>  	/* get the original dentry */
>>  	old_dentry = sysfs_get_dentry(sd);
>>  	if (IS_ERR(old_dentry)) {
>>  		error = PTR_ERR(old_dentry);
>> +		goto out;
>>  	}
>>  
>>  	parent = old_dentry->d_parent;
>>  
>>  	/* lock parent and get dentry for new name */
>>  	mutex_lock(&parent->d_inode->i_mutex);
>> +	mutex_lock(&sysfs_mutex);
>>  
>> +	error = -EEXIST;
>> +	if (sysfs_find_dirent(sd->s_parent, new_name))
>>  		goto out_unlock;
>>  
>> +	error = -ENOMEM;
>> +	new_dentry = d_alloc_name(parent, new_name);
>> +	if (!new_dentry)
>>  		goto out_unlock;
>>  
>>  	/* rename kobject and sysfs_dirent */
>>  	error = -ENOMEM;
>>  	new_name = dup_name = kstrdup(new_name, GFP_KERNEL);
>>  	if (!new_name)
>> +		goto out_unlock;
>>  
>>  	error = kobject_set_name(kobj, "%s", new_name);
>>  	if (error)
>> +		goto out_unlock;
>>  
>>  	mutex_lock(&sysfs_mutex);
>
> sysfs_mutex is being grabbed twice and unlocked twice later.

Ugh.  That patch was supposed to remove the inner grab and release of
sysfs_mutex.  I guess I somehow failed to move that change all of the
way down to this patch.  #18 gets it right for sysfs_move_dir.  And
#20 fixes it but yes this patch is broken, and will mess up any
git-bisect badly.

So this patch needs to be respun.

Eric
