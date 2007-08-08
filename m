From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 19/25] sysfs: sysfs_get_dentry add a sb parameter
Date: Wed, 08 Aug 2007 09:34:27 -0600
Message-ID: <m1abt2doqk.fsf@ebiederm.dsl.xmission.com>
References: <m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>
	<20070808085703.GK13674@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757473AbXHHPf2@vger.kernel.org>
In-Reply-To: <20070808085703.GK13674@htj.dyndns.org> (Tejun Heo's message of
	"Wed, 8 Aug 2007 17:57:03 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

> On Tue, Aug 07, 2007 at 03:29:23PM -0600, Eric W. Biederman wrote:
>> 
>> In preparation for multiple mounts of sysfs add a superblock parameter to
>> sysfs_get_dentry.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> @@ -827,7 +829,7 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
>>  	 */
>>  	dentry = NULL;
>>  	cur = sd;
>> -	while (!(dentry = __sysfs_get_dentry(sysfs_sb, cur))) {
>> +	while (!(dentry = __sysfs_get_dentry(sb, cur))) {
>
> It's probably better to add @sb to __sysfs_get_dentry() here too.
> That will make things look clearer.

A little.

I just wanted to be certain I was testing the final __sysfs_get_dentry
logic as soon as I could.


Eric
