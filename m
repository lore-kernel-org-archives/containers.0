From: Matthew Helsley <matt.helsley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Patch v3 2/3] binfmt_misc: add persistent opened binary handler
	for containers
Date: Wed, 13 Apr 2016 14:02:17 -0700
Message-ID: <CA+RrjuV3VOjLRMm_bnk-9CKF_3NqX6DVNBgAUVpxW0+NE0bLHg@mail.gmail.com>
References: <1459436046.2958.21.camel@HansenPartnership.com>
	<1459436179.2958.23.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1459436179.2958.23.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

With the current model it's possible to upgrade the emulator binary and
have new exec()s utilize the upgraded binary. I think this flag would
prevent that from happening until userspace removed the binfmt_misc entry
and re-added it. That creates a race where the entry would be missing for a
time and exec() could fail unexpectedly. It looks like the register path in
binfmt_misc fails if the entry already exists so there's no race-free way
to change or replace a registered binfmt_misc entry.

If binfmt_misc could hold a reference to the mount namespace used when
registering the handler then we wouldn't need to hold the filp reference on
the emulator binary and upgrading would not be affected. Then modifying the
entry would never be necessary AFAICS. I think that *might* be better so
long there's no circular reference between the mount namespace reference
and the binfmt_misc procfs code that I haven't accounted for.

Alternately, perhaps you could keep the filp and add a way to
modify/replace binfmt_misc entries without the race.

Cheers,
    -Matt Helsley

On Thu, Mar 31, 2016 at 7:56 AM, James Bottomley <
James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:

> This patch adds a new flag 'F' to the binfmt handlers.  If you pass in
> 'F' the binary that runs the emulation will be opened immediately and
> in future, will be cloned from the open file.
>
> The net effect is that the handler survives both changeroots and mount
> namespace changes, making it easy to work with foreign architecture
> containers without contaminating the container image with the
> emulator.
>
> Signed-off-by: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  fs/binfmt_misc.c | 41 +++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 39 insertions(+), 2 deletions(-)
>
> diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
> index 3a3ced7..8a108c4 100644
> --- a/fs/binfmt_misc.c
> +++ b/fs/binfmt_misc.c
> @@ -26,6 +26,8 @@
>  #include <linux/fs.h>
>  #include <linux/uaccess.h>
>
> +#include "internal.h"
> +
>  #ifdef DEBUG
>  # define USE_DEBUG 1
>  #else
> @@ -43,6 +45,7 @@ enum {Enabled, Magic};
>  #define MISC_FMT_PRESERVE_ARGV0 (1 << 31)
>  #define MISC_FMT_OPEN_BINARY (1 << 30)
>  #define MISC_FMT_CREDENTIALS (1 << 29)
> +#define MISC_FMT_OPEN_FILE (1 << 28)
>
>  typedef struct {
>         struct list_head list;
> @@ -54,6 +57,7 @@ typedef struct {
>         char *interpreter;              /* filename of interpreter */
>         char *name;
>         struct dentry *dentry;
> +       struct file *interp_file;
>  } Node;
>
>  static DEFINE_RWLOCK(entries_lock);
> @@ -201,7 +205,13 @@ static int load_misc_binary(struct linux_binprm *bprm)
>         if (retval < 0)
>                 goto error;
>
> -       interp_file = open_exec(iname);
> +       if (fmt->flags & MISC_FMT_OPEN_FILE && fmt->interp_file) {
> +               interp_file = filp_clone_open(fmt->interp_file);
> +               if (!IS_ERR(interp_file))
> +                       deny_write_access(interp_file);
> +       } else {
> +               interp_file = open_exec(iname);
> +       }
>         retval = PTR_ERR(interp_file);
>         if (IS_ERR(interp_file))
>                 goto error;
> @@ -285,6 +295,11 @@ static char *check_special_flags(char *sfs, Node *e)
>                         e->flags |= (MISC_FMT_CREDENTIALS |
>                                         MISC_FMT_OPEN_BINARY);
>                         break;
> +               case 'F':
> +                       pr_debug("register: flag: F: open interpreter file
> now\n");
> +                       p++;
> +                       e->flags |= MISC_FMT_OPEN_FILE;
> +                       break;
>                 default:
>                         cont = 0;
>                 }
> @@ -543,6 +558,8 @@ static void entry_status(Node *e, char *page)
>                 *dp++ = 'O';
>         if (e->flags & MISC_FMT_CREDENTIALS)
>                 *dp++ = 'C';
> +       if (e->flags & MISC_FMT_OPEN_FILE)
> +               *dp++ = 'F';
>         *dp++ = '\n';
>
>         if (!test_bit(Magic, &e->flags)) {
> @@ -590,6 +607,11 @@ static void kill_node(Node *e)
>         }
>         write_unlock(&entries_lock);
>
> +       if ((e->flags & MISC_FMT_OPEN_FILE) && e->interp_file) {
> +               filp_close(e->interp_file, NULL);
> +               e->interp_file = NULL;
> +       }
> +
>         if (dentry) {
>                 drop_nlink(d_inode(dentry));
>                 d_drop(dentry);
> @@ -698,6 +720,21 @@ static ssize_t bm_register_write(struct file *file,
> const char __user *buffer,
>                 goto out2;
>         }
>
> +       if (e->flags & MISC_FMT_OPEN_FILE) {
> +               struct file *f;
> +
> +               f = open_exec(e->interpreter);
> +               if (IS_ERR(f)) {
> +                       err = PTR_ERR(f);
> +                       pr_notice("register: failed to install interpreter
> file %s\n", e->interpreter);
> +                       simple_release_fs(&bm_mnt, &entry_count);
> +                       iput(inode);
> +                       inode = NULL;
> +                       goto out2;
> +               }
> +               e->interp_file = f;
> +       }
> +
>         e->dentry = dget(dentry);
>         inode->i_private = e;
>         inode->i_fop = &bm_entry_operations;
> @@ -716,7 +753,7 @@ out:
>
>         if (err) {
>                 kfree(e);
> -               return -EINVAL;
> +               return err;
>         }
>         return count;
>  }
> --
> 2.6.2
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>
