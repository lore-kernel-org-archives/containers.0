From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 20/25] sysfs: Rename Support multiple superblocks
Date: Thu, 09 Aug 2007 01:42:03 +0900
Message-ID: <46B9F25B.6020804@gmail.com>
References: <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>	<m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>	<m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com>	<20070808093505.GL13674@htj.dyndns.org>	<m1643qdo7e.fsf@ebiederm.dsl.xmission.com>	<46B9E660.6030702@gmail.com> <m1lkcmc7c5.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936502AbXHHQmY@vger.kernel.org>
In-Reply-To: <m1lkcmc7c5.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
>> 	/* Find the first parent which has valid dentry.
>> 	 */
>> 	dentry = NULL;
>> 	cur = sd;
>> 	while (!(dentry = __sysfs_get_dentry(sb, cur))) {
>> 		if (cur->s_flags & SYSFS_FLAG_REMOVED) {
>> 			dentry = ERR_PTR(-ENOENT);
>> 			break;
>> 		}
>> 		cur = cur->s_parent;
>> 	}
> 
> Here we depend on the fact that sysfs_root is pointed to
> by sb->s_root so we know it will always have a dentry.

Hmmm... dentry could be ERR_PTR(-ENOENT) here if the REMOVED flag test
succeeded, right?

>> 	/* from the found dentry, look up depth times */
>> 	while (dentry->d_fsdata != sd) {

And then dereferenced.  The REMOVED test should never succeed there, so
we're probably in the clear but still the code looks a bit scary.

-- 
tejun
