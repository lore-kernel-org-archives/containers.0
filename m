From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 4/7] Add target_pids parameter to alloc_pid()
Date: Mon, 1 Jun 2009 13:52:33 -0700
Message-ID: <20090601205233.GB1812@us.ibm.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000220.GC4191@us.ibm.com>
	<20090601083419.GE4381@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090601083419.GE4381-+dguKlz9DXUf7BdofF/totBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Amerigo Wang [xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:
| >@@ -294,7 +295,11 @@ struct pid *alloc_pid(struct pid_namespace *ns)
| > 
| > 	tmp = ns;
| > 	for (i = ns->level; i >= 0; i--) {
| >-		nr = alloc_pidmap(tmp, 0);
| >+		tpid = 0;
| 
| How about initializing 'tpid' to 0 when define it?

'tpid' may contain a non-zero value from the previous iteration and
needs to be reset each time.

| 
| Otherwise,
| 
| Reviewed-by: WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks for the review.

Sukadev
