From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/3] container quota tool: teach quota tools to detect and
	perfrom quota if desired.
Date: Wed, 30 May 2012 23:07:58 +0800
Message-ID: <1338390478-13951-3-git-send-email-jeff.liu@oracle.com>
References: <1338390478-13951-1-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338390478-13951-1-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Teach quota pre-checking stuff to detect and perform container quota if desired.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

---
 Makefile.in  |    4 +-
 config.h.in  |    6 ++--
 mntopt.h     |    1 +
 quotacheck.c |   40 +++++++++++++++++++++++--
 quotacheck.h |    1 +
 quotaio.c    |   25 ++++++++++++++++
 quotaio.h    |    7 ++++-
 quotasys.c   |   91 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 8 files changed, 162 insertions(+), 13 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index c81d7a9..04582bc 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -1,5 +1,5 @@
 PROGS         = quotacheck quotaon quota quot repquota warnquota quotastats xqmstats edquota setquota convertquota rpc.rquotad quotasync @QUOTA_NETLINK_PROG@
-SOURCES       = bylabel.c common.c convertquota.c edquota.c pot.c quot.c quota.c quotacheck.c quotacheck_v1.c quotacheck_v2.c quotaio.c quotaio_rpc.c quotaio_v1.c quotaio_v2.c quotaio_tree.c quotaio_xfs.c quotaio_meta.c quotaio_generic.c quotaon.c quotaon_xfs.c quotaops.c quotastats.c quotasys.c repquota.c rquota_client.c rquota_server.c rquota_svc.c setquota.c warnquota.c xqmstats.c svc_socket.c quotasync.c
+SOURCES       = bylabel.c common.c convertquota.c edquota.c pot.c quot.c quota.c quotacheck.c quotacheck_v1.c quotacheck_v2.c quotaio.c quotaio_rpc.c quotaio_v1.c quotaio_v2.c quotaio_tree.c quotaio_xfs.c quotaio_meta.c quotaio_lxc.c  quotaio_generic.c quotaon.c quotaon_xfs.c quotaops.c quotastats.c quotasys.c repquota.c rquota_client.c rquota_server.c rquota_svc.c setquota.c warnquota.c xqmstats.c svc_socket.c quotasync.c
 CFLAGS        = @CFLAGS@ -D_GNU_SOURCE -Wall -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
 CPPFLAGS      = @CPPFLAGS@
 EXT2LIBS      = @EXT2LIBS@
@@ -34,7 +34,7 @@ sysconfdir    = @sysconfdir@
 datarootdir   = @datarootdir@
 
 RPCCLNTOBJS = rquota_xdr.o rquota_client.o rquota_clnt.o
-IOOBJS = quotaio.o quotaio_v1.o quotaio_v2.o quotaio_tree.o quotaio_rpc.o quotaio_xfs.o quotaio_meta.o quotaio_generic.o
+IOOBJS = quotaio.o quotaio_v1.o quotaio_v2.o quotaio_tree.o quotaio_rpc.o quotaio_xfs.o quotaio_meta.o quotaio_lxc.o quotaio_generic.o
 IOOBJS += $(RPCCLNTOBJS)
 LIBOBJS = bylabel.o common.o quotasys.o pot.o $(IOOBJS)
 LIBOBJS += @LIBMALLOC@
diff --git a/config.h.in b/config.h.in
index 432e3b5..97e23f1 100644
--- a/config.h.in
+++ b/config.h.in
@@ -1,8 +1,5 @@
 /* config.h.in.  Generated from configure.in by autoheader.  */
 
-/* Alternative file format of edquota */
-#undef ALT_FORMAT
-
 /* File with mounted filesystems */
 #undef ALT_MTAB
 
@@ -66,6 +63,9 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
+/* Define to the home page for this package. */
+#undef PACKAGE_URL
+
 /* Version of quota tools */
 #undef PACKAGE_VERSION
 
diff --git a/mntopt.h b/mntopt.h
index 63905bd..de6cd62 100644
--- a/mntopt.h
+++ b/mntopt.h
@@ -20,6 +20,7 @@
 #define MNTTYPE_MPFS		"mpfs"  /* EMC Celerra MPFS filesystem */
 #define MNTTYPE_OCFS2		"ocfs2"	/* Oracle Cluster filesystem */
 #define MNTTYPE_GFS2		"gfs2"	/* Red Hat Global filesystem 2 */
+#define MNTTYPE_LXC		"rootfs" /* Container rootfs mount type */
 
 /* mount options */
 #define MNTOPT_NOQUOTA		"noquota"	/* don't enforce quota */
