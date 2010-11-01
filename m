From: Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] kernel, cred, kvm,
	security - removing superfluous rcu_read_lock_held check
Date: Mon, 01 Nov 2010 23:42:23 +0100
Message-ID: <4CCF424F.3050205__14756.7971529954$1288651390$gmane$org@redhat.com>
References: <1288638909-10541-1-git-send-email-jolsa@redhat.com>
	<1288638909-10541-3-git-send-email-jolsa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1288638909-10541-3-git-send-email-jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: paul.moore-VXdhtT5mjnY@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/01/2010 08:15 PM, Jiri Olsa wrote:
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index a055742..a90a7e3 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -256,7 +256,6 @@ void kvm_put_kvm(struct kvm *kvm);
>   static inline struct kvm_memslots *kvm_memslots(struct kvm *kvm)
>   {
>   	return rcu_dereference_check(kvm->memslots,
> -			srcu_read_lock_held(&kvm->srcu)
>   			|| lockdep_is_held(&kvm->slots_lock));
>   }
>

This is an srcu_read_lock_held, which you don't touch here:

> diff --git a/kernel/rcutorture.c b/kernel/rcutorture.c
> index 9d8e8fb..0956a73 100644
> --- a/kernel/rcutorture.c
> +++ b/kernel/rcutorture.c
> @@ -807,7 +807,6 @@ static void rcu_torture_timer(unsigned long unused)
>  	idx = cur_ops->readlock();
>  	completed = cur_ops->completed();
>  	p = rcu_dereference_check(rcu_torture_current,
> -				  rcu_read_lock_held() ||
>  				  rcu_read_lock_bh_held() ||
>  				  rcu_read_lock_sched_held() ||
>  				  srcu_read_lock_held(&srcu_ctl));

I guess the kvm hunk is the incorrect one?

Paolo
