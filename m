From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
Date: Fri, 07 Mar 2008 13:23:02 +0900
Message-ID: <47D0C326.6060103@mxp.nes.nec.co.jp>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>
	<47CE4BB6.8050803@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47CE4BB6.8050803-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi.

Balbir Singh wrote:
> Daisuke Nishimura wrote:
>> Basic idea of my implementation:
>>   - what will be charged ?
>>     the number of swap entries.
>>
>>   - when to charge/uncharge ?
>>     charge at get_swap_entry(), and uncharge at swap_entry_free().
>>
> 
> You mean get_swap_page(), I suppose. The assumption in the code is that every
> swap page being charged has already been charged by the memory controller (that
> will go against making the controllers independent). Also, be careful of any

To make swap-limit independent of memory subsystem, I think
page_cgroup code should be separated into two part:
subsystem-independent and subsystem-dependent, that is
part of associating page and page_cgroup and that of associating
page_cgroup and subsystem.

Rather than to do such a thing, I now think that
it would be better to implement swap-limit as part of
memory subsystem.


Thanks,
Daisuke Nishimura.
