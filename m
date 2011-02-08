From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3,
	RESEND 05/16] sunrpc: get rpc_pipefs mount point for svc_serv from
	callers
Date: Tue,  8 Feb 2011 20:41:56 +0200
Message-ID: <1297190527-19925-6-git-send-email-kas__37932.4794900187$1297191290$gmane$org@openvz.org>
References: <1297190527-19925-1-git-send-email-kas@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1297190527-19925-1-git-send-email-kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Kirill A. Shutemov <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Reviewed-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 fs/lockd/svc.c             |    4 +++-
 fs/nfs/callback.c          |    4 +++-
 fs/nfsd/nfssvc.c           |    6 ++++--
 include/linux/sunrpc/svc.h |    8 ++++----
 net/sunrpc/svc.c           |   18 +++++++++---------
 5 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abfff9d..32310b1 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -31,6 +31,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <net/ip.h>
 #include <linux/lockd/lockd.h>
 #include <linux/nfs.h>
@@ -269,7 +270,8 @@ int lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
+	serv = svc_create(&nlmsvc_program, init_rpc_pipefs, LOCKD_BUFSIZE,
+			NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..c9b98ad 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -16,6 +16,7 @@
 #include <linux/freezer.h>
 #include <linux/kthread.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/bc_xprt.h>
 
 #include <net/inet_sock.h>
@@ -259,7 +260,8 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		nfs_callback_bc_serv(minorversion, xprt, cb_info);
 		goto out;
 	}
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
+	serv = svc_create(&nfs4_callback_program, init_rpc_pipefs,
+			NFS4_CALLBACK_BUFSIZE, NULL);
 	if (!serv) {
 		ret = -ENOMEM;
 		goto out_err;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 18743c4..e4fc85d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -13,6 +13,7 @@
 
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
@@ -331,8 +332,9 @@ int nfsd_create_serv(void)
 	}
 	nfsd_reset_versions();
 
-	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, THIS_MODULE);
+	nfsd_serv = svc_create_pooled(&nfsd_program, init_rpc_pipefs,
+				      nfsd_max_blksize, nfsd_last_thread, nfsd,
+				      THIS_MODULE);
 	if (nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 0cfd8e8..be15862 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -401,13 +401,13 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
-struct svc_serv *svc_create(struct svc_program *, unsigned int,
-			    void (*shutdown)(struct svc_serv *));
+struct svc_serv *svc_create(struct svc_program *, struct vfsmount *,
+			    unsigned int, void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
-struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv *),
+struct svc_serv *  svc_create_pooled(struct svc_program *, struct vfsmount *,
+			unsigned int, void (*shutdown)(struct svc_serv *),
 			svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 370bc46..63abe2b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -28,7 +28,6 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
-#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
@@ -361,7 +360,8 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
  * Create an RPC service
  */
 static struct svc_serv *
-__svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
+__svc_create(struct svc_program *prog, struct vfsmount *rpcmount,
+	     unsigned int bufsize, int npools,
 	     void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
@@ -373,7 +373,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		return NULL;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
-	serv->sv_rpcmount  = mntget(init_rpc_pipefs);
+	serv->sv_rpcmount  = mntget(rpcmount);
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
 	if (bufsize > RPCSVC_MAXPAYLOAD)
@@ -429,22 +429,22 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 }
 
 struct svc_serv *
-svc_create(struct svc_program *prog, unsigned int bufsize,
-	   void (*shutdown)(struct svc_serv *serv))
+svc_create(struct svc_program *prog, struct vfsmount *rpcmount,
+	   unsigned int bufsize, void (*shutdown)(struct svc_serv *serv))
 {
-	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
+	return __svc_create(prog, rpcmount, bufsize, /*npools*/1, shutdown);
 }
 EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
-svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  void (*shutdown)(struct svc_serv *serv),
+svc_create_pooled(struct svc_program *prog, struct vfsmount *rpcmount,
+		  unsigned int bufsize, void (*shutdown)(struct svc_serv *serv),
 		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
-	serv = __svc_create(prog, bufsize, npools, shutdown);
+	serv = __svc_create(prog, rpcmount, bufsize, npools, shutdown);
 
 	if (serv != NULL) {
 		serv->sv_function = func;
-- 
1.7.4