diff --git a/quotacheck.c b/quotacheck.c
index 0d0d4b2..a59ae0f 100644
--- a/quotacheck.c
+++ b/quotacheck.c
@@ -410,6 +410,9 @@ static void parse_options(int argcnt, char **argstr)
 		mntpoint = argstr[optind];
 	else
 		mntpoint = NULL;
+
+	if (fmt == QF_LXC)
+		flags |= FL_LXC;
 }
 
 #if defined(EXT2_DIRECT)
@@ -795,6 +798,12 @@ static int dump_to_file(struct mount_entry *mnt, int type)
 			       strerror(errno));
 			return -1;
 		}
+	} else if (cfmt == QF_LXC) {
+		if (!(h = init_lxc_io(mnt, type))) {
+			errstr(_("Cannot initialize IO on lxc %s\n"),
+				strerror(errno));
+			return -1;
+		}
 	} else {
 		if (!(h = new_io(mnt, type, cfmt))) {
 			errstr(_("Cannot initialize IO on new quotafile: %s\n"),
@@ -828,6 +837,11 @@ static int dump_to_file(struct mount_entry *mnt, int type)
 		return -1;
 	}
 	debug(FL_DEBUG, _("Data dumped.\n"));
+
+	/* For LXC quota, don't need to do left checking stuff. */
+	if (cfmt == QF_LXC)
+		return 0;
+
 	if (kern_quota_on(mnt, type, cfmt) >= 0) {	/* Quota turned on? */
 		char *filename;
 
@@ -914,12 +928,12 @@ static int check_dir(struct mount_entry *mnt)
 	cur_dev = st.st_dev;
 	files_done = dirs_done = 0;
 	/*
-	 * For gfs2, we scan the fs first and then tell the kernel about the new usage.
+	 * For gfs2/lxc, we scan the fs first and then tell the kernel about the new usage.
 	 * So, there's no need to load any information. We also don't remount the
 	 * filesystem read-only because for a clustering filesystem it won't stop
 	 * modifications from other nodes anyway.
 	 */
-	if (cfmt == QF_XFS)
+	if (cfmt == QF_XFS || cfmt == QF_LXC)
 		goto start_scan;
 	if (ucheck)
 		if (process_file(mnt, USRQUOTA) < 0)
@@ -1133,11 +1147,30 @@ static int check_all(void)
 	static int warned;
 	int failed = 0;
 
-	if (init_mounts_scan((flags & FL_ALL) ? 0 : 1, &mntpoint, 0) < 0)
+	/*
+	 * Call init_mounts_scan() with flags to ensure LXC quotacheck
+	 * can be detected properly.
+	 */
+	if (init_mounts_scan((flags & FL_ALL) ? 0 : 1, &mntpoint, flags) < 0)
 		die(2, _("Cannot initialize mountpoint scan.\n"));
 	while ((mnt = get_next_mount())) {
 		if (flags & FL_ALL && flags & FL_NOROOT && !strcmp(mnt->me_dir, "/"))
 			continue;
+
+		/*
+		 * Deal with LXC format separately, since we have no general
+		 * quota mount options.
+		 * FIXME:
+		 * Need to tweak up if we have to implements container quota
+		 * with those quota mount strings.
+		 */
+		if (fmt == QF_LXC && flags & FL_LXC) {
+			cfmt = fmt;
+			ucheck = uwant ? 1 : 0;
+			gcheck = gwant ? 1 : 0;
+			goto start_check_dir;
+		}
+
 		if (!compatible_fs_qfmt(mnt->me_type, fmt)) {
 			debug(FL_DEBUG | FL_VERBOSE, _("Skipping %s [%s]\n"), mnt->me_devname, mnt->me_dir);
 			continue;
@@ -1177,6 +1210,7 @@ static int check_all(void)
 			warn_if_jquota_supported();
 		}
 
+start_check_dir:
 		checked++;
 		failed |= check_dir(mnt);
 	}
diff --git a/quotacheck.h b/quotacheck.h
index 0abdaaa..27c4d3e 100644
--- a/quotacheck.h
+++ b/quotacheck.h
@@ -26,6 +26,7 @@
 #define FL_NOROOT 512		/* Scan all mountpoints except root */
 #define FL_BACKUPS 1024		/* Create backup of old quota file? */
 #define FL_VERYVERBOSE 2048	/* Print directory names when checking */
+#define FL_LXC 4096		/* Perform container quotacheck */
 
 extern int flags;		/* Options from command line */
 extern struct util_dqinfo old_info[MAXQUOTAS];	/* Loaded info from file */
diff --git a/quotaio.c b/quotaio.c
index d3c7cb6..95a180c 100644
--- a/quotaio.c
+++ b/quotaio.c
@@ -27,6 +27,7 @@
 #include "dqblk_v2.h"
 #include "dqblk_rpc.h"
 #include "dqblk_xfs.h"
+#include "dqblk_lxc.h"
 
 /* Header in all newer quotafiles */
 struct disk_dqheader {
@@ -186,6 +187,30 @@ out_handle:
 	return NULL;
 }
 
+/* Initialize LXC quota IO */
+struct quota_handle *init_lxc_io(struct mount_entry *mnt, int type)
+{
+	struct quota_handle *h = smalloc(sizeof(struct quota_handle));
+
+	/* FIXME: maybe we don't need to stat(2) here */
+	if (stat(mnt->me_devname, &h->qh_stat) < 0)
+		memset(&h->qh_stat, 0, sizeof(struct stat));
+
+	h->qh_io_flags = 0;
+	h->qh_type = type;
+	sstrncpy(h->qh_quotadev, mnt->me_devname, sizeof(h->qh_quotadev));
+	sstrncpy(h->qh_fstype, mnt->me_type, MAX_FSTYPE_LEN);
+	sstrncpy(h->qh_dir, mnt->me_dir, PATH_MAX);
+
+	h->qh_fd = -1;
+	h->qh_fmt = QF_LXC;
+	h->qh_ops = &quotafile_ops_lxc;
+	memset(&h->qh_info, 0, sizeof(h->qh_info));
+	h->qh_ops->init_io(h);
+
+	return h;
+}
+
 /*
  *	Create new quotafile of specified format on given filesystem
  */
diff --git a/quotaio.h b/quotaio.h
index 2c373b2..1f90178 100644
--- a/quotaio.h
+++ b/quotaio.h
@@ -19,7 +19,8 @@
 #include "dqblk_rpc.h"
 #include "dqblk_xfs.h"
 
-#define QUOTAFORMATS 6
+/* With LXC quota, now we support 8 kind of quota formats */
+#define QUOTAFORMATS 8
 
 #define INITQFBASENAMES {\
 	"quota",\
@@ -41,6 +42,7 @@
 #define QF_XFS 4		/* XFS quota format */
 #define QF_META 5		/* Quota files are hidden, we don't care about the format */
 #define QF_VFSUNKNOWN 6		/* Some VFS quotas, we didn't detect particular format yet */
+#define QF_LXC 7		/* Container quota format */
 
 static inline int is_tree_qfmt(int fmt)
 {
@@ -173,6 +175,9 @@ struct quota_handle *init_io(struct mount_entry *mnt, int type, int fmt, int fla
 /* Create new quotafile of specified format on given filesystem */
 struct quota_handle *new_io(struct mount_entry *mnt, int type, int fmt);
 
+/* Check quota format used on LXC and initialize it */
+struct quota_handle *init_lxc_io(struct mount_entry *mnt, int type);
+
 /* Close quotafile */
 int end_io(struct quota_handle *h);
 
diff --git a/quotasys.c b/quotasys.c
index 73a0799..7365cb4 100644
--- a/quotasys.c
+++ b/quotasys.c
@@ -34,9 +34,16 @@
 #include "dqblk_xfs.h"
 #include "quotaio_v2.h"
 
+#include "dqblk_lxc.h"	/* export lxc quota opertions */
+#include "quotacheck.h" /* FL_LXC */
+
 #define min(x,y) (((x) < (y)) ? (x) : (y))
 
-#define QFMT_NAMES 5
+/*
+ * Index container disk quota format.
+ * FIXME: fix up in a proper way.
+ */
+#define QFMT_NAMES 8
 
 static char extensions[MAXQUOTAS + 2][20] = INITQFNAMES;
 static char *basenames[] = INITQFBASENAMES;
@@ -45,9 +52,20 @@ static char *fmtnames[] = { "vfsold",
 			    "vfsv1",
 			    "rpc",
 			    "xfs",
+			    "pad", /* Two pading string to index lxc */
+			    "pad",
+			    "lxc",
 };
 
 /*
+ *	check for container rootfs
+ */
+int lxc_fstype(char *type)
+{
+	return !strcmp(type, MNTTYPE_LXC);
+}
+
+/*
  *	Check for various kinds of NFS filesystem
  */
 int nfs_fstype(char *type)
@@ -227,7 +245,8 @@ int name2fmt(char *str)
   vfsv0 - standard quota format\n\
   vfsv1 - quota format with 64-bit limits\n\
   rpc - use RPC calls\n\
-  xfs - XFS quota format\n"), str);
+  xfs - XFS quota format\n\
+  lxc - LXC quota format\n"), str);
 	return QF_ERROR;
 }
 
@@ -253,6 +272,8 @@ static int kern2utilfmt(int kernfmt)
 			return QF_VFSV1;
 		case QFMT_OCFS2:
 			return QF_META;
+		case QFMT_NS:
+			return QF_LXC;
 	}
 	return -1;
 }
@@ -495,6 +516,14 @@ static int hasquota(const char *dev, struct mntent *mnt, int type, int flags)
 		return hasxfsquota(dev, mnt, type, flags);
 	if (!strcmp(mnt->mnt_type, MNTTYPE_OCFS2))
 		return hasvfsmetaquota(dev, mnt, type, flags);
+
+	/*
+	 * For LXC, no quota mount options at all.  Just return the LXC
+	 * quota format identifier is ok.
+	 */
+	if (lxc_fstype(mnt->mnt_type) || flags & FL_LXC)
+		return QF_LXC;
+
 	/*
 	 * For ext4 we check whether it has quota in system files and if not,
 	 * we fall back on checking standard quotas. Furthermore we cannot use
@@ -645,7 +674,11 @@ struct quota_handle **create_handle_list(int count, char **mntpoints, int type,
 		if (nfs_fstype(mnt->mnt_type))
 			continue;
 #endif
-		if (fmt == -1 || count) {
+		if (fmt == QF_LXC) {
+			if (!(hlist[gotmnt] = init_lxc_io(mnt, type)))
+				continue;
+			gotmnt++;
+		} else if (fmt == -1 || count) {
 add_entry:
 			if (gotmnt+1 >= hlist_allocated) {
 				hlist_allocated += START_MNT_POINTS;
@@ -772,6 +805,7 @@ void init_kernel_interface(void)
 		kernel_qfmt[kernel_qfmt_num++] = QF_VFSOLD;
 		kernel_qfmt[kernel_qfmt_num++] = QF_VFSV0;
 		kernel_qfmt[kernel_qfmt_num++] = QF_VFSV1;
+		kernel_qfmt[kernel_qfmt_num++] = QF_LXC;
 	}
 	else {
 		struct v2_dqstats v2_stats;
@@ -924,6 +958,41 @@ static struct mount_entry *mnt_entries;	/* Cached mounted filesystems */
 static int check_dirs_cnt, act_checked;	/* Number of dirs to check; Actual checked dir/(mountpoint in case of -a) */
 static struct searched_dir *check_dirs;	/* Directories to check */
 
+static int get_rootfs_device(dev_t *dev)
+{
+	FILE *fp = NULL;
+	struct stat st;
+	char fstype[256];
+	char device[256];
+	char mp[256];
+
+	memset(fstype, 0, sizeof(fstype));
+	memset(device, 0, sizeof(device));
+	memset(mp, 0, sizeof(mp));
+
+	if (!(fp = fopen("/proc/mounts", "r"))) {
+		perror("fopen");
+		return -1;
+	}
+
+	while (fscanf(fp, "%256s %256s %256s %*s %*d %*d\n",
+		      device, mp, fstype) == 3) {
+		if (strcmp(mp, "/") == 0 && strcmp(device, "rootfs") != 0)
+			break;
+	}
+
+	if (!device[0])
+		return -1;
+
+	if (stat(device, &st) < 0) {
+		perror("stat");
+		return -1;
+	}
+
+	*dev = st.st_rdev;
+	return 0;
+}
+
 /* Cache mtab/fstab */
 static int cache_mnt_table(int flags)
 {
@@ -1030,7 +1099,7 @@ alloc:
 			continue;
 		}
 
-		if (!nfs_fstype(mnt->mnt_type)) {
+		if (!nfs_fstype(mnt->mnt_type) && !lxc_fstype(mnt->mnt_type)) {
 			if (stat(devname, &st) < 0) {	/* Can't stat mounted device? */
 				errstr(_("Cannot stat() mounted device %s: %s\n"), devname, strerror(errno));
 				free((char *)devname);
@@ -1044,6 +1113,20 @@ alloc:
 			dev = st.st_rdev;
 			for (i = 0; i < mnt_entries_cnt && mnt_entries[i].me_dev != dev; i++);
 		}
+		/*
+		 * FIXME: There is no relevant DEV for rootfs inside LXC guest
+		 * by default.  I have to create it through `mknod /dev/sdaX x
+		 * x` to make the current code logic works.  Maybe we don't
+		 * need to fetch the corresponding dev_t at all.
+		 */
+		if (lxc_fstype(mnt->mnt_type)) {
+			if (get_rootfs_device(&dev) < 0) {
+				errstr(_("Cannot find device for rootfs\n"));
+				continue;
+			}
+			for (i = 0; i < mnt_entries_cnt && mnt_entries[i].me_dev != dev; i++);
+		}
+
 		/* Cope with network filesystems or new mountpoint */
 		if (nfs_fstype(mnt->mnt_type) || i == mnt_entries_cnt) {
 			if (stat(mnt->mnt_dir, &st) < 0) {	/* Can't stat mountpoint? We have better ignore it... */
-- 
1.7.9
