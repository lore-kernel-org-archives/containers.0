From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Mon, 24 Mar 2008 17:52:08 +0530
Message-ID: <47E79CF0.6040308@linux.vnet.ibm.com>
References: <20080317020407.8512E1E7995@siro.lan>
	<47DE2894.6010306@mxp.nes.nec.co.jp>
	<47E79A26.3070401@mxp.nes.nec.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47E79A26.3070401-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
List-Id: containers.vger.kernel.org

Daisuke Nishimura wrote:
> Daisuke Nishimura wrote:
>> Hi, Yamamoto-san.
>>
>> I'm reviewing and testing your patch now.
>>
> 
> In building kernel infinitely(in a cgroup of
> memory.limit=64M and swap.limit=128M, with swappiness=100),
> almost all of the swap (1GB) is consumed as swap cache
> after a day or so.
> As a result, processes are occasionally OOM-killed even when
> the swap.usage of the group doesn't exceed the limit.
> 
> I don't know why the swap cache uses up swap space.
> I will test whether a similar issue happens without your patch.
> Do you have any thoughts?
> 
> 
> BTW, I think that it would be better, in the sence of
> isolating memory resource, if there is a framework
> to limit the usage of swap cache.

We had this earlier, but dropped it later due to issues related to swap
readahead and assigning the pages to the correct cgroup.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
