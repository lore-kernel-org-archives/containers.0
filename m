From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Fri, 15 Aug 2014 11:41:21 -0700
Message-ID: <CALCETrXh4JLWDUmqC6knh6g0fyEMGQtajoaHzZdMaqsniiEc5Q__26604.7245743268$1408128117$gmane$org@mail.gmail.com>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<53EAD180.4010906@amacapital.net>
	<87sil1nhut.fsf@x220.int.ebiederm.org>
	<CAOP=4widH1rMZ1O=hzAT+M_8exdzRPA8pJ+wH29AQ9L0ogu9nw@mail.gmail.com>
	<87tx5ghekp.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tx5ghekp.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 13, 2014 at 3:24 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org> writes:
>
>> On Tue, Aug 12, 2014 at 9:17 PM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:

> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Wed, 13 Aug 2014 01:33:38 -0700
> Subject: [PATCH] mnt: Implicitly add MNT_NODEV on remount as we do on mount
>
> Now that remount is properly enforcing the rule that you can't
> remove nodev at least sandstorm.io is breaking when performing
> a remount.
>
> It turns out that there is an easy intuitive solution implicitly
> add nodev on remount under the same conditions that we do on mount.
>
> Update the regression test for remounts to verify that this new
> addition does not regress either.

Tested-but-disliked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>

Quoting Alan Cox [1]:

Lying to apps generally ends up like children lying to parents - the
lie gets more complicated to keep up each case you find until it
breaks.

The kernel was unnecessarily fudging mount flags, and it broke,
because the fudge didn't go far enough.  This extends the fudge.
Let's just delete it instead.

--Andy

[1] https://lwn.net/Articles/608435/

