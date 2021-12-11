Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36ADF29CA
	for <containers@lists.linux.dev>; Sat, 11 Dec 2021 11:00:47 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 485AEC004DD;
	Sat, 11 Dec 2021 11:00:41 +0000 (UTC)
Date: Sat, 11 Dec 2021 12:00:38 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org
Subject: Re: [PATCH v6 14/17] ima: Tie opened SecurityFS files to the IMA
 namespace it belongs to
Message-ID: <20211211110038.dbshu23uvlhv65vn@wittgenstein>
References: <20211210194736.1538863-1-stefanb@linux.ibm.com>
 <20211210194736.1538863-15-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20211210194736.1538863-15-stefanb@linux.ibm.com>

On Fri, Dec 10, 2021 at 02:47:33PM -0500, Stefan Berger wrote:
> Tie IMA's files in SecurityFS to the IMA namespace they belong to so that
> also file descriptor that were passed or inherited to other user/IMA
> namespaces will always access the data of the IMA namespace they originally
> belonged to.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---
>  security/integrity/ima/ima_fs.c     | 74 ++++++++++++++++++++++++-----
>  security/integrity/ima/ima_policy.c |  4 +-
>  2 files changed, 63 insertions(+), 15 deletions(-)
> 
> diff --git a/security/integrity/ima/ima_fs.c b/security/integrity/ima/ima_fs.c
> index 0e582ceecc7f..a136d14f29ec 100644
> --- a/security/integrity/ima/ima_fs.c
> +++ b/security/integrity/ima/ima_fs.c
> @@ -35,6 +35,20 @@ static int __init default_canonical_fmt_setup(char *str)
>  }
>  __setup("ima_canonical_fmt", default_canonical_fmt_setup);
>  
> +static inline struct user_namespace *ima_user_ns_from_file(struct file *filp)
> +{
> +	return filp->f_path.mnt->mnt_sb->s_user_ns;
> +}

I'd probably rewrite this as:

static inline struct user_namespace *ima_user_ns_from_file(const struct file *filp)
{
	return file_inode(filp)->i_sb->s_user_ns;
}

as it spares you some pointer chasing and also looks cleaner.

> +
> +static int ima_open(struct inode *inode, struct file *file)
> +{
> +	struct user_namespace *user_ns = ima_user_ns_from_file(file);
> +	struct ima_namespace *ns = user_ns->ima_ns;
> +
> +	file->private_data = ns;
> +	return 0;
> +}
> +
>  static ssize_t ima_show_htable_value(char __user *buf, size_t count,
>  				     loff_t *ppos, atomic_long_t *val)
>  {
> @@ -49,12 +63,13 @@ static ssize_t ima_show_htable_violations(struct file *filp,
>  					  char __user *buf,
>  					  size_t count, loff_t *ppos)
>  {
> -	struct ima_namespace *ns = get_current_ns();
> +	struct ima_namespace *ns = filp->private_data;
>  
>  	return ima_show_htable_value(buf, count, ppos, &ns->ima_htable.violations);
>  }
>  
>  static const struct file_operations ima_htable_violations_ops = {
> +	.open = ima_open,
>  	.read = ima_show_htable_violations,
>  	.llseek = generic_file_llseek,
>  };
> @@ -63,12 +78,13 @@ static ssize_t ima_show_measurements_count(struct file *filp,
>  					   char __user *buf,
>  					   size_t count, loff_t *ppos)
>  {
> -	struct ima_namespace *ns = get_current_ns();
> +	struct ima_namespace *ns = filp->private_data;
>  
>  	return ima_show_htable_value(buf, count, ppos, &ns->ima_htable.len);
>  }
>  
>  static const struct file_operations ima_measurements_count_ops = {
> +	.open = ima_open,
>  	.read = ima_show_measurements_count,
>  	.llseek = generic_file_llseek,
>  };
> @@ -76,7 +92,7 @@ static const struct file_operations ima_measurements_count_ops = {
>  /* returns pointer to hlist_node */
>  static void *ima_measurements_start(struct seq_file *m, loff_t *pos)
>  {
> -	struct ima_namespace *ns = get_current_ns();
> +	struct ima_namespace *ns = m->private;
>  	loff_t l = *pos;
>  	struct ima_queue_entry *qe;
>  
> @@ -94,7 +110,7 @@ static void *ima_measurements_start(struct seq_file *m, loff_t *pos)
>  
>  static void *ima_measurements_next(struct seq_file *m, void *v, loff_t *pos)
>  {
> -	struct ima_namespace *ns = get_current_ns();
> +	struct ima_namespace *ns = m->private;
>  	struct ima_queue_entry *qe = v;
>  
>  	/* lock protects when reading beyond last element
> @@ -195,9 +211,26 @@ static const struct seq_operations ima_measurments_seqops = {
>  	.show = ima_measurements_show
>  };
>  
> +static int ima_seq_open(struct file *file, const struct seq_operations *seq_ops)
> +{
> +	struct user_namespace *user_ns = ima_user_ns_from_file(file);
> +	struct ima_namespace *ns = user_ns->ima_ns;
> +	struct seq_file *seq;
> +	int err;
> +
> +	err = seq_open(file, seq_ops);
> +	if (err)
> +		return err;
> +
> +	seq = file->private_data;
> +	seq->private = ns;
> +
> +	return 0;
> +}
> +
>  static int ima_measurements_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open(file, &ima_measurments_seqops);
> +	return ima_seq_open(file, &ima_measurments_seqops);
>  }
>  
>  static const struct file_operations ima_measurements_ops = {
> @@ -263,7 +296,7 @@ static const struct seq_operations ima_ascii_measurements_seqops = {
>  
>  static int ima_ascii_measurements_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open(file, &ima_ascii_measurements_seqops);
> +	return ima_seq_open(file, &ima_ascii_measurements_seqops);
>  }
>  
>  static const struct file_operations ima_ascii_measurements_ops = {
> @@ -273,9 +306,8 @@ static const struct file_operations ima_ascii_measurements_ops = {
>  	.release = seq_release,
>  };
>  
> -static ssize_t ima_read_policy(char *path)
> +static ssize_t ima_read_policy(struct ima_namespace *ns, char *path)
>  {
> -	struct ima_namespace *ns = get_current_ns();
>  	void *data = NULL;
>  	char *datap;
>  	size_t size;
> @@ -314,10 +346,23 @@ static ssize_t ima_read_policy(char *path)
>  		return pathlen;
>  }
>  
> +static struct ima_namespace *ima_filp_private(struct file *filp)
> +{
> +	if (!(filp->f_flags & O_WRONLY)) {
> +#ifdef CONFIG_IMA_READ_POLICY
> +		struct seq_file *seq;
> +
> +		seq = filp->private_data;
> +		return seq->private;
> +#endif
> +	}
> +	return filp->private_data;
> +}

All of that isn't needed with my last proposal. You don't need to stash
anything anywhere. I showed that in my previous patch suggestion. The
original filp is stashed in the seq_file's private member, i.e. taking

ima_measurements_start(struct seq_file *m, loff_t *pos)

you can get at:

const struct file *filp = m->file;
struct user_namespace *user_ns = file_inode(filp)->i_sb->s_user_ns;
struct ima_namespace *ns = user_ns->ima_ns;
