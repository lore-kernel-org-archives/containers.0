From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 29/43] userns: Convert stat to return values mapped
	from kuids and kgids
Date: Wed, 18 Apr 2012 19:03:53 +0000
Message-ID: <20120418190353.GG5186__21191.9374800802$1334775791$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-29-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-29-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> - Store uids and gids with kuid_t and kgid_t in struct kstat
> - Convert uid and gids to userspace usable values with
>   from_kuid and from_kgid
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  arch/arm/kernel/sys_oabi-compat.c |    4 ++--
>  arch/parisc/hpux/fs.c             |    4 ++--
>  arch/s390/kernel/compat_linux.c   |    4 ++--
>  arch/sparc/kernel/sys_sparc32.c   |    4 ++--
>  arch/x86/ia32/sys_ia32.c          |    4 ++--
>  fs/compat.c                       |    4 ++--
>  fs/stat.c                         |    8 ++++----
>  include/linux/stat.h              |    5 +++--
>  8 files changed, 19 insertions(+), 18 deletions(-)
> 
> diff --git a/arch/arm/kernel/sys_oabi-compat.c b/arch/arm/kernel/sys_oabi-compat.c
> index af0aaeb..3e94811 100644
> --- a/arch/arm/kernel/sys_oabi-compat.c
> +++ b/arch/arm/kernel/sys_oabi-compat.c
> @@ -124,8 +124,8 @@ static long cp_oldabi_stat64(struct kstat *stat,
>  	tmp.__st_ino = stat->ino;
>  	tmp.st_mode = stat->mode;
>  	tmp.st_nlink = stat->nlink;
> -	tmp.st_uid = stat->uid;
> -	tmp.st_gid = stat->gid;
> +	tmp.st_uid = from_kuid_munged(current_user_ns(), stat->uid);
> +	tmp.st_gid = from_kgid_munged(current_user_ns(), stat->gid);
>  	tmp.st_rdev = huge_encode_dev(stat->rdev);
>  	tmp.st_size = stat->size;
>  	tmp.st_blocks = stat->blocks;
> diff --git a/arch/parisc/hpux/fs.c b/arch/parisc/hpux/fs.c
> index 0dc8543..c71eb6c 100644
> --- a/arch/parisc/hpux/fs.c
> +++ b/arch/parisc/hpux/fs.c
> @@ -159,8 +159,8 @@ static int cp_hpux_stat(struct kstat *stat, struct hpux_stat64 __user *statbuf)
>  	tmp.st_ino = stat->ino;
>  	tmp.st_mode = stat->mode;
>  	tmp.st_nlink = stat->nlink;
> -	tmp.st_uid = stat->uid;
> -	tmp.st_gid = stat->gid;
> +	tmp.st_uid = from_kuid_munged(current_user_ns(), stat->uid);
> +	tmp.st_gid = from_kgid_munged(current_user_ns(), stat->gid);
>  	tmp.st_rdev = new_encode_dev(stat->rdev);
>  	tmp.st_size = stat->size;
>  	tmp.st_atime = stat->atime.tv_sec;
> diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
> index 5baac18..80ab23a 100644
> --- a/arch/s390/kernel/compat_linux.c
> +++ b/arch/s390/kernel/compat_linux.c
> @@ -546,8 +546,8 @@ static int cp_stat64(struct stat64_emu31 __user *ubuf, struct kstat *stat)
>  	tmp.__st_ino = (u32)stat->ino;
>  	tmp.st_mode = stat->mode;
>  	tmp.st_nlink = (unsigned int)stat->nlink;
> -	tmp.st_uid = stat->uid;
> -	tmp.st_gid = stat->gid;
> +	tmp.st_uid = from_kuid_munged(current_user_ns(), stat->uid);
> +	tmp.st_gid = from_kgid_munged(current_user_ns(), stat->gid);
>  	tmp.st_rdev = huge_encode_dev(stat->rdev);
>  	tmp.st_size = stat->size;
>  	tmp.st_blksize = (u32)stat->blksize;
> diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
> index 29c478f..f739233 100644
> --- a/arch/sparc/kernel/sys_sparc32.c
> +++ b/arch/sparc/kernel/sys_sparc32.c
> @@ -139,8 +139,8 @@ static int cp_compat_stat64(struct kstat *stat,
>  	err |= put_user(stat->ino, &statbuf->st_ino);
>  	err |= put_user(stat->mode, &statbuf->st_mode);
>  	err |= put_user(stat->nlink, &statbuf->st_nlink);
> -	err |= put_user(stat->uid, &statbuf->st_uid);
> -	err |= put_user(stat->gid, &statbuf->st_gid);
> +	err |= put_user(from_kuid_munged(current_user_ns(), stat->uid), &statbuf->st_uid);
> +	err |= put_user(from_kgid_munged(current_user_ns(), stat->gid), &statbuf->st_gid);
>  	err |= put_user(huge_encode_dev(stat->rdev), &statbuf->st_rdev);
>  	err |= put_user(0, (unsigned long __user *) &statbuf->__pad3[0]);
>  	err |= put_user(stat->size, &statbuf->st_size);
> diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
> index aec2202..d5c820a 100644
> --- a/arch/x86/ia32/sys_ia32.c
> +++ b/arch/x86/ia32/sys_ia32.c
> @@ -71,8 +71,8 @@ static int cp_stat64(struct stat64 __user *ubuf, struct kstat *stat)
>  {
>  	typeof(ubuf->st_uid) uid = 0;
>  	typeof(ubuf->st_gid) gid = 0;
> -	SET_UID(uid, stat->uid);
> -	SET_GID(gid, stat->gid);
> +	SET_UID(uid, from_kuid_munged(current_user_ns(), stat->uid));
> +	SET_GID(gid, from_kgid_munged(current_user_ns(), stat->gid));
>  	if (!access_ok(VERIFY_WRITE, ubuf, sizeof(struct stat64)) ||
>  	    __put_user(huge_encode_dev(stat->dev), &ubuf->st_dev) ||
>  	    __put_user(stat->ino, &ubuf->__st_ino) ||
> diff --git a/fs/compat.c b/fs/compat.c
> index f2944ac..0781e61 100644
> --- a/fs/compat.c
> +++ b/fs/compat.c
> @@ -144,8 +144,8 @@ static int cp_compat_stat(struct kstat *stat, struct compat_stat __user *ubuf)
>  	tmp.st_nlink = stat->nlink;
>  	if (tmp.st_nlink != stat->nlink)
>  		return -EOVERFLOW;
> -	SET_UID(tmp.st_uid, stat->uid);
> -	SET_GID(tmp.st_gid, stat->gid);
> +	SET_UID(tmp.st_uid, from_kuid_munged(current_user_ns(), stat->uid));
> +	SET_GID(tmp.st_gid, from_kgid_munged(current_user_ns(), stat->gid));
>  	tmp.st_rdev = old_encode_dev(stat->rdev);
>  	if ((u64) stat->size > MAX_NON_LFS)
>  		return -EOVERFLOW;
> diff --git a/fs/stat.c b/fs/stat.c
> index c733dc5..fca17f9 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -137,8 +137,8 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
>  	tmp.st_nlink = stat->nlink;
>  	if (tmp.st_nlink != stat->nlink)
>  		return -EOVERFLOW;
> -	SET_UID(tmp.st_uid, stat->uid);
> -	SET_GID(tmp.st_gid, stat->gid);
> +	SET_UID(tmp.st_uid, from_kuid_munged(current_user_ns(), stat->uid));
> +	SET_GID(tmp.st_gid, from_kgid_munged(current_user_ns(), stat->gid));
>  	tmp.st_rdev = old_encode_dev(stat->rdev);
>  #if BITS_PER_LONG == 32
>  	if (stat->size > MAX_NON_LFS)
> @@ -215,8 +215,8 @@ static int cp_new_stat(struct kstat *stat, struct stat __user *statbuf)
>  	tmp.st_nlink = stat->nlink;
>  	if (tmp.st_nlink != stat->nlink)
>  		return -EOVERFLOW;
> -	SET_UID(tmp.st_uid, stat->uid);
> -	SET_GID(tmp.st_gid, stat->gid);
> +	SET_UID(tmp.st_uid, from_kuid_munged(current_user_ns(), stat->uid));
> +	SET_GID(tmp.st_gid, from_kgid_munged(current_user_ns(), stat->gid));
>  #if BITS_PER_LONG == 32
>  	tmp.st_rdev = old_encode_dev(stat->rdev);
>  #else
> diff --git a/include/linux/stat.h b/include/linux/stat.h
> index 611c398..4613240 100644
> --- a/include/linux/stat.h
> +++ b/include/linux/stat.h
> @@ -58,14 +58,15 @@
>  
>  #include <linux/types.h>
>  #include <linux/time.h>
> +#include <linux/uidgid.h>
>  
>  struct kstat {
>  	u64		ino;
>  	dev_t		dev;
>  	umode_t		mode;
>  	unsigned int	nlink;
> -	uid_t		uid;
> -	gid_t		gid;
> +	kuid_t		uid;
> +	kgid_t		gid;
>  	dev_t		rdev;
>  	loff_t		size;
>  	struct timespec  atime;
> -- 
> 1.7.2.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
