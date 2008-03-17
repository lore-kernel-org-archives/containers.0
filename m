From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Mon, 17 Mar 2008 10:41:51 +0530
Message-ID: <47DDFD97.6000209@linux.vnet.ibm.com>
References: <20080317020407.8512E1E7995@siro.lan>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080317020407.8512E1E7995-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org

YAMAMOTO Takashi wrote:
> hi,
> 
> the following is another swap controller, which was designed and
> implemented independently from nishimura-san's one.
> 
> some random differences from nishimura-san's one:
> - counts and limits the number of ptes with swap entries instead of
>   on-disk swap slots.
> - no swapon-time memory allocation.
> - anonymous objects (shmem) are not accounted.
> - precise wrt moving tasks between cgroups. 
> 
> this patch contains some unrelated small fixes which i've posted separately:
> - exe_file fput botch fix
> - cgroup_rmdir EBUSY fix
> 
> any comments?
> 

Hi, YAMAMOTO-San,

Thanks for the patch. I'll review and test it. I'll get back soon

Balbir

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
