From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
Date: Fri, 14 Jan 2011 15:48:58 +0200
Message-ID: <1295012954-7769-1-git-send-email-kas__22861.9019072086$1295013557$gmane$org@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
Only for client for now.

It's step forwart to get nfs work from container.

Changelog:

v3:
 - rebase to the current Linus' tree (52cfd503ad)
 - rework get_rpc_pipefs() once again;
 - solve problem with rmmod sunrpc moudle;
 - free dns cache on killing rpc_pipefs superblock.

v2:
 - one of rpc_create() calls was missed initially, fixed;
 - change logic for get_rpc_pipefs(NULL);
 - export get_rpc_pipefs() to be able to use from modules (tnx J. Bruce Field);
 - change "From:" and "Signed-off-by:" addresses.

v1:
 - initial revision of the patchset.

Kirill A. Shutemov (16):
  sunrpc: mount rpc_pipefs on initialization
  sunrpc: introduce init_rpc_pipefs
  sunrpc: push init_rpc_pipefs up to rpc_create() callers
  sunrpc: tag svc_serv with rpc_pipefs mount point
  sunrpc: get rpc_pipefs mount point for svc_serv from callers
  lockd: get rpc_pipefs mount point from callers
  sunrpc: get rpc_pipefs mount point for rpcb_create[_local] from
    callers
  sunrpc: tag pipefs field of cache_detail with rpc_pipefs mount point
  sunrpc: introduce rpc_pipefs_add_destroy_cb()
  nfs: per-rpc_pipefs dns cache
  Export iterate_mounts symbol to be able to use from sunrpc module.
  sunrpc: introduce get_rpc_pipefs()
  nfs: introduce mount option 'rpcmount'
  sunrpc: make rpc_pipefs be mountable multiple times
  sunrpc: remove global init_rpc_pipefs
  Rework get_rpc_pipefs and introduce put_rpc_pipefs()

 fs/lockd/clntlock.c                |    8 +-
 fs/lockd/host.c                    |   15 ++-
 fs/lockd/mon.c                     |   13 ++-
 fs/lockd/svc.c                     |    4 +-
 fs/namespace.c                     |    1 +
 fs/nfs/cache_lib.c                 |   18 +--
 fs/nfs/cache_lib.h                 |    3 +-
 fs/nfs/callback.c                  |    7 +-
 fs/nfs/callback.h                  |    3 +-
 fs/nfs/client.c                    |   45 ++++++-
 fs/nfs/dns_resolve.c               |  137 ++++++++++++++++-----
 fs/nfs/dns_resolve.h               |   15 +--
 fs/nfs/inode.c                     |    9 +--
 fs/nfs/internal.h                  |   10 ++-
 fs/nfs/mount_clnt.c                |    1 +
 fs/nfs/namespace.c                 |    3 +-
 fs/nfs/nfs4namespace.c             |   20 ++--
 fs/nfs/super.c                     |   20 +++
 fs/nfsd/nfs4callback.c             |    5 +
 fs/nfsd/nfssvc.c                   |   20 +++-
 include/linux/lockd/bind.h         |    3 +-
 include/linux/lockd/lockd.h        |    4 +-
 include/linux/nfs_fs_sb.h          |    1 +
 include/linux/sunrpc/cache.h       |    9 +-
 include/linux/sunrpc/clnt.h        |    5 +-
 include/linux/sunrpc/rpc_pipe_fs.h |    7 +-
 include/linux/sunrpc/svc.h         |    9 +-
 net/sunrpc/cache.c                 |   16 ++-
 net/sunrpc/clnt.c                  |   19 ++--
 net/sunrpc/rpc_pipe.c              |  235 ++++++++++++++++++++++++++++++++----
 net/sunrpc/rpcb_clnt.c             |   19 ++-
 net/sunrpc/svc.c                   |   52 +++++---
 32 files changed, 549 insertions(+), 187 deletions(-)

-- 
1.7.3.4
