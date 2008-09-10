From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v4][PATCH 2/9] General infrastructure for checkpoint restart
Date: Wed, 10 Sep 2008 14:36:16 -0400
Message-ID: <48C813A0.2020404__36564.4869664267$1221072162$gmane$org@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>	
	<1220946154-15174-3-git-send-email-orenl@cs.columbia.edu>
	<28c262360809092310x244c0c8dvca8a6022c7d0d225@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <28c262360809092310x244c0c8dvca8a6022c7d0d225-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: MinChan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



MinChan Kim wrote:
> On Tue, Sep 9, 2008 at 4:42 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

[...]

>> +struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
>> +{
>> +       struct cr_ctx *ctx;
>> +
>> +       ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
>> +       if (!ctx)
>> +               return ERR_PTR(-ENOMEM);
>> +
>> +       ctx->file = fget(fd);
>> +       if (!ctx->file) {
>> +               cr_ctx_free(ctx);
>> +               return ERR_PTR(-EBADF);
>> +       }
>> +       get_file(ctx->file);
> 
> Why do you need get_file?
> You already called fget.
> Am I missing something ?

This was meant for when we will restart multiple processes, each would
have access to the checkpoint-context, such that the checkpoint-context
may outlives the task that created it and initiated the restart. Thus
the file-pointer will need to stay around longer than that task.

Of course, restart of multiple processes _can_ be coded such that this
first task will always terminate last - either after restart completes
successfully, or after all the other tasks aborted and won't use the
checkpoint-context anymore.

Because that code is not part of the this patch-set, I considered it
safer to grab a reference of the file pointer, making it less likely
that we forget about it later.

> 
>> +       ctx->hbuf = (void *) __get_free_pages(GFP_KERNEL, CR_HBUF_ORDER);
>> +       if (!ctx->hbuf) {
>> +               cr_ctx_free(ctx);
>> +               return ERR_PTR(-ENOMEM);
>> +       }
>> +
>> +       ctx->pid = pid;
>> +       ctx->flags = flags;
>> +
>> +       ctx->crid = atomic_inc_return(&cr_ctx_count);
>> +
>> +       return ctx;
>> +}

Oren.
