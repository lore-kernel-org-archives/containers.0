From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] C/R: Fix storing IPv6 addresses and handle the
	"ipv6only" socket flag
Date: Tue, 6 Apr 2010 18:47:10 -0500
Message-ID: <20100406234710.GD22025@us.ibm.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
	<1270563183-9351-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270563183-9351-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> The first item is a result of sockaddr_in6 being larger than the base
> sockaddr structure, thus not being long enough to reserve enough space in
> the checkpoint header.
> 
> The second comes into play when things (like sshd) bind to INADDR6_ANY,
> set the "ipv6only" socket flag and then bind an IPv4 socket to the same
> port.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

since ipv6 can be a module, this requires:

From 7132840517ecc258a2d972dae7011a6666e91c56 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 6 Apr 2010 12:35:54 -0500
Subject: [PATCH 1/1] export needed symbols needed by ipv6

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/ipv4/checkpoint.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index 57b185d..7479ffd 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -299,6 +299,7 @@ int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(inet_checkpoint);
 
 int inet_collect(struct ckpt_ctx *ctx, struct socket *sock)
 {
@@ -553,3 +554,4 @@ int inet_restore(struct ckpt_ctx *ctx,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(inet_restore);
-- 
1.6.0.6