>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c                                     |  9 ++++
>  .../selftests/mount/unprivileged-remount-test.c    | 51 ++++++++++++----------
>  2 files changed, 36 insertions(+), 24 deletions(-)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 7886176232c1..0f158300c866 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1934,6 +1934,15 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
>         if (path->dentry != path->mnt->mnt_root)
>                 return -EINVAL;
>
> +       /* Only in special cases allow devices from mounts created
> +        * outside the initial user namespace.
> +        */
> +       if ((mnt->mnt_ns->user_ns != &init_user_ns) &&
> +           !(sb->s_type->fs_flags & FS_USERNS_DEV_MOUNT)) {
> +               flags |= MS_NODEV;
> +               mnt_flags |= MNT_NODEV;
> +       }
> +
>         /* Don't allow changing of locked mnt flags.
>          *
>          * No locks need to be held here while testing the various
> diff --git a/tools/testing/selftests/mount/unprivileged-remount-test.c b/tools/testing/selftests/mount/unprivileged-remount-test.c
> index 1b3ff2fda4d0..6d408c155e0f 100644
> --- a/tools/testing/selftests/mount/unprivileged-remount-test.c
> +++ b/tools/testing/selftests/mount/unprivileged-remount-test.c
> @@ -118,7 +118,8 @@ static void create_and_enter_userns(void)
>  }
>
>  static
> -bool test_unpriv_remount(int mount_flags, int remount_flags, int invalid_flags)
> +bool test_unpriv_remount(const char *fstype, const char *mount_options,
> +                        int mount_flags, int remount_flags, int invalid_flags)
>  {
>         pid_t child;
>
> @@ -151,9 +152,11 @@ bool test_unpriv_remount(int mount_flags, int remount_flags, int invalid_flags)
>                         strerror(errno));
>         }
>
> -       if (mount("testing", "/tmp", "ramfs", mount_flags, NULL) != 0) {
> -               die("mount of /tmp failed: %s\n",
> -                       strerror(errno));
> +       if (mount("testing", "/tmp", fstype, mount_flags, mount_options) != 0) {
> +               die("mount of %s with options '%s' on /tmp failed: %s\n",
> +                   fstype,
> +                   mount_options? mount_options : "",
> +                   strerror(errno));
>         }
>
>         create_and_enter_userns();
> @@ -181,60 +184,60 @@ bool test_unpriv_remount(int mount_flags, int remount_flags, int invalid_flags)
>
>  static bool test_unpriv_remount_simple(int mount_flags)
>  {
> -       return test_unpriv_remount(mount_flags, mount_flags, 0);
> +       return test_unpriv_remount("ramfs", NULL, mount_flags, mount_flags, 0);
>  }
>
>  static bool test_unpriv_remount_atime(int mount_flags, int invalid_flags)
>  {
> -       return test_unpriv_remount(mount_flags, mount_flags, invalid_flags);
> +       return test_unpriv_remount("ramfs", NULL, mount_flags, mount_flags,
> +                                  invalid_flags);
>  }
>
>  int main(int argc, char **argv)
>  {
> -       if (!test_unpriv_remount_simple(MS_RDONLY|MS_NODEV)) {
> +       if (!test_unpriv_remount_simple(MS_RDONLY)) {
>                 die("MS_RDONLY malfunctions\n");
>         }
> -       if (!test_unpriv_remount_simple(MS_NODEV)) {
> +       if (!test_unpriv_remount("devpts", "newinstance", MS_NODEV, MS_NODEV, 0)) {
>                 die("MS_NODEV malfunctions\n");
>         }
> -       if (!test_unpriv_remount_simple(MS_NOSUID|MS_NODEV)) {
> +       if (!test_unpriv_remount_simple(MS_NOSUID)) {
>                 die("MS_NOSUID malfunctions\n");
>         }
> -       if (!test_unpriv_remount_simple(MS_NOEXEC|MS_NODEV)) {
> +       if (!test_unpriv_remount_simple(MS_NOEXEC)) {
>                 die("MS_NOEXEC malfunctions\n");
>         }
> -       if (!test_unpriv_remount_atime(MS_RELATIME|MS_NODEV,
> -                                      MS_NOATIME|MS_NODEV))
> +       if (!test_unpriv_remount_atime(MS_RELATIME,
> +                                      MS_NOATIME))
>         {
>                 die("MS_RELATIME malfunctions\n");
>         }
> -       if (!test_unpriv_remount_atime(MS_STRICTATIME|MS_NODEV,
> -                                      MS_NOATIME|MS_NODEV))
> +       if (!test_unpriv_remount_atime(MS_STRICTATIME,
> +                                      MS_NOATIME))
>         {
>                 die("MS_STRICTATIME malfunctions\n");
>         }
> -       if (!test_unpriv_remount_atime(MS_NOATIME|MS_NODEV,
> -                                      MS_STRICTATIME|MS_NODEV))
> +       if (!test_unpriv_remount_atime(MS_NOATIME,
> +                                      MS_STRICTATIME))
>         {
>                 die("MS_RELATIME malfunctions\n");
>         }
> -       if (!test_unpriv_remount_atime(MS_RELATIME|MS_NODIRATIME|MS_NODEV,
> -                                      MS_NOATIME|MS_NODEV))
> +       if (!test_unpriv_remount_atime(MS_RELATIME|MS_NODIRATIME,
> +                                      MS_NOATIME))
>         {
>                 die("MS_RELATIME malfunctions\n");
>         }
> -       if (!test_unpriv_remount_atime(MS_STRICTATIME|MS_NODIRATIME|MS_NODEV,
> -                                      MS_NOATIME|MS_NODEV))
> +       if (!test_unpriv_remount_atime(MS_STRICTATIME|MS_NODIRATIME,
> +                                      MS_NOATIME))
>         {
>                 die("MS_RELATIME malfunctions\n");
>         }
> -       if (!test_unpriv_remount_atime(MS_NOATIME|MS_NODIRATIME|MS_NODEV,
> -                                      MS_STRICTATIME|MS_NODEV))
> +       if (!test_unpriv_remount_atime(MS_NOATIME|MS_NODIRATIME,
> +                                      MS_STRICTATIME))
>         {
>                 die("MS_RELATIME malfunctions\n");
>         }
> -       if (!test_unpriv_remount(MS_STRICTATIME|MS_NODEV, MS_NODEV,
> -                                MS_NOATIME|MS_NODEV))
> +       if (!test_unpriv_remount("ramfs", NULL, MS_STRICTATIME, 0, MS_NOATIME))
>         {
>                 die("Default atime malfunctions\n");
>         }
> --
> 1.9.1
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
