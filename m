From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [patch 1/4][resend] fuse-procfs: proxy proc files
Date: Mon, 14 Sep 2009 22:38:58 +0200
Message-ID: <ac1c4bf20909141338p3e13c1d6sc71899b7859bd963@mail.gmail.com>
References: <20090904162556.407556958@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20090904165149.491603361@mai-009101017029.toulouse-stg.fr.ibm.com>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090904165149.491603361-+lpkiSBCrgqwGcPS5fe+fxcU4LlsiAD9x8DZ0lRKBDr1ENwx4SLHqw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Daniel,

right now I do not have any new tasks so I can take a look your patches
and... they won't to apply (patches from 2 to 4).
Can you send me your current procfs.c single file with patches added?

Thanks

-- 
K

2009/9/4 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

> This patch makes possible to mount the fuse-procfs on top of /proc
> and display the content of /proc via fuse.
>
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> ---
>  procfs.c |  246
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 246 insertions(+)
>
> Index: lxcfs/procfs.c
> ===================================================================
> --- /dev/null
> +++ lxcfs/procfs.c
> @@ -0,0 +1,246 @@
> +
> +#include <fuse.h>
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <libgen.h>
> +#include <errno.h>
> +#include <dirent.h>
> +#include <mntent.h>
> +#include <limits.h>
> +#include <fcntl.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <sys/param.h>
> +
> +enum {
> +       PROCFS_PROXY,
> +};
> +
> +struct procfs_info {
> +       DIR *procdir;
> +       DIR *subdir;
> +};
> +
> +struct proxy_file {
> +       int fd;
> +};
> +
> +struct procfs_file {
> +       int type;
> +       union {
> +               struct proxy_file proxy;
> +       } file;
> +};
> +
> +static int procfs_readlink(const char *path, char *buf, size_t bufsiz)
> +{
> +       struct fuse_context *context = fuse_get_context();
> +       struct procfs_info *fsinfo = context->private_data;
> +       char *bname = strchr(path, '/');
> +       int ret;
> +
> +       if (strcmp(path, "/"))
> +               bname += 1;
> +
> +       ret = readlinkat(dirfd(fsinfo->procdir), bname, buf, bufsiz);
> +       if (ret < 0)
> +               return -errno;
> +
> +       buf[ret] = '\0';
> +
> +       return 0;
> +}
> +
> +static int procfs_getattr(const char *path, struct stat *stbuf)
> +{
> +       struct fuse_context *context = fuse_get_context();
> +       struct procfs_info *fsinfo = context->private_data;
> +       char *bname = strchr(path, '/');
> +
> +       if (strcmp(path, "/"))
> +               bname += 1;
> +
> +       if (fstatat(dirfd(fsinfo->procdir), bname, stbuf,
> AT_SYMLINK_NOFOLLOW))
> +               return -errno;
> +
> +       return 0;
> +}
> +
> +static int procfs_open(const char *path, struct fuse_file_info *fi)
> +{
> +       struct fuse_context *context = fuse_get_context();
> +       struct procfs_info *fsinfo = context->private_data;
> +       char *bname = strchr(path, '/');
> +       struct procfs_file *pfile;
> +
> +       if (strcmp(path, "/"))
> +               bname += 1;
> +
> +       pfile = malloc(sizeof(*pfile));
> +       if (!pfile)
> +               return -ENOMEM;
> +
> +       pfile->type = PROCFS_PROXY;
> +       pfile->file.proxy.fd = openat(dirfd(fsinfo->procdir), bname,
> fi->flags);
> +       if (pfile->file.proxy.fd < 0) {
> +               free(pfile);
> +               return -errno;
> +       }
> +
> +       fi->fh = (typeof(fi->fh))pfile;
> +
> +       return 0;
> +}
> +
> +static int procfs_read(const char *path, char *buf, size_t size,
> +                     off_t offset, struct fuse_file_info *fi)
> +{
> +       int ret;
> +       struct procfs_file *pfile = (typeof(pfile))fi->fh;;
> +
> +       switch (pfile->type) {
> +
> +       case PROCFS_PROXY:
> +               ret = read(pfile->file.proxy.fd, buf, size);
> +               if (ret < 0)
> +                       return -errno;
> +               break;
> +       }
> +
> +       return ret;
> +}
> +
> +static int procfs_write(const char *path, const char *buf, size_t size,
> +                      off_t offset, struct fuse_file_info *fi)
> +{
> +       int ret;
> +       struct procfs_file *pfile = (typeof(pfile))fi->fh;;
> +
> +       switch (pfile->type) {
> +
> +       case PROCFS_PROXY:
> +               ret = write(pfile->file.proxy.fd, buf, size);
> +               if (ret < 0)
> +                       return -errno;
> +               break;
> +       }
> +
> +       return ret;
> +}
> +
> +static int procfs_release(const char *path, struct fuse_file_info *fi)
> +{
> +       struct procfs_file *pfile = (typeof(pfile))fi->fh;;
> +
> +       switch (pfile->type) {
> +
> +       case PROCFS_PROXY:
> +               if (close(pfile->file.proxy.fd))
> +                       return -errno;
> +               break;
> +       }
> +
> +       return 0;
> +}
> +
> +static int procfs_opendir(const char *path, struct fuse_file_info *fi)
> +{
> +       struct fuse_context *context = fuse_get_context();
> +       struct procfs_info *fsinfo = context->private_data;
> +       char *bname = strchr(path, '/');
> +       int fd;
> +
> +       if (!strcmp(path, "/")) {
> +               fsinfo->subdir = fsinfo->procdir;
> +               return 0;
> +       }
> +
> +       fd = openat(dirfd(fsinfo->procdir), bname + 1, O_DIRECTORY);
> +       if (fd < 0)
> +               return -errno;
> +
> +       fsinfo->subdir = fdopendir(fd);
> +
> +       return 0;
> +}
> +
> +static int procfs_readdir(const char *path, void *buf, fuse_fill_dir_t
> filler,
> +                        off_t offset, struct fuse_file_info *fi)
> +{
> +       struct fuse_context *context = fuse_get_context();
> +       struct procfs_info *fsinfo = context->private_data;
> +        struct dirent dirent, *direntp;
> +
> +       if (!offset)
> +               rewinddir(fsinfo->subdir);
> +
> +        while (!readdir_r(fsinfo->subdir, &dirent, &direntp) && direntp)
> +               if (filler(buf, direntp->d_name, NULL, offset++))
> +                       break;
> +
> +       return 0;
> +}
> +
> +static int procfs_releasedir(const char *path, struct fuse_file_info *fi)
> +{
> +       struct fuse_context *context = fuse_get_context();
> +       struct procfs_info *fsinfo = context->private_data;
> +       DIR *subdir = fsinfo->subdir;
> +
> +       fsinfo->subdir = NULL;
> +       if (subdir && subdir != fsinfo->procdir)
> +               closedir(subdir);
> +
> +       return 0;
> +}
> +
> +static void *procfs_init(struct fuse_conn_info *conn)
> +{
> +       struct procfs_info *fsinfo;
> +
> +       fsinfo = malloc(sizeof(*fsinfo));
> +       if (!fsinfo)
> +               return NULL;
> +
> +       fsinfo->procdir = opendir("/proc");
> +       if (!fsinfo->procdir)
> +               goto out_free_fsinfo;
> +
> +       fsinfo->subdir = NULL;
> +out:
> +       return fsinfo;
> +
> +out_free_fsinfo:
> +       free(fsinfo);
> +       fsinfo = NULL;
> +       goto out;
> +}
> +
> +static void procfs_destroy(void *private_data)
> +{
> +       struct procfs_info *fsinfo = private_data;
> +
> +       closedir(fsinfo->procdir);
> +       free(fsinfo);
> +}
> +
> +static struct fuse_operations procfs_ops = {
> +       .readlink   = procfs_readlink,
> +       .getattr    = procfs_getattr,
> +       .open       = procfs_open,
> +       .read       = procfs_read,
> +       .write      = procfs_write,
> +       .opendir    = procfs_opendir,
> +       .releasedir = procfs_releasedir,
> +       .readdir    = procfs_readdir,
> +       .release    = procfs_release,
> +       .init       = procfs_init,
> +       .destroy    = procfs_destroy,
> +};
> +
> +int main(int argc, char *argv[])
> +{
> +       return fuse_main(argc, argv, &procfs_ops, NULL);
> +}
>
>
