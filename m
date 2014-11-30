From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [CFT][PATCH] mnt: Implicitly add MNT_NODEV on remount when it was
	implicitly added by mount
Date: Sat, 29 Nov 2014 16:07:48 -0800
Message-ID: <CALCETrX=B+0PVe8fhvCEyqBGD-D1wLJPd6CrqPn6LCGYgzxPMg@mail.gmail.com>
References: <20141127101105.GA30605@linux-rxt1.site>
	<87k32dlicc.fsf@x220.int.ebiederm.org>
	<87egsllia3.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87egsllia3.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, joeyli <jlee-IBi9RG/b67k@public.gmane.org>, Jim Fehlig <jfehlig-IBi9RG/b67k@public.gmane.org>, Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>
List-Id: containers.vger.kernel.org

On Nov 29, 2014 4:06 PM, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
>
> Now that remount is properly enforcing the rule that you can't remove
> nodev at leastsandstorm.iois breaking when performing a remount.
>
> It turns out that there is an easy intuitive solution implicitly
> add nodev on remount when nodev was implicitly added on mount.

Is this intended to be a permanent fix or are you planning on
replacing it with something closer to my version for 3.19?

http://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=userns/fix_magic_nodev&id=bf8b198add82a249d6da4ecf280c30a0865637f6

I still think that the implicit nodev behavior is a bad idea in general.

--Andy

>
> Cc:stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 5b66b2b3624d..3a1a87dc33df 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2098,7 +2098,13 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
>         }
>         if ((mnt->mnt.mnt_flags & MNT_LOCK_NODEV) &&
>             !(mnt_flags & MNT_NODEV)) {
> -               return -EPERM;
> +               /* Was the nodev implicitly added in mount? */
> +               if ((mnt->mnt_ns->user_ns != &init_user_ns) &&
> +                   !(sb->s_type->fs_flags & FS_USERNS_DEV_MOUNT)) {
> +                       mnt_flags |= MNT_NODEV;
> +               } else {
> +                       return -EPERM;
> +               }
>         }
>         if ((mnt->mnt.mnt_flags & MNT_LOCK_NOSUID) &&
>             !(mnt_flags & MNT_NOSUID)) {
> --
> 1.9.1
>
