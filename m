From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 09:54:29 -0400
Message-ID: <1243605269.3966.28.camel__46050.1312780709$1243605447$gmane$org@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Xy8It6mvGD69AKR/HH1+"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243604796.3966.21.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


--=-Xy8It6mvGD69AKR/HH1+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Minoru,

I hate to do this to you after i made suggestions on how to
make the changes.... (as an adult i hate it when people do it to
me;->)
But sometimes code helps. So what i meant is the attached patch.
I havent even compiled it yet.
If it works, please submit it and add yourself as the author
(and a signed-off from me). Then we can revisit the init()
issue in cls_group..
You should also cc tgraf in your cls_grp config questions.

cheers,
jamal

On Fri, 2009-05-29 at 09:46 -0400, jamal wrote:
> 
> This is incorrect. tp may already exist and you dont want to destroy
> for failure to change its parameters. You also dont want to reattach
> an existing tp because it succeeded in parameter change. 
> So the soln is to check if this is a new tp and then do what you did
> above...
> Did that make sense?
> 
> cheers,
> jamal

--=-Xy8It6mvGD69AKR/HH1+
Content-Disposition: attachment; filename=err-change-inited
Content-Type: text/x-patch; name=err-change-inited; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..8760a48 100644
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
 
@@ -314,8 +309,21 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
+	if (err == 0) {
+		if (n->nlmsg_type == RTM_NEWTFILTER &&
+		    (n->nlmsg_flags&NLM_F_CREATE)) {
+			spin_lock_bh(root_lock);
+			tp->next = *back;
+			*back = tp;
+			spin_unlock_bh(root_lock);
+		}
 		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	} else {
+		if (n->nlmsg_type == RTM_NEWTFILTER &&
+		    (n->nlmsg_flags&NLM_F_CREATE)) {
+			tcf_destroy(tp);
+		}
+	}
 
 errout:
 	if (cl)

--=-Xy8It6mvGD69AKR/HH1+
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--=-Xy8It6mvGD69AKR/HH1+--
