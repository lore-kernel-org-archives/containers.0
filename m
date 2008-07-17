From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Thu, 17 Jul 2008 10:43:35 +0900 (JST)
Message-ID: <20080717014335.ED78A5A22__42675.3861400813$1216259147$gmane$org@siro.lan>
References: <1216043344.12595.89.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Mon, 14 Jul 2008 15:49:04 +0200"
	<1216043344.12595.89.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

> Now the problem this patch tries to address...
> 
> As you can see you'd need p_{bdi,cgroup,task} for it to work, and the
> obvious approximation p_bdi * p_cgroup * p_task will get even more
> coarse.
> 
> You could possibly attempt to do p_{bdi,cgroup} * p_task since the bdi
> and cgroup set are pretty static, but still that would be painful.

i chose min(p_bdi * p_cgroup, p_bdi * p_task) because i couldn't imagine
a case where p_bdi * p_cgroup * p_task is better.

> So, could you please give some more justification for this work, I'm not
> seeing the value in complicating all this just yet.

a simple example for which my patch can make some sense is:

	while :;do dd if=/dev/zero of=file conv=notrunc bs=4096 count=1;done

YAMAMOTO Takashi
