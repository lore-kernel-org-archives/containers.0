From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 14:18:30 +0900
Message-ID: <20090529141830.8ba30a24.usui__23894.2383825362$1243579354$gmane$org@mxm.nes.nec.co.jp>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090521092256.d33717b9.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, 

On Thu, 21 May 2009 09:22:56 +0900
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:

> Hi
> 
> Unfortunately this is only panic report.
> 
> I used cgroup net_cls subsystem, then kernel panic occured.
> I attach panic message and kernel config in this mail's last paragraph.
> If my operation is wrong, could you tell me how to use net_cls and
> where the documentation is. 
> 
> # But I think panic is very bad even if my operation is wrong.

I investigated this problem, and I found a bug in tc_ctl_tfilter() in net/sched/cls_api.c.

When 'tc filter add' command is executed and proto-tcf does not exist, 
tcf_ctl_tfilter() allocates, initializes and chanins proto-tcf(tp) to
cops->tcf_chain()'s chain before calling tp->ops->change().

If tp->ops->change() returns an error, tcf_ctl_tfilter() returns an error
too, but proto-tcf(tp) is not unchained yet. 

I think tcf_ctl_tfilter() shouldn't chain proto-tcf to the chain before it returns
an error.

Signed-off-by: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..756148b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -266,11 +266,6 @@ replay:
 			goto errout;
 		}
 
-		spin_lock_bh(root_lock);
-		tp->next = *back;
-		*back = tp;
-		spin_unlock_bh(root_lock);
-
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
 
@@ -314,8 +309,17 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
-		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	if (err) {
+		tcf_destroy(tp);
+		goto errout;
+	}
+
+	spin_lock_bh(root_lock);
+	tp->next = *back;
+	*back = tp;
+	spin_unlock_bh(root_lock);
+
+	tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
 
 errout:
 	if (cl)

-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
