From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 20/25] sysfs: Rename Support multiple superblocks
Date: Wed, 08 Aug 2007 09:45:57 -0600
Message-ID: <m1643qdo7e.fsf@ebiederm.dsl.xmission.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760624AbXHHPxW@vger.kernel.org>
In-Reply-To: <20070808093505.GL13674@htj.dyndns.org> (Tejun Heo's message of
	"Wed, 8 Aug 2007 18:35:05 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

>> +{
>> +	struct sysfs_rename_struct *srs;
>> +	struct super_block *sb;
>> +	struct dentry *dentry;
>> +	int error;
>> +
>> +	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
>> +		dentry = sysfs_get_dentry(sb, sd);
>> +		if (!dentry)
>> +			continue;
>
> sysfs_get_dentry() return ERR_PTR() value.  Oops, sysfs_get_dentry()
> implementation is wrong too.  Also, please move
> sysfs_grab/release_supers() near this patch and add (a lot of)
> comments there.
>
> Other than that, I think this is as clean as this can be.  Great.

Welcome.  I will see what I can do with respect to cleaning up
the names.

As for the return value of sysfs_get_dentry that is tricky.  In particular
I have three specific cases the code needs to deal with.

- We got the dentry.
- We did not get the dentry because for this super block there never
  ever will be a dentry.
- Some kind of error occurred in attempting to get the dentry.

Not getting a dentry because it is impossible I am currently handling
with a NULL return.  I can equally use a specific error code to mean
that as well.  It doesn't much matter.  So I guess the hunk in
question could read:

>> +	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
>> +		dentry = sysfs_get_dentry(sb, sd);
>> +		if (dentry == ERR_PTR(-ENOENT))
>> +			continue;

As long as we handle that class of error differently I really don't
care.

Eric
