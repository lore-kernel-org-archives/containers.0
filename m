From: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 04/12] userns: Convert cifs to use kuid/kgid where
	appropriate
Date: Tue, 20 Nov 2012 10:56:40 -0600
Message-ID: <CAH2r5mt91Av7w6GQUPNu2A9EGRNbPGGAhMO=EobOMi5Cn8gh5g@mail.gmail.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-4-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-4-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Do you have a pointer to the background on kuid/kgid

On Tue, Nov 20, 2012 at 6:43 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>wrote:

> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> Cc: Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/cifs/cifs_fs_sb.h  |    8 ++--
>  fs/cifs/cifs_spnego.c |    4 +-
>  fs/cifs/cifsacl.c     |  115
> ++++++++++++++++++++++++++++++++++++------------
>  fs/cifs/cifsacl.h     |   16 ++++++-
>  fs/cifs/cifsfs.c      |   12 +++--
>  fs/cifs/cifsglob.h    |   22 +++++-----
>  fs/cifs/cifspdu.h     |    2 +
>  fs/cifs/cifsproto.h   |    9 ++--
>  fs/cifs/cifssmb.c     |   11 ++++-
>  fs/cifs/connect.c     |   58 +++++++++++++++++++------
>  fs/cifs/dir.c         |   18 ++++----
>  fs/cifs/file.c        |    8 ++--
>  fs/cifs/inode.c       |   28 ++++++------
>  fs/cifs/misc.c        |    2 +-
>  init/Kconfig          |    1 -
>  15 files changed, 213 insertions(+), 101 deletions(-)
>
> diff --git a/fs/cifs/cifs_fs_sb.h b/fs/cifs/cifs_fs_sb.h
> index c865bfd..37e4a72 100644
> --- a/fs/cifs/cifs_fs_sb.h
> +++ b/fs/cifs/cifs_fs_sb.h
> @@ -55,10 +55,10 @@ struct cifs_sb_info {
>         unsigned int wsize;
>         unsigned long actimeo; /* attribute cache timeout (jiffies) */
>         atomic_t active;
> -       uid_t   mnt_uid;
> -       gid_t   mnt_gid;
> -       uid_t   mnt_backupuid;
> -       gid_t   mnt_backupgid;
> +       kuid_t  mnt_uid;
> +       kgid_t  mnt_gid;
> +       kuid_t  mnt_backupuid;
> +       kgid_t  mnt_backupgid;
>         umode_t mnt_file_mode;
>         umode_t mnt_dir_mode;
>         unsigned int mnt_cifs_flags;
> diff --git a/fs/cifs/cifs_spnego.c b/fs/cifs/cifs_spnego.c
> index 086f381..014a4c2 100644
> --- a/fs/cifs/cifs_spnego.c
> +++ b/fs/cifs/cifs_spnego.c
> @@ -149,10 +149,10 @@ cifs_get_spnego_key(struct cifs_ses *sesInfo)
>                 goto out;
>
>         dp = description + strlen(description);
> -       sprintf(dp, ";uid=0x%x", sesInfo->linux_uid);
> +       sprintf(dp, ";uid=0x%x", from_kuid_munged(&init_user_ns,
> sesInfo->linux_uid));
>
>         dp = description + strlen(description);
> -       sprintf(dp, ";creduid=0x%x", sesInfo->cred_uid);
> +       sprintf(dp, ";creduid=0x%x", from_kuid_munged(&init_user_ns,
> sesInfo->cred_uid));
>
>         if (sesInfo->user_name) {
>                 dp = description + strlen(description);
> diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
> index fc783e2..0f8b920 100644
> --- a/fs/cifs/cifsacl.c
> +++ b/fs/cifs/cifsacl.c
> @@ -44,6 +44,55 @@ static const struct cifs_sid sid_user = {1, 2 , {0, 0,
> 0, 0, 0, 5}, {} };
>
>  const struct cred *root_cred;
>
> +static inline struct cifs_id kuid_to_cid(kuid_t uid)
> +{
> +       struct cifs_id cid;
> +       cid.type = SIDOWNER;
> +       cid.uid = uid;
> +       return cid;
> +}
> +
> +static inline struct cifs_id kgid_to_cid(kgid_t gid)
> +{
> +       struct cifs_id cid;
> +       cid.type = SIDGROUP;
> +       cid.gid = gid;
> +       return cid;
> +}
> +
> +static unsigned long from_cid(struct user_namespace *user_ns, struct
> cifs_id cid)
> +{
> +       switch (cid.type) {
> +       case SIDOWNER:
> +               return from_kuid(user_ns, cid.uid);
> +       case SIDGROUP:
> +               return from_kgid(user_ns, cid.gid);
> +       default:
> +               BUG();
> +       }
> +}
> +
> +static bool cid_lt(struct cifs_id left, struct cifs_id right)
> +{
> +       if (left.type < right.type)
> +               return true;
> +       if (left.type > right.type)
> +               return false;
> +       switch (left.type) {
> +       case SIDOWNER:
> +               return uid_lt(left.uid, right.uid);
> +       case SIDGROUP:
> +               return gid_lt(left.gid, right.gid);
> +       default:
> +               BUG();
> +       }
> +}
> +
> +static inline bool cid_gt(struct cifs_id left, struct cifs_id right)
> +{
> +       return cid_lt(right, left);
> +}
> +
>  static void
>  shrink_idmap_tree(struct rb_root *root, int nr_to_scan, int *nr_rem,
>                         int *nr_del)
> @@ -105,7 +154,7 @@ cifs_idmap_shrinker(struct shrinker *shrink, struct
> shrink_control *sc)
>  }
>
>  static void
> -sid_rb_insert(struct rb_root *root, unsigned long cid,
> +sid_rb_insert(struct rb_root *root, struct cifs_id cid,
>                 struct cifs_sid_id **psidid, char *typestr)
>  {
>         char *strptr;
> @@ -117,11 +166,11 @@ sid_rb_insert(struct rb_root *root, unsigned long
> cid,
>         while (node) {
>                 lsidid = rb_entry(node, struct cifs_sid_id, rbnode);
>                 parent = node;
> -               if (cid > lsidid->id) {
> +               if (cid_gt(cid, lsidid->id)) {
>                         linkto = &(node->rb_left);
>                         node = node->rb_left;
>                 }
> -               if (cid < lsidid->id) {
> +               if (cid_lt(cid, lsidid->id)) {
>                         linkto = &(node->rb_right);
>                         node = node->rb_right;
>                 }
> @@ -133,7 +182,7 @@ sid_rb_insert(struct rb_root *root, unsigned long cid,
>
>         sprintf((*psidid)->sidstr, "%s", typestr);
>         strptr = (*psidid)->sidstr + strlen((*psidid)->sidstr);
> -       sprintf(strptr, "%ld", cid);
> +       sprintf(strptr, "%ld", from_cid(&init_user_ns, cid));
>
>         clear_bit(SID_ID_PENDING, &(*psidid)->state);
>         clear_bit(SID_ID_MAPPED, &(*psidid)->state);
> @@ -143,16 +192,16 @@ sid_rb_insert(struct rb_root *root, unsigned long
> cid,
>  }
>
>  static struct cifs_sid_id *
> -sid_rb_search(struct rb_root *root, unsigned long cid)
> +sid_rb_search(struct rb_root *root, struct cifs_id cid)
>  {
>         struct rb_node *node = root->rb_node;
>         struct cifs_sid_id *lsidid;
>
>         while (node) {
>                 lsidid = rb_entry(node, struct cifs_sid_id, rbnode);
> -               if (cid > lsidid->id)
> +               if (cid_gt(cid, lsidid->id))
>                         node = node->rb_left;
> -               else if (cid < lsidid->id)
> +               else if (cid_lt(cid, lsidid->id))
>                         node = node->rb_right;
>                 else /* node found */
>                         return lsidid;
> @@ -292,7 +341,7 @@ sidid_pending_wait(void *unused)
>  }
>
>  static int
> -id_to_sid(unsigned long cid, uint sidtype, struct cifs_sid *ssid)
> +id_to_sid(struct cifs_id cid, struct cifs_sid *ssid)
>  {
>         int rc = 0;
>         struct key *sidkey;
> @@ -302,10 +351,10 @@ id_to_sid(unsigned long cid, uint sidtype, struct
> cifs_sid *ssid)
>         struct rb_root *cidtree;
>         spinlock_t *cidlock;
>
> -       if (sidtype == SIDOWNER) {
> +       if (cid.type == SIDOWNER) {
>                 cidlock = &siduidlock;
>                 cidtree = &uidtree;
> -       } else if (sidtype == SIDGROUP) {
> +       } else if (cid.type == SIDGROUP) {
>                 cidlock = &sidgidlock;
>                 cidtree = &gidtree;
>         } else
> @@ -336,7 +385,7 @@ id_to_sid(unsigned long cid, uint sidtype, struct
> cifs_sid *ssid)
>                 } else {
>                         psidid = npsidid;
>                         sid_rb_insert(cidtree, cid, &psidid,
> -                                       sidtype == SIDOWNER ? "oi:" :
> "gi:");
> +                                       cid.type == SIDOWNER ? "oi:" :
> "gi:");
>                         ++psidid->refcount;
>                         spin_unlock(cidlock);
>                 }
> @@ -410,7 +459,7 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct
> cifs_sid *psid,
>                 struct cifs_fattr *fattr, uint sidtype)
>  {
>         int rc;
> -       unsigned long cid;
> +       struct cifs_id cid;
>         struct key *idkey;
>         const struct cred *saved_cred;
>         struct cifs_sid_id *psidid, *npsidid;
> @@ -418,11 +467,11 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct
> cifs_sid *psid,
>         spinlock_t *cidlock;
>
>         if (sidtype == SIDOWNER) {
> -               cid = cifs_sb->mnt_uid; /* default uid, in case upcall
> fails */
> +               cid = kuid_to_cid(cifs_sb->mnt_uid); /* default uid, in
> case upcall fails */
>                 cidlock = &siduidlock;
>                 cidtree = &uidtree;
>         } else if (sidtype == SIDGROUP) {
> -               cid = cifs_sb->mnt_gid; /* default gid, in case upcall
> fails */
> +               cid = kgid_to_cid(cifs_sb->mnt_gid); /* default gid, in
> case upcall fails */
>                 cidlock = &sidgidlock;
>                 cidtree = &gidtree;
>         } else
> @@ -471,7 +520,7 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct
> cifs_sid *psid,
>          * any fields of the node after a reference is put .
>          */
>         if (test_bit(SID_ID_MAPPED, &psidid->state)) {
> -               cid = psidid->id;
> +               //cid = psidid->id;
>                 psidid->time = jiffies; /* update ts for accessing */
>                 goto sid_to_id_out;
>         }
> @@ -485,8 +534,13 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct
> cifs_sid *psid,
>                 if (IS_ERR(idkey))
>                         cFYI(1, "%s: Can't map SID to an id", __func__);
>                 else {
> -                       cid = *(unsigned long *)idkey->payload.value;
> -                       psidid->id = cid;
> +                       u32 id;
> +                       id = *(u32 *)idkey->payload.value;
> +                       psidid->id.type = sidtype;
> +                       if (sidtype == SIDOWNER)
> +                               psidid->id.uid = make_kuid(&init_user_ns,
> id);
> +                       else
> +                               psidid->id.gid = make_kgid(&init_user_ns,
> id);
>                         set_bit(SID_ID_MAPPED, &psidid->state);
>                         key_put(idkey);
>                         kfree(psidid->sidstr);
> @@ -510,10 +564,10 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct
> cifs_sid *psid,
>
>  sid_to_id_out:
>         --psidid->refcount; /* decremented without spinlock */
> -       if (sidtype == SIDOWNER)
> -               fattr->cf_uid = cid;
> +       if (cid.type == SIDOWNER)
> +               fattr->cf_uid = cid.uid;
>         else
> -               fattr->cf_gid = cid;
> +               fattr->cf_gid = cid.gid;
>
>         return 0;
>  }
> @@ -537,7 +591,8 @@ init_cifs_idmap(void)
>         if (!cred)
>                 return -ENOMEM;
>
> -       keyring = key_alloc(&key_type_keyring, ".cifs_idmap", 0, 0, cred,
> +       keyring = key_alloc(&key_type_keyring, ".cifs_idmap",
> +                           GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
>                             (KEY_POS_ALL & ~KEY_POS_SETATTR) |
>                             KEY_USR_VIEW | KEY_USR_READ,
>                             KEY_ALLOC_NOT_IN_QUOTA);
> @@ -1074,7 +1129,7 @@ static int parse_sec_desc(struct cifs_sb_info
> *cifs_sb,
>
>  /* Convert permission bits from mode to equivalent CIFS ACL */
>  static int build_sec_desc(struct cifs_ntsd *pntsd, struct cifs_ntsd
> *pnntsd,
> -       __u32 secdesclen, __u64 nmode, uid_t uid, gid_t gid, int *aclflag)
> +       __u32 secdesclen, __u64 nmode, kuid_t uid, kgid_t gid, int
> *aclflag)
>  {
>         int rc = 0;
>         __u32 dacloffset;
> @@ -1106,17 +1161,18 @@ static int build_sec_desc(struct cifs_ntsd *pntsd,
> struct cifs_ntsd *pnntsd,
>                 *aclflag = CIFS_ACL_DACL;
>         } else {
>                 memcpy(pnntsd, pntsd, secdesclen);
> -               if (uid != NO_CHANGE_32) { /* chown */
> +               if (!uid_eq(uid, NO_CHANGE_UID)) { /* chown */
>                         owner_sid_ptr = (struct cifs_sid *)((char *)pnntsd
> +
>                                         le32_to_cpu(pnntsd->osidoffset));
>                         nowner_sid_ptr = kmalloc(sizeof(struct cifs_sid),
>
> GFP_KERNEL);
>                         if (!nowner_sid_ptr)
>                                 return -ENOMEM;
> -                       rc = id_to_sid(uid, SIDOWNER, nowner_sid_ptr);
> +                       rc = id_to_sid(kuid_to_cid(uid), nowner_sid_ptr);
>                         if (rc) {
>                                 cFYI(1, "%s: Mapping error %d for owner id
> %d",
> -                                               __func__, rc, uid);
> +                                               __func__, rc,
> +                                               from_kuid(&init_user_ns,
> uid));
>                                 kfree(nowner_sid_ptr);
>                                 return rc;
>                         }
> @@ -1125,17 +1181,18 @@ static int build_sec_desc(struct cifs_ntsd *pntsd,
> struct cifs_ntsd *pnntsd,
>                         kfree(nowner_sid_ptr);
>                         *aclflag = CIFS_ACL_OWNER;
>                 }
> -               if (gid != NO_CHANGE_32) { /* chgrp */
> +               if (!gid_eq(gid, NO_CHANGE_GID)) { /* chgrp */
>                         group_sid_ptr = (struct cifs_sid *)((char *)pnntsd
> +
>                                         le32_to_cpu(pnntsd->gsidoffset));
>                         ngroup_sid_ptr = kmalloc(sizeof(struct cifs_sid),
>
> GFP_KERNEL);
>                         if (!ngroup_sid_ptr)
>                                 return -ENOMEM;
> -                       rc = id_to_sid(gid, SIDGROUP, ngroup_sid_ptr);
> +                       rc = id_to_sid(kgid_to_cid(gid), ngroup_sid_ptr);
>                         if (rc) {
>                                 cFYI(1, "%s: Mapping error %d for group id
> %d",
> -                                               __func__, rc, gid);
> +                                               __func__, rc,
> +                                               from_kgid(&init_user_ns,
> gid));
>                                 kfree(ngroup_sid_ptr);
>                                 return rc;
>                         }
> @@ -1304,7 +1361,7 @@ cifs_acl_to_fattr(struct cifs_sb_info *cifs_sb,
> struct cifs_fattr *fattr,
>  /* Convert mode bits to an ACL so we can update the ACL on the server */
>  int
>  id_mode_to_cifs_acl(struct inode *inode, const char *path, __u64 nmode,
> -                       uid_t uid, gid_t gid)
> +                       kuid_t uid, kgid_t gid)
>  {
>         int rc = 0;
>         int aclflag = CIFS_ACL_DACL; /* default flag to set */
> diff --git a/fs/cifs/cifsacl.h b/fs/cifs/cifsacl.h
> index 5c902c7..233c576 100644
> --- a/fs/cifs/cifsacl.h
> +++ b/fs/cifs/cifsacl.h
> @@ -39,8 +39,10 @@
>  #define ACCESS_ALLOWED 0
>  #define ACCESS_DENIED  1
>
> -#define SIDOWNER 1
> -#define SIDGROUP 2
> +enum sidtype {
> +       SIDOWNER = 1,
> +       SIDGROUP = 2,
> +};
>  #define SIDLEN 150 /* S- 1 revision- 6 authorities- max 5 sub authorities
> */
>
>  #define SID_ID_MAPPED 0
> @@ -83,9 +85,17 @@ struct cifs_wksid {
>         char sidname[SIDNAMELENGTH];
>  } __attribute__((packed));
>
> +struct cifs_id {
> +       enum sidtype type;
> +       union {
> +               kuid_t uid;
> +               kgid_t gid;
> +       };
> +};
> +
>  struct cifs_sid_id {
>         unsigned int refcount; /* increment with spinlock, decrement
> without */
> -       unsigned long id;
> +       struct cifs_id id;
>         unsigned long time;
>         unsigned long state;
>         char *sidstr;
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index e7931cc..0a4740b 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -377,13 +377,13 @@ cifs_show_options(struct seq_file *s, struct dentry
> *root)
>                                    (int)(srcaddr->sa_family));
>         }
>
> -       seq_printf(s, ",uid=%u", cifs_sb->mnt_uid);
> +       seq_printf(s, ",uid=%u", from_kuid_munged(&init_user_ns,
> cifs_sb->mnt_uid));
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)
>                 seq_printf(s, ",forceuid");
>         else
>                 seq_printf(s, ",noforceuid");
>
> -       seq_printf(s, ",gid=%u", cifs_sb->mnt_gid);
> +       seq_printf(s, ",gid=%u", from_kgid_munged(&init_user_ns,
> cifs_sb->mnt_gid));
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)
>                 seq_printf(s, ",forcegid");
>         else
> @@ -438,9 +438,13 @@ cifs_show_options(struct seq_file *s, struct dentry
> *root)
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NO_PERM)
>                 seq_printf(s, ",noperm");
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPUID)
> -               seq_printf(s, ",backupuid=%u", cifs_sb->mnt_backupuid);
> +               seq_printf(s, ",backupuid=%u",
> +                          from_kuid_munged(&init_user_ns,
> +                                           cifs_sb->mnt_backupuid));
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPGID)
> -               seq_printf(s, ",backupgid=%u", cifs_sb->mnt_backupgid);
> +               seq_printf(s, ",backupgid=%u",
> +                          from_kgid_munged(&init_user_ns,
> +                                           cifs_sb->mnt_backupgid));
>
>         seq_printf(s, ",rsize=%u", cifs_sb->rsize);
>         seq_printf(s, ",wsize=%u", cifs_sb->wsize);
> diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
> index f5af252..97f1683 100644
> --- a/fs/cifs/cifsglob.h
> +++ b/fs/cifs/cifsglob.h
> @@ -400,11 +400,11 @@ struct smb_vol {
>         char *iocharset;  /* local code page for mapping to and from
> Unicode */
>         char source_rfc1001_name[RFC1001_NAME_LEN_WITH_NULL]; /* clnt nb
> name */
>         char target_rfc1001_name[RFC1001_NAME_LEN_WITH_NULL]; /* srvr nb
> name */
> -       uid_t cred_uid;
> -       uid_t linux_uid;
> -       gid_t linux_gid;
> -       uid_t backupuid;
> -       gid_t backupgid;
> +       kuid_t cred_uid;
> +       kuid_t linux_uid;
> +       kgid_t linux_gid;
> +       kuid_t backupuid;
> +       kgid_t backupgid;
>         umode_t file_mode;
>         umode_t dir_mode;
>         unsigned secFlg;
> @@ -703,8 +703,8 @@ struct cifs_ses {
>         char *serverNOS;        /* name of network operating system of
> server */
>         char *serverDomain;     /* security realm of server */
>         __u64 Suid;             /* remote smb uid  */
> -       uid_t linux_uid;        /* overriding owner of files on the mount
> */
> -       uid_t cred_uid;         /* owner of credentials */
> +       kuid_t linux_uid;       /* overriding owner of files on the mount
> */
> +       kuid_t cred_uid;        /* owner of credentials */
>         unsigned int capabilities;
>         char serverName[SERVER_NAME_LEN_WITH_NULL * 2]; /* BB make bigger
> for
>                                 TCP names - will ipv6 and sctp addresses
> fit? */
> @@ -838,7 +838,7 @@ struct cifs_tcon {
>   */
>  struct tcon_link {
>         struct rb_node          tl_rbnode;
> -       uid_t                   tl_uid;
> +       kuid_t                  tl_uid;
>         unsigned long           tl_flags;
>  #define TCON_LINK_MASTER       0
>  #define TCON_LINK_PENDING      1
> @@ -931,7 +931,7 @@ struct cifsFileInfo {
>         struct list_head tlist; /* pointer to next fid owned by tcon */
>         struct list_head flist; /* next fid (file instance) for this inode
> */
>         struct cifs_fid_locks *llist;   /* brlocks held by this fid */
> -       unsigned int uid;       /* allows finding which FileInfo structure
> */
> +       kuid_t uid;             /* allows finding which FileInfo structure
> */
>         __u32 pid;              /* process id who opened file */
>         struct cifs_fid fid;    /* file id from remote */
>         /* BB add lock scope info here if needed */ ;
> @@ -1259,8 +1259,8 @@ struct cifs_fattr {
>         u64             cf_eof;
>         u64             cf_bytes;
>         u64             cf_createtime;
> -       uid_t           cf_uid;
> -       gid_t           cf_gid;
> +       kuid_t          cf_uid;
> +       kgid_t          cf_gid;
>         umode_t         cf_mode;
>         dev_t           cf_rdev;
>         unsigned int    cf_nlink;
> diff --git a/fs/cifs/cifspdu.h b/fs/cifs/cifspdu.h
> index b9d59a9..2ede310 100644
> --- a/fs/cifs/cifspdu.h
> +++ b/fs/cifs/cifspdu.h
> @@ -278,6 +278,8 @@
>
>  #define NO_CHANGE_64          0xFFFFFFFFFFFFFFFFULL
>  #define NO_CHANGE_32          0xFFFFFFFFUL
> +#define NO_CHANGE_UID         INVALID_UID
> +#define NO_CHANGE_GID         INVALID_GID
>
>  /* IPC$ in ASCII */
>  #define CIFS_IPC_RESOURCE "\x49\x50\x43\x24"
> diff --git a/fs/cifs/cifsproto.h b/fs/cifs/cifsproto.h
> index 5144e9f..27b268a 100644
> --- a/fs/cifs/cifsproto.h
> +++ b/fs/cifs/cifsproto.h
> @@ -46,7 +46,8 @@ extern void _free_xid(unsigned int);
>  ({                                                             \
>         unsigned int __xid = _get_xid();                                \
>         cFYI(1, "CIFS VFS: in %s as Xid: %u with uid: %d",      \
> -            __func__, __xid, current_fsuid());                 \
> +            __func__, __xid,                                   \
> +            from_kuid(&init_user_ns, current_fsuid()));        \
>         __xid;                                                  \
>  })
>
> @@ -161,7 +162,7 @@ extern int cifs_acl_to_fattr(struct cifs_sb_info
> *cifs_sb,
>                               struct cifs_fattr *fattr, struct inode
> *inode,
>                               const char *path, const __u16 *pfid);
>  extern int id_mode_to_cifs_acl(struct inode *inode, const char *path,
> __u64,
> -                                       uid_t, gid_t);
> +                                       kuid_t, kgid_t);
>  extern struct cifs_ntsd *get_cifs_acl(struct cifs_sb_info *, struct inode
> *,
>                                         const char *, u32 *);
>  extern int set_cifs_acl(struct cifs_ntsd *, __u32, struct inode *,
> @@ -304,8 +305,8 @@ struct cifs_unix_set_info_args {
>         __u64   atime;
>         __u64   mtime;
>         __u64   mode;
> -       __u64   uid;
> -       __u64   gid;
> +       kuid_t  uid;
> +       kgid_t  gid;
>         dev_t   device;
>  };
>
> diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
> index 76d0d29..6b88d47 100644
> --- a/fs/cifs/cifssmb.c
> +++ b/fs/cifs/cifssmb.c
> @@ -5820,6 +5820,13 @@ cifs_fill_unix_set_info(FILE_UNIX_BASIC_INFO
> *data_offset,
>                         const struct cifs_unix_set_info_args *args)
>  {
>         u64 mode = args->mode;
> +       __u64 uid;
> +       __u64 gid;
> +
> +       uid = uid_eq(args->uid, NO_CHANGE_UID) ? NO_CHANGE_64:
> +               (__u64)from_kuid(&init_user_ns, args->uid);
> +       gid = gid_eq(args->gid, NO_CHANGE_GID) ? NO_CHANGE_64:
> +               (__u64)from_kgid(&init_user_ns, args->gid);
>
>         /*
>          * Samba server ignores set of file size to zero due to bugs in
> some
> @@ -5833,8 +5840,8 @@ cifs_fill_unix_set_info(FILE_UNIX_BASIC_INFO
> *data_offset,
>         data_offset->LastStatusChange = cpu_to_le64(args->ctime);
>         data_offset->LastAccessTime = cpu_to_le64(args->atime);
>         data_offset->LastModificationTime = cpu_to_le64(args->mtime);
> -       data_offset->Uid = cpu_to_le64(args->uid);
> -       data_offset->Gid = cpu_to_le64(args->gid);
> +       data_offset->Uid = cpu_to_le64(uid);
> +       data_offset->Gid = cpu_to_le64(gid);
>         /* better to leave device as zero when it is  */
>         data_offset->DevMajor = cpu_to_le64(MAJOR(args->device));
>         data_offset->DevMinor = cpu_to_le64(MINOR(args->device));
> diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
> index 5c670b9..dab3cf1 100644
> --- a/fs/cifs/connect.c
> +++ b/fs/cifs/connect.c
> @@ -1108,6 +1108,8 @@ cifs_parse_mount_options(const char *mountdata,
> const char *devname,
>         char *string = NULL;
>         char *tmp_end, *value;
>         char delim;
> +       kuid_t uid;
> +       kgid_t gid;
>
>         separator[0] = ',';
>         separator[1] = 0;
> @@ -1361,7 +1363,13 @@ cifs_parse_mount_options(const char *mountdata,
> const char *devname,
>                                         __func__);
>                                 goto cifs_parse_mount_err;
>                         }
> -                       vol->backupuid = option;
> +                       uid = make_kuid(current_user_ns(), option);
> +                       if (!uid_valid(uid)) {
> +                               cERROR(1, "%s: Invalid backupuid value",
> +                                       __func__);
> +                               goto cifs_parse_mount_err;
> +                       }
> +                       vol->backupuid = uid;
>                         vol->backupuid_specified = true;
>                         break;
>                 case Opt_backupgid:
> @@ -1370,7 +1378,13 @@ cifs_parse_mount_options(const char *mountdata,
> const char *devname,
>                                         __func__);
>                                 goto cifs_parse_mount_err;
>                         }
> -                       vol->backupgid = option;
> +                       gid = make_kgid(current_user_ns(), option);
> +                       if (!gid_valid(gid)) {
> +                               cERROR(1, "%s: Invalid backupgid value",
> +                                       __func__);
> +                               goto cifs_parse_mount_err;
> +                       }
> +                       vol->backupgid = gid;
>                         vol->backupgid_specified = true;
>                         break;
>                 case Opt_uid:
> @@ -1379,7 +1393,13 @@ cifs_parse_mount_options(const char *mountdata,
> const char *devname,
>                                         __func__);
>                                 goto cifs_parse_mount_err;
>                         }
> -                       vol->linux_uid = option;
> +                       uid = make_kuid(current_user_ns(), option);
> +                       if (!uid_valid(uid)) {
> +                               cERROR(1, "%s: Invalid uid value",
> +                                       __func__);
> +                               goto cifs_parse_mount_err;
> +                       }
> +                       vol->linux_uid = uid;
>                         uid_specified = true;
>                         break;
>                 case Opt_cruid:
> @@ -1388,7 +1408,13 @@ cifs_parse_mount_options(const char *mountdata,
> const char *devname,
>                                         __func__);
>                                 goto cifs_parse_mount_err;
>                         }
> -                       vol->cred_uid = option;
> +                       uid = make_kuid(current_user_ns(), option);
> +                       if (!uid_valid(uid)) {
> +                               cERROR(1, "%s: Invalid cruid value",
> +                                       __func__);
> +                               goto cifs_parse_mount_err;
> +                       }
> +                       vol->cred_uid = uid;
>                         break;
>                 case Opt_gid:
>                         if (get_option_ul(args, &option)) {
> @@ -1396,7 +1422,13 @@ cifs_parse_mount_options(const char *mountdata,
> const char *devname,
>                                                 __func__);
>                                 goto cifs_parse_mount_err;
>                         }
> -                       vol->linux_gid = option;
> +                       gid = make_kgid(current_user_ns(), option);
> +                       if (!gid_valid(gid)) {
> +                               cERROR(1, "%s: Invalid gid value",
> +                                       __func__);
> +                               goto cifs_parse_mount_err;
> +                       }
> +                       vol->linux_gid = gid;
>                         gid_specified = true;
>                         break;
>                 case Opt_file_mode:
> @@ -2203,7 +2235,7 @@ static int match_session(struct cifs_ses *ses,
> struct smb_vol *vol)
>  {
>         switch (ses->server->secType) {
>         case Kerberos:
> -               if (vol->cred_uid != ses->cred_uid)
> +               if (!uid_eq(vol->cred_uid, ses->cred_uid))
>                         return 0;
>                 break;
>         default:
> @@ -2692,7 +2724,7 @@ compare_mount_options(struct super_block *sb, struct
> cifs_mnt_data *mnt_data)
>         if (new->rsize && new->rsize < old->rsize)
>                 return 0;
>
> -       if (old->mnt_uid != new->mnt_uid || old->mnt_gid != new->mnt_gid)
> +       if (!uid_eq(old->mnt_uid, new->mnt_uid) || !gid_eq(old->mnt_gid,
> new->mnt_gid))
>                 return 0;
>
>         if (old->mnt_file_mode != new->mnt_file_mode ||
> @@ -3910,7 +3942,7 @@ cifs_set_vol_auth(struct smb_vol *vol, struct
> cifs_ses *ses)
>  }
>
>  static struct cifs_tcon *
> -cifs_construct_tcon(struct cifs_sb_info *cifs_sb, uid_t fsuid)
> +cifs_construct_tcon(struct cifs_sb_info *cifs_sb, kuid_t fsuid)
>  {
>         int rc;
>         struct cifs_tcon *master_tcon = cifs_sb_master_tcon(cifs_sb);
> @@ -3980,7 +4012,7 @@ cifs_sb_tcon_pending_wait(void *unused)
>
>  /* find and return a tlink with given uid */
>  static struct tcon_link *
> -tlink_rb_search(struct rb_root *root, uid_t uid)
> +tlink_rb_search(struct rb_root *root, kuid_t uid)
>  {
>         struct rb_node *node = root->rb_node;
>         struct tcon_link *tlink;
> @@ -3988,9 +4020,9 @@ tlink_rb_search(struct rb_root *root, uid_t uid)
>         while (node) {
>                 tlink = rb_entry(node, struct tcon_link, tl_rbnode);
>
> -               if (tlink->tl_uid > uid)
> +               if (uid_gt(tlink->tl_uid, uid))
>                         node = node->rb_left;
> -               else if (tlink->tl_uid < uid)
> +               else if (uid_lt(tlink->tl_uid, uid))
>                         node = node->rb_right;
>                 else
>                         return tlink;
> @@ -4009,7 +4041,7 @@ tlink_rb_insert(struct rb_root *root, struct
> tcon_link *new_tlink)
>                 tlink = rb_entry(*new, struct tcon_link, tl_rbnode);
>                 parent = *new;
>
> -               if (tlink->tl_uid > new_tlink->tl_uid)
> +               if (uid_gt(tlink->tl_uid, new_tlink->tl_uid))
>                         new = &((*new)->rb_left);
>                 else
>                         new = &((*new)->rb_right);
> @@ -4039,7 +4071,7 @@ struct tcon_link *
>  cifs_sb_tlink(struct cifs_sb_info *cifs_sb)
>  {
>         int ret;
> -       uid_t fsuid = current_fsuid();
> +       kuid_t fsuid = current_fsuid();
>         struct tcon_link *tlink, *newtlink;
>
>         if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MULTIUSER))
> diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
> index 7c0a812..d2c4062 100644
> --- a/fs/cifs/dir.c
> +++ b/fs/cifs/dir.c
> @@ -310,14 +310,14 @@ cifs_do_create(struct inode *inode, struct dentry
> *direntry, unsigned int xid,
>
>                 *created |= FILE_CREATED;
>                 if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_SET_UID) {
> -                       args.uid = (__u64) current_fsuid();
> +                       args.uid = current_fsuid();
>                         if (inode->i_mode & S_ISGID)
> -                               args.gid = (__u64) inode->i_gid;
> +                               args.gid = inode->i_gid;
>                         else
> -                               args.gid = (__u64) current_fsgid();
> +                               args.gid = current_fsgid();
>                 } else {
> -                       args.uid = NO_CHANGE_64;
> -                       args.gid = NO_CHANGE_64;
> +                       args.uid = NO_CHANGE_UID;
> +                       args.gid = NO_CHANGE_GID;
>                 }
>                 CIFSSMBUnixSetFileInfo(xid, tcon, &args, fid->netfid,
>                                        current->tgid);
> @@ -547,11 +547,11 @@ int cifs_mknod(struct inode *inode, struct dentry
> *direntry, umode_t mode,
>                         .device = device_number,
>                 };
>                 if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_SET_UID) {
> -                       args.uid = (__u64) current_fsuid();
> -                       args.gid = (__u64) current_fsgid();
> +                       args.uid = current_fsuid();
> +                       args.gid = current_fsgid();
>                 } else {
> -                       args.uid = NO_CHANGE_64;
> -                       args.gid = NO_CHANGE_64;
> +                       args.uid = NO_CHANGE_UID;
> +                       args.gid = NO_CHANGE_GID;
>                 }
>                 rc = CIFSSMBUnixSetPathInfo(xid, pTcon, full_path, &args,
>                                             cifs_sb->local_nls,
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index edb25b4..603863c 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -487,8 +487,8 @@ int cifs_open(struct inode *inode, struct file *file)
>                  */
>                 struct cifs_unix_set_info_args args = {
>                         .mode   = inode->i_mode,
> -                       .uid    = NO_CHANGE_64,
> -                       .gid    = NO_CHANGE_64,
> +                       .uid    = NO_CHANGE_UID,
> +                       .gid    = NO_CHANGE_GID,
>                         .ctime  = NO_CHANGE_64,
>                         .atime  = NO_CHANGE_64,
>                         .mtime  = NO_CHANGE_64,
> @@ -1631,7 +1631,7 @@ struct cifsFileInfo *find_readable_file(struct
> cifsInodeInfo *cifs_inode,
>            are always at the end of the list but since the first entry
> might
>            have a close pending, we go through the whole list */
>         list_for_each_entry(open_file, &cifs_inode->openFileList, flist) {
> -               if (fsuid_only && open_file->uid != current_fsuid())
> +               if (fsuid_only && !uid_eq(open_file->uid, current_fsuid()))
>                         continue;
>                 if (OPEN_FMODE(open_file->f_flags) & FMODE_READ) {
>                         if (!open_file->invalidHandle) {
> @@ -1684,7 +1684,7 @@ refind_writable:
>         list_for_each_entry(open_file, &cifs_inode->openFileList, flist) {
>                 if (!any_available && open_file->pid != current->tgid)
>                         continue;
> -               if (fsuid_only && open_file->uid != current_fsuid())
> +               if (fsuid_only && !uid_eq(open_file->uid, current_fsuid()))
>                         continue;
>                 if (OPEN_FMODE(open_file->f_flags) & FMODE_WRITE) {
>                         if (!open_file->invalidHandle) {
> diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
> index afdff79..c43bfa2 100644
> --- a/fs/cifs/inode.c
> +++ b/fs/cifs/inode.c
> @@ -247,12 +247,12 @@ cifs_unix_basic_to_fattr(struct cifs_fattr *fattr,
> FILE_UNIX_BASIC_INFO *info,
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)
>                 fattr->cf_uid = cifs_sb->mnt_uid;
>         else
> -               fattr->cf_uid = le64_to_cpu(info->Uid);
> +               fattr->cf_uid = make_kuid(&init_user_ns,
> le64_to_cpu(info->Uid));
>
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)
>                 fattr->cf_gid = cifs_sb->mnt_gid;
>         else
> -               fattr->cf_gid = le64_to_cpu(info->Gid);
> +               fattr->cf_gid = make_kgid(&init_user_ns,
> le64_to_cpu(info->Gid));
>
>         fattr->cf_nlink = le64_to_cpu(info->Nlinks);
>  }
> @@ -1245,14 +1245,14 @@ cifs_mkdir_qinfo(struct inode *parent, struct
> dentry *dentry, umode_t mode,
>                         .device = 0,
>                 };
>                 if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_SET_UID) {
> -                       args.uid = (__u64)current_fsuid();
> -                       if (parent->i_mode & S_ISGID)
> -                               args.gid = (__u64)parent->i_gid;
> +                       args.uid = current_fsuid();
> +                       if (inode->i_mode & S_ISGID)
> +                               args.gid = inode->i_gid;
>                         else
> -                               args.gid = (__u64)current_fsgid();
> +                               args.gid = current_fsgid();
>                 } else {
> -                       args.uid = NO_CHANGE_64;
> -                       args.gid = NO_CHANGE_64;
> +                       args.uid = INVALID_UID;
> +                       args.gid = INVALID_GID;
>                 }
>                 CIFSSMBUnixSetPathInfo(xid, tcon, full_path, &args,
>                                        cifs_sb->local_nls,
> @@ -2012,12 +2012,12 @@ cifs_setattr_unix(struct dentry *direntry, struct
> iattr *attrs)
>         if (attrs->ia_valid & ATTR_UID)
>                 args->uid = attrs->ia_uid;
>         else
> -               args->uid = NO_CHANGE_64;
> +               args->uid = NO_CHANGE_UID;
>
>         if (attrs->ia_valid & ATTR_GID)
>                 args->gid = attrs->ia_gid;
>         else
> -               args->gid = NO_CHANGE_64;
> +               args->gid = NO_CHANGE_GID;
>
>         if (attrs->ia_valid & ATTR_ATIME)
>                 args->atime = cifs_UnixTimeToNT(attrs->ia_atime);
> @@ -2085,8 +2085,8 @@ static int
>  cifs_setattr_nounix(struct dentry *direntry, struct iattr *attrs)
>  {
>         unsigned int xid;
> -       uid_t uid = NO_CHANGE_32;
> -       gid_t gid = NO_CHANGE_32;
> +       kuid_t uid = NO_CHANGE_UID;
> +       kgid_t gid = NO_CHANGE_GID;
>         struct inode *inode = direntry->d_inode;
>         struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
>         struct cifsInodeInfo *cifsInode = CIFS_I(inode);
> @@ -2145,7 +2145,7 @@ cifs_setattr_nounix(struct dentry *direntry, struct
> iattr *attrs)
>
>  #ifdef CONFIG_CIFS_ACL
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_ACL) {
> -               if (uid != NO_CHANGE_32 || gid != NO_CHANGE_32) {
> +               if (!uid_eq(uid, NO_CHANGE_UID) || !gid_eq(gid,
> NO_CHANGE_GID)) {
>                         rc = id_mode_to_cifs_acl(inode, full_path,
> NO_CHANGE_64,
>                                                         uid, gid);
>                         if (rc) {
> @@ -2169,7 +2169,7 @@ cifs_setattr_nounix(struct dentry *direntry, struct
> iattr *attrs)
>  #ifdef CONFIG_CIFS_ACL
>                 if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_ACL) {
>                         rc = id_mode_to_cifs_acl(inode, full_path, mode,
> -                                               NO_CHANGE_32,
> NO_CHANGE_32);
> +                                               NO_CHANGE_UID,
> NO_CHANGE_GID);
>                         if (rc) {
>                                 cFYI(1, "%s: Setting ACL failed with
> error: %d",
>                                         __func__, rc);
> diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
> index 3a00c0d..1b15bf8 100644
> --- a/fs/cifs/misc.c
> +++ b/fs/cifs/misc.c
> @@ -569,7 +569,7 @@ bool
>  backup_cred(struct cifs_sb_info *cifs_sb)
>  {
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPUID) {
> -               if (cifs_sb->mnt_backupuid == current_fsuid())
> +               if (uid_eq(cifs_sb->mnt_backupuid, current_fsuid()))
>                         return true;
>         }
>         if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_CIFS_BACKUPGID) {
> diff --git a/init/Kconfig b/init/Kconfig
> index cb2c46a..58959ea 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -999,7 +999,6 @@ config UIDGID_CONVERTED
>         default y
>
>         # Filesystems
> -       depends on CIFS = n
>         depends on CODA_FS = n
>         depends on GFS2_FS = n
>         depends on NCP_FS = n
> --
> 1.7.5.4
>
>


-- 
Thanks,

Steve
