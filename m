From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] checkpoint: Note checkpointability of mm_struct (v2)
Date: Wed, 4 Mar 2009 16:35:05 -0600
Message-ID: <20090304223505.GA27248@us.ibm.com>
References: <20090302161115.GA10484@us.ibm.com>
	<87iqmpvtfw.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87iqmpvtfw.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> SH> +static inline void task_show_checkpointable(struct seq_file *m,
> SH> +						struct task_struct *p)
> SH> +{
> SH> +	if (test_bit(0, &p->mm->may_checkpoint))
> SH> +		seq_printf(m,	"mm is checkpointable\n");
>                              ^^^
> You have a hard tab in the middle of the line.  Was that intentional?
> 
> SH> +	else
> SH> +		seq_printf(m,	"mm is not checkpointable\n");
> SH> +
> SH> +	if (test_bit(0, &p->files->may_checkpoint))
> SH> +		seq_printf(m,	"files are checkpointable\n");
> SH> +	else
> SH> +		seq_printf(m,	"files are not checkpointable\n");
> SH> +}
> 
> These too.
> 
> SH> +static inline void __mm_deny_checkpointing(struct mm_struct *mm,
> SH> +		char *file, int line)
> SH> +{
> SH> +	if (!test_and_clear_bit(0, &mm->may_checkpoint))
> SH> +		return;
> SH> +	printk(KERN_INFO "process performed an (mm) action that can not be "
> SH> +			"checkpointed at: %s:%d\n", file, line);
> SH> +}
> SH> +#define mm_deny_checkpointing(f) \
> SH> +	__mm_deny_checkpointing(f, __FILE__, __LINE__)
> 
> There is no definition of mm_deny_checkpointing() outside of
> CONFIG_CHECKPOINT_RESTART, which means that you get a build error
> because mm->may_checkpoint is only present when CR is enabled.
> 
> SH> -	WARN_ON(1);
> SH> +	//WARN_ON(1);
> 
> I assume commenting this out wasn't intended to be in this patch.

Yeah that's why I said I would clean it up before sending to
lkml :)

I was especially curious whether using vm_stat_account to catch the
offending mmaps seemed sensible.

thanks,
-serge
