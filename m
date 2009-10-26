From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] Checkpoint/restart eventfd
Date: Mon, 26 Oct 2009 11:11:56 -0500
Message-ID: <20091026161156.GA27657@us.ibm.com>
References: <1256447590-31138-1-git-send-email-matthltc@us.ibm.com>
	<20091026152151.GB23564@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091026152151.GB23564-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > Save/restore eventfd files. These are anon_inodes just like epoll
> > but instead of a set of files to poll they are a 64-bit counter
> > and a flag value. Used for AIO.
> > 
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > NOTE: Marked [RFC] because it strangely does not pass my adapted LTP
> > 	test cases unless it's running from a checkpointed image.
> > 	Seems to be a mistake in the test case adaptation.
> > ---
> >  checkpoint/files.c             |    7 +++++
> >  fs/eventfd.c                   |   51 ++++++++++++++++++++++++++++++++++++++++
> >  include/linux/checkpoint_hdr.h |    8 ++++++
> >  include/linux/eventfd.h        |   10 ++++++++
> >  4 files changed, 76 insertions(+), 0 deletions(-)
> > 
> > diff --git a/checkpoint/files.c b/checkpoint/files.c
> > index f6de07e..43b95cc 100644
> > --- a/checkpoint/files.c
> > +++ b/checkpoint/files.c
> > @@ -23,6 +23,7 @@
> >  #include <linux/checkpoint.h>
> >  #include <linux/checkpoint_hdr.h>
> >  #include <net/sock.h>
> > +#include <linux/eventfd.h>
> > 
> > 
> >  /**************************************************************************
> > @@ -607,6 +608,12 @@ static struct restore_file_ops restore_file_ops[] = {
> >  		.file_type = CKPT_FILE_TTY,
> >  		.restore = tty_file_restore,
> >  	},
> > +	/* eventfd */
> > +	{
> > +		.file_name = "EVENTFD",
> > +		.file_type = CKPT_FILE_EVENTFD,
> > +		.restore = eventfd_restore,
> > +	},
> >  };
> > 
> >  static struct file *do_restore_file(struct ckpt_ctx *ctx)
> > diff --git a/fs/eventfd.c b/fs/eventfd.c
> > index 31d12de..5d30cd5 100644
> > --- a/fs/eventfd.c
> > +++ b/fs/eventfd.c
> > @@ -18,6 +18,8 @@
> >  #include <linux/module.h>
> >  #include <linux/kref.h>
> >  #include <linux/eventfd.h>
> > +#include <linux/checkpoint.h>
> > +#include <linux/checkpoint_hdr.h>
> > 
> >  struct eventfd_ctx {
> >  	struct kref kref;
> > @@ -223,11 +225,34 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
> >  	return res;
> >  }
> > 
> > +static int eventfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
> > +{
> > +	struct eventfd_ctx *ctx;
> > +	struct ckpt_hdr_file_eventfd *h;
> > +	int ret = -ENOMEM;
> > +
> > +	h = ckpt_hdr_get_type(ckpt_ctx, sizeof(*h), CKPT_HDR_FILE);
> > +	if (!h)
> > +		return -ENOMEM;
> > +	h->common.f_type = CKPT_FILE_EVENTFD;
> > +	ret = checkpoint_file_common(ckpt_ctx, file, &h->common);
> > +	if (ret < 0)
> > +		goto out;
> > +	ctx = file->private_data;
> > +	h->count = ctx->count;
> 
> I only took a very cursory glance at the eventfd code, but eventfd_poll()
> suggests that ULLONG_MAX is a valid value for ctx->count (suggesting error).
> Should you be checking for that?  (Or is that a special case that will
> never be checkpointed somehow?)

(for posterity)

As you pointed out on irc, there is no problem.

thanks,
-serge
