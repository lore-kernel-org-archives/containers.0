From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] audit: skip sessionid sentinel value when
	auto-incrementing
Date: Mon, 14 Nov 2016 15:17:40 -0500
Message-ID: <CAHC9VhS0z8qDRBebkaQAu8p-SdXGak_x1T8XmtS=Ydr=nA5XkQ@mail.gmail.com>
References: <2e99896c655ae31ea481240692a720e9701b0a76.1478758980.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2e99896c655ae31ea481240692a720e9701b0a76.1478758980.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 10, 2016 at 1:41 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> The value (unsigned int)-1 is used as a sentinel to indicate the
> sessionID is unset.  Skip this value when the session_id value wraps.
>
> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/auditsc.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)

Since we haven't merged the session ID kernel patches into audit#next
yet, why don't you just squash this patch in with the session ID patch
and resubmit upstream in one nice neat patch.

> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 5abf1dc..e414dfa 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -2025,8 +2025,11 @@ int audit_set_loginuid(kuid_t loginuid)
>                 goto out;
>
>         /* are we setting or clearing? */
> -       if (uid_valid(loginuid))
> +       if (uid_valid(loginuid)) {
>                 sessionid = (unsigned int)atomic_inc_return(&session_id);
> +               if (unlikely(sessionid == (unsigned int)-1))
> +                       sessionid = (unsigned int)atomic_inc_return(&session_id);
> +       }
>
>         task->sessionid = sessionid;
>         task->loginuid = loginuid;
> --
> 1.7.1
>
> --
> Linux-audit mailing list
> Linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
> https://www.redhat.com/mailman/listinfo/linux-audit



-- 
paul moore
www.paul-moore.com
