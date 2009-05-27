From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Wed, 27 May 2009 20:28:40 +0400
Message-ID: <20090527162840.GA30529__42058.9665919126$1243441807$gmane$org@x200.localdomain>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1242968132-1044-18-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, May 22, 2009 at 08:55:12AM +0400, Alexey Dobriyan wrote:
> +static int task_struct_restorer(void *_tsk_ctx)
> +{
> +	struct task_struct_restore_context *tsk_ctx = _tsk_ctx;
> +	struct kstate_image_task_struct *i = tsk_ctx->i;
> +	struct kstate_context *ctx = tsk_ctx->ctx;
> +	/* In the name of symmetry. */
> +	struct task_struct *tsk = current, *real_parent;
> +	int rv;
> +
> +	pr_debug("%s: ENTER tsk %p/%s\n", __func__, tsk, tsk->comm);
> +
> +	write_lock_irq(&tasklist_lock);
> +	real_parent = ctx->init_tsk->nsproxy->pid_ns->child_reaper;
> +	tsk->real_parent = tsk->parent = real_parent;
> +	list_move_tail(&tsk->sibling, &tsk->real_parent->sibling);
							 ^^^^^^^
> +	write_unlock_irq(&tasklist_lock);

Eek, what a stupid bug here


commit 2c4b5f5d606a1892b702d95a0e4d29f207685381
Author: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed May 27 20:21:59 2009 +0400

    C/R: fix stupid bug in reparenting
    
    Child process should be added to ->children list of course
    
    Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index 9ed5a19..6df7d25 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -490,7 +490,7 @@ static int task_struct_restorer(void *_tsk_ctx)
 		real_parent = tmp->o_obj;
 	}
 	tsk->real_parent = tsk->parent = real_parent;
-	list_move_tail(&tsk->sibling, &tsk->real_parent->sibling);
+	list_move_tail(&tsk->sibling, &tsk->real_parent->children);
 	write_unlock_irq(&tasklist_lock);
 
 	rv = restore_mm(ctx, &i->ref_mm);
