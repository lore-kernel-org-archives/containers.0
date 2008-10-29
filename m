From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 03/10] Introduce context structure needed
	during checkpointing/restart
Date: Wed, 29 Oct 2008 19:30:28 +0400
Message-ID: <200810291830.29732.major__26403.8224042908$1225294496$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-4-git-send-email-major@openvz.org>
	<1224522144.1848.115.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224522144.1848.115.camel@nimitz>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 21:02 Dave Hansen wrote:
> On Sat, 2008-10-18 at 03:11 +0400, Andrey Mirkin wrote:
> > +typedef struct cpt_context
> > +{
> > +	pid_t		pid;		/* should be changed to ctid later */
> > +	int		ctx_id;		/* context id */
> > +	struct list_head ctx_list;
> > +	int		refcount;
> > +	int		ctx_state;
> > +	struct semaphore main_sem;
>
> Does this really need to be a semaphore or is a mutex OK?
Actually mutex is enough here.

> > +	int		errno;
>
> Could you hold off on adding these things to the struct until the patch
> where they're actually used?  It's hard to judge this without seeing
> what you do with it.
I will try not to introduce variables and functions which are not used in 
future.

>
> > +	struct file	*file;
> > +	loff_t		current_object;
> > +
> > +	struct list_head object_array[CPT_OBJ_MAX];
> > +
> > +	int		(*write)(const void *addr, size_t count, struct cpt_context *ctx);
> > +	int		(*read)(void *addr, size_t count, struct cpt_context *ctx);
> > +} cpt_context_t;
>
> Man, this is hard to review.  I was going to try and make sure that your
> refcounting was right and atomic, but there's no use of it in this patch
> except for the initialization and accessor functions.  Darn.
For simplicity I will throw out all this stuff completely.

>
> > +extern int debug_level;
>
> I'm going to go out on a limb here and say that "debug_level" is
> probably a wee bit too generic of a variable name.
I will change it to something else.

>
> > +#define cpt_printk(lvl, fmt, args...)	do {	\
> > +		if (lvl <= debug_level)		\
> > +			printk(fmt, ##args);	\
> > +	} while (0)
>
> I think you can use pr_debug() here, too, just like Oren did.
Will switch to pr_debug().

>
> > +struct cpt_context * context_alloc(void)
> > +{
> > +	struct cpt_context *ctx;
> > +	int i;
> > +
> > +	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
> > +	if (!ctx)
> > +		return NULL;
> > +
> > +	init_MUTEX(&ctx->main_sem);
> > +	ctx->refcount = 1;
> > +
> > +	ctx->current_object = -1;
> > +	ctx->write = file_write;
> > +	ctx->read = file_read;
> > +	for (i = 0; i < CPT_OBJ_MAX; i++) {
> > +		INIT_LIST_HEAD(&ctx->object_array[i]);
> > +	}
> > +
> > +	return ctx;
> > +}
> > +
> > +void context_release(struct cpt_context *ctx)
> > +{
> > +	ctx->ctx_state = CPT_CTX_ERROR;
> > +
> > +	kfree(ctx);
> > +}
> > +
> > +static void context_put(struct cpt_context *ctx)
> > +{
> > +	if (!--ctx->refcount)
> > +		context_release(ctx);
> > +}
> > +
> >  static int checkpoint(pid_t pid, int fd, unsigned long flags)
> >  {
> > -	return -ENOSYS;
> > +	struct file *file;
> > +	struct cpt_context *ctx;
> > +	int err;
> > +
> > +	err = -EBADF;
> > +	file = fget(fd);
> > +	if (!file)
> > +		goto out;
> > +
> > +	err = -ENOMEM;
> > +	ctx = context_alloc();
> > +	if (!ctx)
> > +		goto out_file;
> > +
> > +	ctx->file = file;
> > +	ctx->ctx_state = CPT_CTX_DUMPING;
> > +
> > +	/* checkpoint */
> > +	err = -ENOSYS;
> > +
> > +	context_put(ctx);
> > +
> > +out_file:
> > +	fput(file);
> > +out:
> > +	return err;
> >  }
>
> So, where is context_get()?  Is there only single-threaded access to the
> refcount?  If so, why do we even need it?  We should probably just use
> context_release() driectly.
The idea is that in future we should be able to keep a context for incremental 
checkpointing. That is why we need context get/put functions. Right now it is 
not used, so I will drop it.

> If there is multithreaded access to context_put() or the refcount, then
> they're unsafe without additional locking.
Access to refcount will be protected with context mutex.

Thanks for comments.

Actually I'm not sure if I will continue with my own patch set, but I will 
take into account all your comments during porting my functionality to Oren's 
tree.

Andrey
