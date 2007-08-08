From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 20/25] sysfs: Rename Support multiple superblocks
Date: Wed, 8 Aug 2007 18:35:05 +0900
Message-ID: <20070808093505.GL13674@htj.dyndns.org>
References: <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com> <m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com> <m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com> <m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com> <m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com> <m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com> <m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com> <m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com> <m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com> <m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932925AbXHHJfa@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Hello,

On Tue, Aug 07, 2007 at 03:31:18PM -0600, Eric W. Biederman wrote:
> This patch modifies the sysfs_rename_dir and sysfs_move_dir
> to support multiple sysfs dentry trees rooted in different
> sysfs superblocks.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

> +struct sysfs_rename_struct {
> +	struct list_head list;
> +	struct dentry *old_dentry;
> +	struct dentry *new_dentry;
> +	struct dentry *old_parent;
> +	struct dentry *new_parent;
> +};

Please rename to sysfs_rename_cxt to it consistent with
sysfs_addrm_cxt.

> +static void post_rename(struct list_head *head)

Please rename to sysfs_post_rename() and add comment.

> +{
> +	struct sysfs_rename_struct *srs;
> +	while (!list_empty(head)) {
> +		srs = list_entry(head->next, struct sysfs_rename_struct, list);
> +		dput(srs->old_dentry);
> +		dput(srs->new_dentry);
> +		dput(srs->old_parent);
> +		dput(srs->new_parent);
> +		list_del(&srs->list);
> +		kfree(srs);
> +	}
> +}
> +
> +static int prep_rename(struct list_head *head,
> +	struct sysfs_dirent *sd, struct sysfs_dirent *new_parent_sd,
> +	const char *name)

Ditto.

> +{
> +	struct sysfs_rename_struct *srs;
> +	struct super_block *sb;
> +	struct dentry *dentry;
> +	int error;
> +
> +	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
> +		dentry = sysfs_get_dentry(sb, sd);
> +		if (!dentry)
> +			continue;

sysfs_get_dentry() return ERR_PTR() value.  Oops, sysfs_get_dentry()
implementation is wrong too.  Also, please move
sysfs_grab/release_supers() near this patch and add (a lot of)
comments there.

Other than that, I think this is as clean as this can be.  Great.

-- 
tejun
