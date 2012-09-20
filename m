From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 01/25] userns: Convert fat to use kuid/kgid where
	appropriate
Date: Thu, 20 Sep 2012 05:04:02 -0700
Message-ID: <87vcf8vr2l.fsf@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
	<87pq5gx60i.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87pq5gx60i.fsf-x/W9pkDDSe1TgC2z9Sl/nXf5DAMn2ifp@public.gmane.org> (OGAWA Hirofumi's message of
	"Thu, 20 Sep 2012 20:55:57 +0900")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: OGAWA Hirofumi <hirofumi-UIVanBePwB70ZhReMnHkpc8NsWr+9BEh@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

OGAWA Hirofumi <hirofumi-UIVanBePwB70ZhReMnHkpc8NsWr+9BEh@public.gmane.org> writes:

> "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> writes:
>
>>  struct fat_mount_options {
>> -	uid_t fs_uid;
>> -	gid_t fs_gid;
>> +	kuid_t fs_uid;
>> +	kgid_t fs_gid;
>>  	unsigned short fs_fmask;
>>  	unsigned short fs_dmask;
>>  	unsigned short codepage;  /* Codepage for shortname conversions */
>
> I'm not reading this thread, so I may be wrong though. Doesn't this need
> to initialize opts->fs_uid/fs_gid by GLOBAL_ROOT_UID/GID?

Good question.

At the start of parse_options there is:

static int parse_options(struct super_block *sb, char *options, int is_vfat,
			 int silent, int *debug, struct fat_mount_options *opts)
{
	char *p;
	substring_t args[MAX_OPT_ARGS];
	int option;
	char *iocharset;

	opts->isvfat = is_vfat;

	opts->fs_uid = current_uid();
	opts->fs_gid = current_gid();

So there should be no problems with initialization.

Eric

>> diff --git a/fs/fat/file.c b/fs/fat/file.c
>> index e007b8b..a62e0ec 100644
>> --- a/fs/fat/file.c
>> +++ b/fs/fat/file.c
>> @@ -352,7 +352,7 @@ static int fat_allow_set_time(struct msdos_sb_info *sbi, struct inode *inode)
>>  {
>>  	umode_t allow_utime = sbi->options.allow_utime;
>>  
>> -	if (current_fsuid() != inode->i_uid) {
>> +	if (!uid_eq(current_fsuid(), inode->i_uid)) {
>>  		if (in_group_p(inode->i_gid))
>>  			allow_utime >>= 3;
>>  		if (allow_utime & MAY_WRITE)
>> @@ -407,9 +407,9 @@ int fat_setattr(struct dentry *dentry, struct iattr *attr)
>>  	}
>>  
>>  	if (((attr->ia_valid & ATTR_UID) &&
>> -	     (attr->ia_uid != sbi->options.fs_uid)) ||
>> +	     (!uid_eq(attr->ia_uid, sbi->options.fs_uid))) ||
>>  	    ((attr->ia_valid & ATTR_GID) &&
>> -	     (attr->ia_gid != sbi->options.fs_gid)) ||
>> +	     (!gid_eq(attr->ia_gid, sbi->options.fs_gid))) ||
>>  	    ((attr->ia_valid & ATTR_MODE) &&
>>  	     (attr->ia_mode & ~FAT_VALID_MODE)))
>>  		error = -EPERM;
>> diff --git a/fs/fat/inode.c b/fs/fat/inode.c
>> index 05e897f..47d9eb0 100644
>> --- a/fs/fat/inode.c
>> +++ b/fs/fat/inode.c
>> @@ -791,10 +791,12 @@ static int fat_show_options(struct seq_file *m, struct dentry *root)
>>  	struct fat_mount_options *opts = &sbi->options;
>>  	int isvfat = opts->isvfat;
>>  
>> -	if (opts->fs_uid != 0)
>> -		seq_printf(m, ",uid=%u", opts->fs_uid);
>> -	if (opts->fs_gid != 0)
>> -		seq_printf(m, ",gid=%u", opts->fs_gid);
>> +	if (!uid_eq(opts->fs_uid, GLOBAL_ROOT_UID))
>> +		seq_printf(m, ",uid=%u",
>> +				from_kuid_munged(&init_user_ns, opts->fs_uid));
>> +	if (!gid_eq(opts->fs_gid, GLOBAL_ROOT_GID))
>> +		seq_printf(m, ",gid=%u",
>> +				from_kgid_munged(&init_user_ns, opts->fs_gid));
>>  	seq_printf(m, ",fmask=%04o", opts->fs_fmask);
>>  	seq_printf(m, ",dmask=%04o", opts->fs_dmask);
>>  	if (opts->allow_utime)
>> @@ -1037,12 +1039,16 @@ static int parse_options(struct super_block *sb, char *options, int is_vfat,
>>  		case Opt_uid:
>>  			if (match_int(&args[0], &option))
>>  				return 0;
>> -			opts->fs_uid = option;
>> +			opts->fs_uid = make_kuid(current_user_ns(), option);
>> +			if (!uid_valid(opts->fs_uid))
>> +				return 0;
>>  			break;
>>  		case Opt_gid:
>>  			if (match_int(&args[0], &option))
>>  				return 0;
>> -			opts->fs_gid = option;
>> +			opts->fs_gid = make_kgid(current_user_ns(), option);
>> +			if (!gid_valid(opts->fs_gid))
>> +				return 0;
>>  			break;
>>  		case Opt_umask:
>>  			if (match_octal(&args[0], &option))
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 296d48b..60bdff2 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -952,7 +952,6 @@ config UIDGID_CONVERTED
>>  	depends on ECRYPT_FS = n
>>  	depends on EFS_FS = n
>>  	depends on EXOFS_FS = n
>> -	depends on FAT_FS = n
>>  	depends on FUSE_FS = n
>>  	depends on GFS2_FS = n
>>  	depends on HFS_FS = n
