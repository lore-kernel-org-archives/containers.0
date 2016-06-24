From: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH review 03/13] ipc: Initialize ipc_namespace->user_ns early.
Date: Fri, 24 Jun 2016 16:34:14 +0200
Message-ID: <CAEiveUdzBB0DbmrniHRn+n+_vPmQAd5mhJ1MGDLM2GZh0FhrCw@mail.gmail.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
	<20160620172130.15712-3-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160620172130.15712-3-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jun 20, 2016 at 7:21 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Allow the ipc namespace initialization code to depend on ns->user_ns
> being set during initialization.
>
> In particular this allows mq_init_ns to use ns->user_ns for permission
> checks and initializating s_user_ns while the the mq filesystem is
> being mounted.
>
> Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Suggested-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Reviewed-by: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  ipc/namespace.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index 068caf18d565..04cb07eb81f1 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -34,8 +34,11 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
>         ns->ns.ops = &ipcns_operations;
>
>         atomic_set(&ns->count, 1);
> +       ns->user_ns = get_user_ns(user_ns);
> +
>         err = mq_init_ns(ns);
>         if (err) {
> +               put_user_ns(ns->user_ns);
>                 ns_free_inum(&ns->ns);
>                 kfree(ns);
>                 return ERR_PTR(err);
> @@ -46,8 +49,6 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
>         msg_init_ns(ns);
>         shm_init_ns(ns);
>
> -       ns->user_ns = get_user_ns(user_ns);
> -
>         return ns;
>  }
>
> --
> 2.8.3
>



-- 
tixxdz
http://opendz.org
http://blog.opendz.org
