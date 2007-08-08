From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 19/25] sysfs: sysfs_get_dentry add a sb parameter
Date: Wed, 8 Aug 2007 17:57:03 +0900
Message-ID: <20070808085703.GK13674@htj.dyndns.org>
References: <m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com> <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com> <m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com> <m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com> <m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com> <m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com> <m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com> <m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com> <m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com> <m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764332AbXHHI5V@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:29:23PM -0600, Eric W. Biederman wrote:
> 
> In preparation for multiple mounts of sysfs add a superblock parameter to
> sysfs_get_dentry.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> @@ -827,7 +829,7 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
>  	 */
>  	dentry = NULL;
>  	cur = sd;
> -	while (!(dentry = __sysfs_get_dentry(sysfs_sb, cur))) {
> +	while (!(dentry = __sysfs_get_dentry(sb, cur))) {

It's probably better to add @sb to __sysfs_get_dentry() here too.
That will make things look clearer.

Thanks.

-- 
tejun
