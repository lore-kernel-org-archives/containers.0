From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Wed, 25 Feb 2009 01:32:45 +0300
Message-ID: <20090224223245.GA17473@x200.localdomain>
References: <20090224220256.GA31001@us.ibm.com> <20090224141651.70155ebd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761281AbZBXW0h@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090224141651.70155ebd.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, clg@fr.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Tue, Feb 24, 2009 at 02:16:51PM -0800, Andrew Morton wrote:
> On Tue, 24 Feb 2009 16:02:56 -0600
> "Serge E. Hallyn" <serue@us.ibm.com> wrote:
> 
> > +#ifdef CONFIG_PROC_SYSCTL
> > +static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
> > +	void __user *buffer, size_t *lenp, loff_t *ppos)
> > +{
> > +	struct ctl_table mq_table;
> > +	memcpy(&mq_table, table, sizeof(mq_table));
> > +	mq_table.data = get_mq(table);
> > +
> > +	return proc_dointvec(&mq_table, write, filp, buffer, lenp, ppos);
> > +}
> > +
> > +static int proc_mq_dointvec_minmax(ctl_table *table, int write,
> > +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
> > +{
> > +	struct ctl_table mq_table;
> > +	memcpy(&mq_table, table, sizeof(mq_table));
> > +	mq_table.data = get_mq(table);
> > +
> > +	return proc_dointvec_minmax(&mq_table, write, filp, buffer,
> > +					lenp, ppos);
> > +}
> > +#else
> > +proc_handler *proc_mq_dointvec = NULL;
> > +proc_handler *proc_mq_dointvec_minmax = NULL;
> > +#endif
> 
> looks odd.  Was this
> 
> --- a/ipc/mq_sysctl.c~mqueue-namespace-adapt-sysctl-update-fix
> +++ a/ipc/mq_sysctl.c
> @@ -52,8 +52,8 @@ static int proc_mq_dointvec_minmax(ctl_t
>  					lenp, ppos);
>  }
>  #else
> -proc_handler *proc_mq_dointvec = NULL;
> -proc_handler *proc_mq_dointvec_minmax = NULL;
> +#define proc_mq_dointvec NULL
> +#define proc_mq_dointvec_minmax NULL
>  #endif

I hope, not.

"#define foo NULL" is the least intrusive thing.
