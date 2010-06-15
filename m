From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH RFC] nsproxy: strengthen the comment above copy_namespaces
Date: Mon, 14 Jun 2010 22:54:13 -0400
Message-ID: <4C16EB55.1090101@cs.columbia.edu>
References: <20100430183638.GA29240@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100430183638.GA29240-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge -

Is this intended for linux-cr ?
Sounds like it should go (or already?) upstream.

Oren.

On 04/30/2010 02:36 PM, Serge E. Hallyn wrote:
> copy_namespaces() cannot be used on a live task.  There are two
> reasons - it can be used to assign another task's nsproxy, which
> is not legal (for a live task).  And, it does not use
> rcu_assign_pointer, so even when we're being extra-clever it is
> unsafe.
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/nsproxy.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index f74e6c0..67d8f2b 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -115,6 +115,9 @@ out_ns:
>  /*
>   * called from clone.  This now handles copy for nsproxy and all
>   * namespaces therein.
> + * Note this should only be used in fork.  Specifically, tsk should
> + * not yet be a live task.  See the the unshare code for how to handle
> + * that.
>   */
>  int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>  {
