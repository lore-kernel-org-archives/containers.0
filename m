From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3,
	RESEND 11/16] Export iterate_mounts symbol to be able to use from
	sunrpc module.
Date: Tue,  8 Feb 2011 20:42:02 +0200
Message-ID: <1297190527-19925-12-git-send-email-kas__769.014683510427$1297191848$gmane$org@openvz.org>
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
 fs/namespace.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 7b0b953..c7f9a19 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1465,6 +1465,7 @@ int iterate_mounts(int (*f)(struct vfsmount *, void *), void *arg,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(iterate_mounts);
 
 static void cleanup_group_ids(struct vfsmount *mnt, struct vfsmount *end)
 {
-- 
1.7.4
