From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/6] cgroup: kill subsys->can_attach_task(), pre_attach()
	and attach_task()
Date: Wed, 31 Aug 2011 09:03:13 +0200
Message-ID: <20110831070313.GA29179__15064.1801454642$1314904910$gmane$org@mtj.dyndns.org>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<1314312192-26885-7-git-send-email-tj@kernel.org>
	<20110830201030.GC15953@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110830201030.GC15953-oHC15RC7JGTpAmv0O++HtFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Frederic.

On Tue, Aug 30, 2011 at 10:10:32PM +0200, Frederic Weisbecker wrote:
> In order to keep the fix queued in -mm (https://lkml.org/lkml/2011/8/26/262)
> the tasks that have failed to migrate should be removed from the iterator
> so that they are not included in the batch in ->attach().

I don't think that's a good approach.  It breaks the symmetry when
calling different callbacks.  What if ->can_attach() allocates
per-task resources and the task exits in the middle?  I think we
better lock down fork/exit/exec.  I'll send patches but I'm currently
moving / traveling w/ limited access to my toys so it might take some
time.

Thanks.

-- 
tejun
