From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 10/14] net/core/scm.c: target capable() calls to user_ns
	owning the net_ns
Date: Thu, 4 Aug 2011 17:06:02 -0500
Message-ID: <20110804220602.GA32347__20645.2687889852$1312495606$gmane$org@sergelap>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
	<1311706717-7398-11-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311706717-7398-11-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> The uid/gid comparisons don't have to be pulled out.  This just seemed
> more easily proved correct.

The following needs to be folded into this patch:

From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Thu, 4 Aug 2011 21:48:13 +0000
Subject: [PATCH 2/2] fold up - net/core/scm.c: cred is const

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 net/core/scm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 21b5d0b..528fa36 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -43,7 +43,7 @@
  *	setu(g)id.
  */
 
-static __inline__ bool uidequiv(struct cred *src, struct ucred *tgt,
+static __inline__ bool uidequiv(const struct cred *src, struct ucred *tgt,
 			       struct user_namespace *ns)
 {
 	if (src->user_ns != ns)
@@ -57,7 +57,7 @@ check_capable:
 	return false;
 }
 
-static __inline__ bool gidequiv(struct cred *src, struct ucred *tgt,
+static __inline__ bool gidequiv(const struct cred *src, struct ucred *tgt,
 			       struct user_namespace *ns)
 {
 	if (src->user_ns != ns)
-- 
1.7.5.4
