From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH review 03/18] umount: Disallow unprivileged mount force
Date: Fri, 12 Dec 2014 15:07:28 -0800
Message-ID: <CALCETrV2kBfzypMbYKgxJ4BqB6yBG6Xvo=sZy3tvTng5ZRvAKQ__16302.538480568$1418425683$gmane$org@mail.gmail.com>
References: <87k31wzehb.fsf@x220.int.ebiederm.org>
	<1418424509-22389-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1418424509-22389-3-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 12, 2014 at 2:48 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Forced unmount affects not just the mount namespace but the underlying
> superblock as well.  Restrict forced unmount to the global root user
> for now.  Otherwise it becomes possible a user in a less privileged
> mount namespace to force the shutdown of a superblock of a filesystem
> in a more privileged mount namespace, allowing a DOS attack on root.
>

I thought I already fixed this.  Did I miss part of it?

> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 3a1a87dc33df..43b16af8af30 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1544,6 +1544,9 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
>                 goto dput_and_out;
>         if (mnt->mnt.mnt_flags & MNT_LOCKED)
>                 goto dput_and_out;
> +       retval = -EPERM;
> +       if (flags & MNT_FORCE && !capable(CAP_SYS_ADMIN))
> +               goto dput_and_out;
>
>         retval = do_umount(mnt, flags);
>  dput_and_out:
> --
> 1.9.1
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
