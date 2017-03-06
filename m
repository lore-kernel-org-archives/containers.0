From: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [REVIEW][PATCH] ucount: Remove the atomicity from ucount->count
Date: Mon, 6 Mar 2017 12:39:21 -0800
Message-ID: <20170306203919.GA17874@gmail.com>
References: <CACT4Y+a043_qFN=2uzvYhDFwF4JS9_p3jnOykpMk=RcpqQfKGQ@mail.gmail.com>
	<CACT4Y+Yev63VXYm+kZdii5kheV_ACBn2cehFcFdz6LBVam3Q2g@mail.gmail.com>
	<CACT4Y+b7YXnoOkdYTjp6D6XH-zuYRx063hMayOVMyJVc735dtQ@mail.gmail.com>
	<c69f8f03-4324-f934-eed2-643c91d703c0@gmail.com>
	<CACT4Y+avCy8Susvb09DLHkGym0K_15+EeZ8yBH7tcgjvnb3Yhw@mail.gmail.com>
	<CACT4Y+YWEq66QXbTMR4yGtgc0ULN+TurAnRzcDASaja1z5XNjA@mail.gmail.com>
	<87shmsoar7.fsf@xmission.com>
	<CACT4Y+bYAbsxsRWA2o+c7x25f1JPSqZKX-8a8NJq4nab-PyYig@mail.gmail.com>
	<87y3wjlg6r.fsf@xmission.com> <87tw77csgd.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87tw77csgd.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Mar 05, 2017 at 03:41:06PM -0600, Eric W. Biederman wrote:
> 
> Always increment/decrement ucount->count under the ucounts_lock.  The
> increments are there already and moving the decrements there means the
> locking logic of the code is simpler.  This simplification in the
> locking logic fixes a race between put_ucounts and get_ucounts that
> could result in a use-after-free because the count could go zero then
> be found by get_ucounts and then be freed by put_ucounts.
> 
> A bug presumably this one was found by a combination of syzkaller and
> KASAN.  JongWhan Kim reported the syzkaller failure and Dmitry Vyukov
> spotted the race in the code.
>

Reviewed-by: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I think we can rework this in a future so that ucount will be rcu
protected.


> Reported-by: JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reported-by: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  include/linux/user_namespace.h |  2 +-
>  kernel/ucount.c                | 18 +++++++++++-------
>  2 files changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 363e0e8082a9..61071b6d2d12 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -69,7 +69,7 @@ struct ucounts {
>  	struct hlist_node node;
>  	struct user_namespace *ns;
>  	kuid_t uid;
> -	atomic_t count;
> +	int count;
>  	atomic_t ucount[UCOUNT_COUNTS];
>  };
>  
> diff --git a/kernel/ucount.c b/kernel/ucount.c
> index 68716403b261..73696faa80dd 100644
> --- a/kernel/ucount.c
> +++ b/kernel/ucount.c
> @@ -143,7 +143,7 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
>  
>  		new->ns = ns;
>  		new->uid = uid;
> -		atomic_set(&new->count, 0);
> +		new->count = 0;
>  
>  		spin_lock_irq(&ucounts_lock);
>  		ucounts = find_ucounts(ns, uid, hashent);
> @@ -154,8 +154,10 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
>  			ucounts = new;
>  		}
>  	}
> -	if (!atomic_add_unless(&ucounts->count, 1, INT_MAX))
> +	if (ucounts->count == INT_MAX)
>  		ucounts = NULL;
> +	else
> +		ucounts->count += 1;
>  	spin_unlock_irq(&ucounts_lock);
>  	return ucounts;
>  }
> @@ -164,13 +166,15 @@ static void put_ucounts(struct ucounts *ucounts)
>  {
>  	unsigned long flags;
>  
> -	if (atomic_dec_and_test(&ucounts->count)) {
> -		spin_lock_irqsave(&ucounts_lock, flags);
> +	spin_lock_irqsave(&ucounts_lock, flags);
> +	ucounts->count -= 1;
> +	if (!ucounts->count)
>  		hlist_del_init(&ucounts->node);
> -		spin_unlock_irqrestore(&ucounts_lock, flags);
> +	else
> +		ucounts = NULL;
> +	spin_unlock_irqrestore(&ucounts_lock, flags);
>  
> -		kfree(ucounts);
> -	}
> +	kfree(ucounts);
>  }
>  
>  static inline bool atomic_inc_below(atomic_t *v, int u)
> -- 
> 2.10.1
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
