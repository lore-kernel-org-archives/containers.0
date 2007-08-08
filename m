From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 20/25] sysfs: Rename Support multiple superblocks
Date: Thu, 09 Aug 2007 00:50:56 +0900
Message-ID: <46B9E660.6030702@gmail.com>
References: <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>	<m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>	<m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com>	<20070808093505.GL13674@htj.dyndns.org> <m1643qdo7e.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755899AbXHHPvY@vger.kernel.org>
In-Reply-To: <m1643qdo7e.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Welcome.  I will see what I can do with respect to cleaning up
> the names.
> 
> As for the return value of sysfs_get_dentry that is tricky.  In particular
> I have three specific cases the code needs to deal with.
> 
> - We got the dentry.
> - We did not get the dentry because for this super block there never
>   ever will be a dentry.
> - Some kind of error occurred in attempting to get the dentry.
> 
> Not getting a dentry because it is impossible I am currently handling
> with a NULL return.  I can equally use a specific error code to mean
> that as well.  It doesn't much matter.  So I guess the hunk in
> question could read:
> 
>>> +	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
>>> +		dentry = sysfs_get_dentry(sb, sd);
>>> +		if (dentry == ERR_PTR(-ENOENT))
>>> +			continue;
> 
> As long as we handle that class of error differently I really don't
> care.

Yeah, I think using -ENOENT is better; otherwise, my little head feels
like exploding.  :-)  More importantly, sysfs_get_dentry() seems like it
would deference ERR_PTR() value.  No?

-- 
tejun
