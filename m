From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/4] userns: Require CAP_SYS_ADMIN for most uses of setns.
Date: Mon, 17 Dec 2012 11:03:56 -0800
Message-ID: <CALCETrVaj0yzhGau0M+9Dd2AX+wu4anFWCfAG=Y6NnG1g-3LBg__29231.885521631$1355771078$gmane$org@mail.gmail.com>
References: <87txroxpgq.fsf@xmission.com> <87hanoxpdh.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87hanoxpdh.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 14, 2012 at 2:03 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> found a nasty little bug in
> the permissions of setns.  With unprivileged user namespaces it
> became possible to create new namespaces without privilege.
>
> However the setns calls were relaxed to only require CAP_SYS_ADMIN in
> the user nameapce of the targed namespace.
>
> Which made the following nasty sequence possible.
>
> pid = clone(CLONE_NEWUSER | CLONE_NEWNS);
> if (pid == 0) { /* child */
>         system("mount --bind /home/me/passwd /etc/passwd");
> }
> else if (pid != 0) { /* parent */
>         char path[PATH_MAX];
>         snprintf(path, sizeof(path), "/proc/%u/ns/mnt");
>         fd = open(path, O_RDONLY);
>         setns(fd, 0);
>         system("su -");
> }
>
> Prevent this possibility by requiring CAP_SYS_ADMIN
> in the current user namespace when joing all but the user namespace.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c           |    3 ++-
>  ipc/namespace.c          |    3 ++-
>  kernel/pid_namespace.c   |    3 ++-
>  kernel/utsname.c         |    3 ++-
>  net/core/net_namespace.c |    3 ++-
>  5 files changed, 10 insertions(+), 5 deletions(-)

Acked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
