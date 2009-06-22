From: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Fixes for the deferqueue_add() function (v2)
Date: Mon, 22 Jun 2009 11:20:39 +0800
Message-ID: <20090622032039.GD5893@cr0.nay.redhat.com>
References: <1245435505-24842-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1245435505-24842-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Fri, Jun 19, 2009 at 11:18:25AM -0700, Dan Smith wrote:
>I'm not sure how the deferqueue would (or has ever) worked without these
>modifications, but I had to make them in order to use it :)
>
>Changes (v2):
>  - Remove unnecessary initialization of the new list item
>
>Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
>Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Good catch!!

Reviewed-by: WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

>---
> kernel/deferqueue.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/kernel/deferqueue.c b/kernel/deferqueue.c
>index efd99d5..3fb388b 100644
>--- a/kernel/deferqueue.c
>+++ b/kernel/deferqueue.c
>@@ -66,7 +66,7 @@ int deferqueue_add(struct deferqueue_head *head, void *data, int size,
> {
> 	struct deferqueue_entry *dq;
> 
>-	dq = kmalloc(sizeof(dq) + size, GFP_KERNEL);
>+	dq = kmalloc(sizeof(*dq) + size, GFP_KERNEL);
> 	if (!dq)
> 		return -ENOMEM;
> 
>@@ -77,7 +77,7 @@ int deferqueue_add(struct deferqueue_head *head, void *data, int size,
> 	pr_debug("%s: adding work %p func %p dtor %p\n",
> 		 __func__, dq, func, dtor);
> 	spin_lock(&head->lock);
>-	list_add_tail(&head->list, &dq->list);
>+	list_add_tail(&dq->list, &head->list);
> 	spin_unlock(&head->lock);
> 	return 0;
> }
>-- 
>1.6.0.4
>
>_______________________________________________
>Containers mailing list
>Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>https://lists.linux-foundation.org/mailman/listinfo/containers
