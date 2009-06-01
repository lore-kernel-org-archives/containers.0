From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 1 Jun 2009 23:55:42 +0200
Message-ID: <20090601215542.GB2760__44315.1040155955$1243893569$gmane$org@ami.dom.local>
References: <1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
	<20090601204957.GA2760@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090601204957.GA2760-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
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

On Mon, Jun 01, 2009 at 10:49:57PM +0200, Jarek Poplawski wrote:
...
> Alas, I still think we don't need to change so much in -stable to
> fix the cls_cgroup oops, so I attach a patch which I think is
> enough for -stable and probably -net too. It could be "reverted"
> in -net-next just after applying cls_api patch. Of course, treat
> it only as my humble proposal, and feel free to recommend to David
> your version, no problem (really).

Since there are possible other oopses in cls_cgroup, here is an update
of patch #2.

Jarek P.
--------------------------> patch #2 (take 2)

 net/sched/cls_cgroup.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 1ab4542..edb71e1 100644
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
@@ -218,6 +220,9 @@ static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct cls_cgroup_head *head = tp->root;
 
+	if (!head)
+		return;
+
 	if (arg->count < arg->skip)
 		goto skip;
 
@@ -236,6 +241,9 @@ static int cls_cgroup_dump(struct tcf_proto *tp, unsigned long fh,
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
+	if (!head)
+		return -1;
+
 	t->tcm_handle = head->handle;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
