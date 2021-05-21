Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 653B870
	for <containers@lists.linux.dev>; Fri, 21 May 2021 15:45:38 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 35C1D61401;
	Fri, 21 May 2021 15:45:34 +0000 (UTC)
Date: Fri, 21 May 2021 17:45:32 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Sargun Dhillon <sargun@sargun.me>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>,
	Andy Lutomirski <luto@kernel.org>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Mauricio =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@linux.microsoft.com>
Subject: Re: [PATCH v2 3/4] seccomp: Support atomic "addfd + send reply"
Message-ID: <20210521154532.utttvofngdg6qeob@wittgenstein>
References: <20210517193908.3113-1-sargun@sargun.me>
 <20210517193908.3113-4-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20210517193908.3113-4-sargun@sargun.me>

On Mon, May 17, 2021 at 12:39:07PM -0700, Sargun Dhillon wrote:
> From: Rodrigo Campos <rodrigo@kinvolk.io>
> 
> Alban Crequy reported a race condition userspace faces when we want to
> add some fds and make the syscall return them[1] using seccomp notify.
> 
> The problem is that currently two different ioctl() calls are needed by
> the process handling the syscalls (agent) for another userspace process
> (target): SECCOMP_IOCTL_NOTIF_ADDFD to allocate the fd and
> SECCOMP_IOCTL_NOTIF_SEND to return that value. Therefore, it is possible
> for the agent to do the first ioctl to add a file descriptor but the
> target is interrupted (EINTR) before the agent does the second ioctl()
> call.
> 
> This patch adds a flag to the ADDFD ioctl() so it adds the fd and
> returns that value atomically to the target program, as suggested by
> Kees Cook[2]. This is done by simply allowing
> seccomp_do_user_notification() to add the fd and return it in this case.
> Therefore, in this case the target wakes up from the wait in
> seccomp_do_user_notification() either to interrupt the syscall or to add
> the fd and return it.
> 
> This "allocate an fd and return" functionality is useful for syscalls
> that return a file descriptor only, like connect(2). Other syscalls that
> return a file descriptor but not as return value (or return more than
> one fd), like socketpair(), pipe(), recvmsg with SCM_RIGHTs, will not
> work with this flag.
> 
> This effectively combines SECCOMP_IOCTL_NOTIF_ADDFD and
> SECCOMP_IOCTL_NOTIF_SEND into an atomic opteration. The notification's
> return value, nor error can be set by the user. Upon successful invocation
> of the SECCOMP_IOCTL_NOTIF_ADDFD ioctl with the SECCOMP_ADDFD_FLAG_SEND
> flag, the notifying process's errno will be 0, and the return value will
> be the file descriptor number that was installed.
> 
> [1]: https://lore.kernel.org/lkml/CADZs7q4sw71iNHmV8EOOXhUKJMORPzF7thraxZYddTZsxta-KQ@mail.gmail.com/
> [2]: https://lore.kernel.org/lkml/202012011322.26DCBC64F2@keescook/
> 
> Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> Acked-by: Tycho Andersen <tycho@tycho.pizza>
> ---
>  .../userspace-api/seccomp_filter.rst          | 12 +++++
>  include/uapi/linux/seccomp.h                  |  1 +
>  kernel/seccomp.c                              | 49 +++++++++++++++++--
>  3 files changed, 58 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/userspace-api/seccomp_filter.rst b/Documentation/userspace-api/seccomp_filter.rst
> index 6efb41cc8072..d61219889e49 100644
> --- a/Documentation/userspace-api/seccomp_filter.rst
> +++ b/Documentation/userspace-api/seccomp_filter.rst
> @@ -259,6 +259,18 @@ and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a response, indicating what should be
>  returned to userspace. The ``id`` member of ``struct seccomp_notif_resp`` should
>  be the same ``id`` as in ``struct seccomp_notif``.
>  
> +Userspace can also add file descriptors to the notifying process via
> +``ioctl(SECCOMP_IOCTL_NOTIF_ADDFD)``. The ``id`` member of
> +``struct seccomp_notif_addfd`` should be the same ``id`` as in
> +``struct seccomp_notif``. The ``newfd_flags`` flag may be used to set flags
> +like O_EXEC on the file descriptor in the notifying process. If the supervisor

nit:
s/O_EXEC/O_CLOEXEC/
