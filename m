From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Tue, 24 Feb 2009 16:32:07 -0600
Message-ID: <20090224223207.GA31959@us.ibm.com>
References: <20090224220256.GA31001@us.ibm.com> <20090224141651.70155ebd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760175AbZBXWce@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090224141651.70155ebd.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: adobriyan@gmail.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
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
> 
>  static int msg_max_limit_min = MIN_MSGMAX;
> _
> 
> intended?

It just seemed more in line with the idea of ensuring type
safety...  Of course the #defines will work and are how the
others (at least ipc and utsname) do it, but this seemed
a touch better.  Of course I'll change it if that's the
preference.

thanks,
-serge
