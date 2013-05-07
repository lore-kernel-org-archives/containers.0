From: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Tue, 7 May 2013 12:10:55 +0300
Message-ID: <CAE=NcraoW5W5iD140R9e36tiwRpqs1Gix9_M1iHDsc3PbAY32w@mail.gmail.com>
References: <1367913689-3423-1-git-send-email-Janne.Karhunen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367913689-3423-1-git-send-email-Janne.Karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

To clarify that bit more - I'm experimenting with a system that has
absolute bare minimum init ns and everything sits in a container.
Given that, it would be nice if someone somewhere was actually able to
do something privileged...

Anyway, patch is just early proposal, better proposals welcome.


--
Janne

On Tue, May 7, 2013 at 11:01 AM, Janne Karhunen
<janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Current state of the kernel appears to be that there are more
> than 1000 capable() calls and only handful are converted to
> ns_capable(). Moreover, it probably does not make any sense
> to convert most of these calls to be namespace aware due to
> the nature of the physical resources they control, making
> 'capable()' the right question to ask. Yet, in order to be
> able to build 'fully functional real device' like containers,
> user namespaces sometimes need the access to real system
> resources.
>
> Thus, one potential candidate for enabling access to physical
> resources from the user namespace would be to use namespaces
> own CAP_SYS_RESOURCE as a magical token for making task
> capabilities valid for init_ns.
>
> Signed-off-by: Janne Karhunen <Janne.Karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  kernel/user_namespace.c |    8 ++++++++
>  security/commoncap.c    |   18 ++++++++++++++++--
>  2 files changed, 24 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index d8c30db..f7281fd 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -43,6 +43,14 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
>         key_put(cred->request_key_auth);
>         cred->request_key_auth = NULL;
>  #endif
> +
> +       /* Since CAP_SYS_RESOURCE is the way out of user_ns, we start off having
> +        * it disabled.
> +        */
> +       cap_lower (cred->cap_effective, CAP_SYS_RESOURCE);
> +       cap_lower (cred->cap_permitted, CAP_SYS_RESOURCE);
> +       cap_lower (cred->cap_inheritable, CAP_SYS_RESOURCE);
> +
>         /* tgcred will be cleared in our caller bc CLONE_THREAD won't be set */
>         cred->user_ns = user_ns;
>  }
> diff --git a/security/commoncap.c b/security/commoncap.c
> index c44b6fe..cdacb2d 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -83,9 +83,18 @@ int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
>          * user namespace's parents.
>          */
>         for (;;) {
> -               /* Do we have the necessary capabilities? */
> +               /* If we belong in this ns, do we have the capability? */
>                 if (ns == cred->user_ns)
>                         return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
> +               else {
> +                       /* User_ns asking for rights in init_ns? */
> +                       if (ns == &init_user_ns) {
> +                               if (cap_raised(cred->cap_effective, CAP_SYS_RESOURCE))
> +                                       return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
> +                               else
> +                                       return -EPERM;
> +                       }
> +               }
>
>                 /* Have we tried all of the parent namespaces? */
>                 if (ns == &init_user_ns)
> @@ -481,7 +490,7 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
>         const struct cred *old = current_cred();
>         struct cred *new = bprm->cred;
>         bool effective, has_cap = false;
> -       int ret;
> +       int ret, has_res;
>         kuid_t root_uid;
>
>         effective = false;
> @@ -501,6 +510,8 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
>                         warn_setuid_and_fcaps_mixed(bprm->filename);
>                         goto skip;
>                 }
> +               has_res = cap_raised(new->cap_permitted, CAP_SYS_RESOURCE);
> +
>                 /*
>                  * To support inheritance of root-permissions and suid-root
>                  * executables under compatibility mode, we override the
> @@ -512,6 +523,9 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
>                         /* pP' = (cap_bset & ~0) | (pI & ~0) */
>                         new->cap_permitted = cap_combine(old->cap_bset,
>                                                          old->cap_inheritable);
> +
> +                       if (!has_res && (old->user_ns != &init_user_ns))
> +                               cap_lower (new->cap_permitted, CAP_SYS_RESOURCE);
>                 }
>                 if (uid_eq(new->euid, root_uid))
>                         effective = true;
> --
> 1.7.9.5
>
