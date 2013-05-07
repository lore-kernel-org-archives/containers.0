From: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Tue, 7 May 2013 13:30:43 +0300
Message-ID: <CAE=NcrY5oVFd-Eu=iBR6PcZ_M_DWcitAxz3bvovWh1smQ5wUog@mail.gmail.com>
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

On Tue, May 7, 2013 at 11:01 AM, Janne Karhunen
<janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

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

I am also seriously unhappy about this 'setuid compatibility mode'
here. It is highly surprising to have all caps elevated on uid/euid
root exec regardless of the executable setuid flags...


--
Janne
