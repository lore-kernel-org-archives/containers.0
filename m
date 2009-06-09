From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] cls_cgroup: Fix oops when user send improperly 'tc
	filter add' request
Date: Tue, 09 Jun 2009 04:03:19 -0700 (PDT)
Message-ID: <20090609.040319.219370461.davem__3314.55181953988$1244545450$gmane$org@davemloft.net>
References: <20090609085408.9b38ffe1.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090609085408.9b38ffe1.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org
Cc: tgraf-G/eBtMaohhA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Date: Tue, 9 Jun 2009 08:54:08 +0900

> cls_cgroup: Fix oops when user send improperly 'tc filter add' request
> 
> I found a bug in cls_cgroup_change() in cls_cgroup.c.
> cls_cgroup_change() expected tca[TCA_OPTIONS] was set from user space properly,
> but tc in iproute2-2.6.29-1 (which I used) didn't set it.
> 
> In the current source code of tc in git, it set tca[TCA_OPTIONS].
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
> 
> If we always use a newest iproute2 in git when we use cls_cgroup, 
> we don't face this oops probably.
> But I think, kernel shouldn't panic regardless of use program's behaviour. 
> 
> Signed-off-by: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>

Patch applied, thank you.
