From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 1 Jun 2009 22:49:58 +0200
Message-ID: <20090601204957.GA2760__46069.3470937715$1243890608$gmane$org@ami.dom.local>
References: <1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243861410.3966.268.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jun 01, 2009 at 09:03:30AM -0400, jamal wrote:
...
> How about going back to your original idea of defining tp_created? With
> apologies to Minoru (he must be thinking we are lunatics by now), how
> does the attached changed patch look to you?
> 
> Before you throw another rock,

Actually, I'd insist with the old rock and handling that other rude
u32 case, at least until it's fixed in place. So I attach my version
of your patch (additionally I removed a pair of braces because of
checkpatch warning).

Alas, I still think we don't need to change so much in -stable to
fix the cls_cgroup oops, so I attach a patch which I think is
enough for -stable and probably -net too. It could be "reverted"
in -net-next just after applying cls_api patch. Of course, treat
it only as my humble proposal, and feel free to recommend to David
your version, no problem (really).

> there is another issue which will be
> caused by this rude misconfig:
> "replace" really means "get rid of the old and add this new one".
> But for the last 50 years we do not "get rid of the old". I cant think
> of a clean way to do it sans shaving one of the kittens. One simple
> thing to do is to printk a warning when detecting this error. I think
> one needs to draw a line where bad config affects your life - in this
> case i dont think it is worth big changes..

Of course I'm against any printk on shaving the kitten...

Cheers,
Jarek P.
-----------------------> patch #1

 net/sched/cls_api.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..09cdcdf 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -135,6 +135,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	unsigned long cl;
 	unsigned long fh;
 	int err;
+	int tp_created = 0;
 
 	if (net != &init_net)
 		return -EINVAL;
@@ -266,10 +267,7 @@ replay:
 			goto errout;
 		}
 
-		spin_lock_bh(root_lock);
-		tp->next = *back;
-		*back = tp;
-		spin_unlock_bh(root_lock);
+		tp_created = 1;
 
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
@@ -296,8 +294,11 @@ replay:
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
 			err = -EEXIST;
-			if (n->nlmsg_flags & NLM_F_EXCL)
+			if (n->nlmsg_flags & NLM_F_EXCL) {
+				if (tp_created)
+					tcf_destroy(tp);
 				goto errout;
+			}
 			break;
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
@@ -314,8 +315,18 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
+	if (err == 0) {
+		if (tp_created) {
+			spin_lock_bh(root_lock);
+			tp->next = *back;
+			*back = tp;
+			spin_unlock_bh(root_lock);
+		}
 		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	} else {
+		if (tp_created)
+			tcf_destroy(tp);
+	}
 
 errout:
 	if (cl)

--------------------------> patch #2

 net/sched/cls_cgroup.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 1ab4542..3b2026f 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -101,6 +101,8 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	struct cgroup_cls_state *cs;
 	int ret = 0;
 
+	if (!head)
+		return -1;
 	/*
 	 * Due to the nature of the classifier it is required to ignore all
 	 * packets originating from softirq context as accessing `current'
