From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Mon, 24 Mar 2008 21:10:14 +0900
Message-ID: <47E79A26.3070401@mxp.nes.nec.co.jp>
References: <20080317020407.8512E1E7995@siro.lan>
	<47DE2894.6010306@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47DE2894.6010306-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
Cc: minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Daisuke Nishimura wrote:
> Hi, Yamamoto-san.
> 
> I'm reviewing and testing your patch now.
> 

In building kernel infinitely(in a cgroup of
memory.limit=64M and swap.limit=128M, with swappiness=100),
almost all of the swap (1GB) is consumed as swap cache
after a day or so.
As a result, processes are occasionally OOM-killed even when
the swap.usage of the group doesn't exceed the limit.

I don't know why the swap cache uses up swap space.
I will test whether a similar issue happens without your patch.
Do you have any thoughts?


BTW, I think that it would be better, in the sence of
isolating memory resource, if there is a framework
to limit the usage of swap cache.


Thanks,
Daisuke Nishimura.
