From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v3.01)
Date: Thu, 5 Aug 2010 16:49:02 -0700
Message-ID: <20100805234902.GS2927@count0.beaverton.ibm.com>
References: <1281031026-2357-1-git-send-email-danms@us.ibm.com>
	<1281031026-2357-3-git-send-email-danms@us.ibm.com>
	<20100805214842.GP2927@count0.beaverton.ibm.com>
	<4C5B3DF9.4000907@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C5B3DF9.4000907-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 05, 2010 at 06:40:57PM -0400, Oren Laadan wrote:
> 
> 
> On 08/05/2010 05:48 PM, Matt Helsley wrote:
> >On Thu, Aug 05, 2010 at 10:57:06AM -0700, Dan Smith wrote:
<snip>
> ><snip>
> >
> >>+static int restore_task_sem_undo_adj(struct ckpt_ctx *ctx)
> 
> Now that Matt said it ... I suggest to rename this too to
> something like "restore_sem_undo_adj()" :)
> 
> (Interestingly, the checkpoint counterpart is named so !)
> 
> >>+{
> >>+	struct ckpt_hdr_task_sem_undo *h;
> >>+	int len;
> >>+	int ret = -ENOMEM;
> >>+	struct sem_undo *un;
> >>+	int nsems;
> >>+	__s16 *semadj = NULL;
> >>+
> >>+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
> >>+	if (IS_ERR(h))
> >>+		return PTR_ERR(h);
> >>+
> >>+	len = sizeof(__s16) * h->semadj_count;
> >>+	ret = ckpt_read_payload(ctx, (void **)&semadj, len, CKPT_HDR_BUFFER);
> >>+	if (ret<  0)
> >>+		goto out;
> >>+
> >
> >As best I can tell exit_sem() does not do permission checking -- it
> >relies on semop and semtimedop to check permissions on the operation
> >that created the undo in the first place. Thus I think we need to check
> >permissions here with ipc_check_perms() or ipcperms(). Otherwise it may
> >be possible to manipulate semaphores we do not have permission to
> >manipulate.
> 
> Good catch !

Perhaps instead of mimicking the kernel data structure in the checkpoint image
and then restoring that kernel structure during restart we could create
a set of semops to write in the checkpoint image and then perform them
during restart. By effectively calling sys_semop during restart we would ensure
that we're doing the proper security checks, make the checkpoint image more
portable (since the semop interface can't change), and greatly reduce the
probability that c/r of the semaphores and their undo lists will bitrot
(IOW make maintenance easy for everyone).

Cheers,
	-Matt Helsley
