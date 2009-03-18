From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 04:35:58 -0400
Message-ID: <49C0B26E.9050108@cs.columbia.edu>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236880612-15316-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> (apologies if you see this multiple times...IBM mail server troubles)
> 
> This patch adds a "phase" of c/r that saves out information about any
> namespaces the task(s) may have.  Do this by tracking the nsproxy of the
> first task and making sure that the tasks that follow get hooked back to
> share the same one on restart.  On restart, we also explicitly create new
> namespaces for any that we support at the first task.
> 
> I tested this with single and multiple task restore, on top of Oren's
> v13 tree.
> 
> This is intended to get some discussion going about how to c/r the various
> namespaces.  So, if this approach isn't favorable, speak up with some
> suggestions for how to do it better.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c        |   57 ++++++++++++++++++++++++++
>  checkpoint/objhash.c           |    7 +++
>  checkpoint/restart.c           |   87 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/checkpoint.h     |    1 +
>  include/linux/checkpoint_hdr.h |   15 +++++++
>  5 files changed, 167 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 64155de..a613f2d 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -193,6 +193,59 @@ static int cr_write_tail(struct cr_ctx *ctx)
>  	return ret;
>  }
>  
> +static int cr_write_ns_uts(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_utsns *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct new_utsname *n = &t->nsproxy->uts_ns->name;
> +	int ret;
> +
> +	h.type = CR_HDR_UTSNS;
> +	h.len = sizeof(*hh);
> +	h.parent = 0;
> +
> +	memcpy(hh->nodename, n->nodename, sizeof(n->nodename));
> +	memcpy(hh->domainname, n->domainname, sizeof(n->domainname));

The length of ->nodename etc may change between kernels or in future
versions. Please also save the length of the buffer.
(see for example cr_write_task_struct() handling of ->comm)

[...]

Oren.
