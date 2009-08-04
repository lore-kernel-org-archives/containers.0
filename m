From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] io-controller: implement per group request allocation
	limitation
Date: Tue, 04 Aug 2009 14:38:35 +0800
Message-ID: <4A77D76B.3090502__11667.8828876049$1249368070$gmane$org@cn.fujitsu.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<4A569FC5.7090801@cn.fujitsu.com>
	<20090713160352.GA3714@redhat.com> <4A5BA238.3030902@ds.jp.nec.com>
	<4A5C377F.4040105@cn.fujitsu.com> <4A77964A.7040602@ds.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A77964A.7040602-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Munehiro Ikeda wrote:
...
> 
> Consideration and Conclusion
> =============================
> 
>  From result(1), it is observed that it takes 1000~1200[ms] to rise P2
> bandwidth.  In result(2), where both of g1 and g2 have
> nr_group_requests=100, the delay gets longer as 1800~2000[ms].  In
> addition to it, the average bandwidth becomes ~5% lower than result(1). 
> This is supposed that P2 couldn't allocate enough requests.
> Then, result(3) shows that bandwidth of P2 can rise quickly (~300[ms])
> if nr_group_requests can be set per-cgroup.  Result(4) shows that the
> delay can be shortened by setting g2 as RT class, however, the delay is
> still longer than result(3).
> 
> I think it is confirmed that "per-cgroup nr_requests limitation is
> useful in a certain situation".  Beyond that, the discussion topic is
> the benefit pointed out above is eligible for the complication of the
> implementation.  IMHO, I don't think the implementation of per-cgroup
> request limitation is too complicated to accept.  On the other hand I
> guess it suddenly gets complicated if we try to implement further more,
> especially hierarchical support.  It is also true that I have a feeling
> that implementation without per-device limitation and hierarchical
> support is like "unfinished work".
> 
> So, my opinion so far is that, per-cgroup nr_requests limitation should
> be merged only if hierarchical support is concluded "unnecessary" for
> it.  If merging it tempts hierarchical support, it shouldn't be.
> How about your opinion, all?

  Hi Munehiro-san,

  Thanks for the great job. It seems Per-cgroup requests allocation limits
  has its value in some cases. IMHO, for the time being, we can just drop
  the hierarchical support for "Per-cgroup requests allocation limits", and
  see whether it can work well.

> 
> My considerations or verification method might be wrong.  Please correct
> them if any.  And if you have any other idea of scenario to verify the
> effect of per-cgroup nr_requests limitation, please let me know.  I'll
> try it.
> 
> 
> 
> 
> ------------------------------------------------------------------------
> 

-- 
Regards
Gui Jianfeng
