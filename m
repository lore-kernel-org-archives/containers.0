From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Tue, 24 Feb 2009 07:35:12 +0300
Message-ID: <20090224043512.GA3202@x200.localdomain>
References: <20090224030347.GA10913@us.ibm.com> <20090224030933.GC11441@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754216AbZBXE2v@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090224030933.GC11441@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 23, 2009 at 09:09:33PM -0600, Serge E. Hallyn wrote:
> +#ifdef CONFIG_PROC_FS
> +static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
> +	void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	struct ctl_table mq_table;
> +	memcpy(&mq_table, table, sizeof(mq_table));
> +	mq_table.data = get_mq(table);
> +
> +	return proc_dointvec(&mq_table, write, filp, buffer, lenp, ppos);
> +}
> +
> +static int proc_mq_dointvec_minmax(ctl_table *table, int write,
> +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	struct ctl_table mq_table;
> +	memcpy(&mq_table, table, sizeof(mq_table));
> +	mq_table.data = get_mq(table);
> +
> +	return proc_dointvec_minmax(&mq_table, write, filp, buffer,
> +					lenp, ppos);
> +}
> +#else /* CONFIG_PROC_FS */
> +static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
> +	void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	return -ENOSYS;
> +}
> +
> +static int proc_mq_dointvec_minmax(ctl_table *table, int write,
> +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	return -ENOSYS;
> +}
> +#endif /* CONFIG_PROC_FS */

These should be under CONFIG_PROC_SYSCTL and one should define them to
NULL otherwise.

> +static ctl_table mq_sysctls[] = {
> +	{
> +		.procname	= "queues_max",
> +		.data		= &init_ipc_ns.mq_queues_max,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_mq_dointvec,
				  ^
No &, please. I'm removing them.

> +	},
> +	{
> +		.procname	= "msg_max",
> +		.data		= &init_ipc_ns.mq_msg_max,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_mq_dointvec_minmax,
> +		.extra1		= &msg_max_limit_min,
> +		.extra2		= &msg_max_limit_max,
> +	},
> +	{
> +		.procname	= "msgsize_max",
> +		.data		= &init_ipc_ns.mq_msgsize_max,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_mq_dointvec_minmax,
> +		.extra1		= &msg_maxsize_limit_min,
> +		.extra2		= &msg_maxsize_limit_max,
> +	},
