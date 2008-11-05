From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: statistics accounting in container
Date: Wed, 05 Nov 2008 18:53:03 +0530
Message-ID: <49119E37.7030905@linux.vnet.ibm.com>
References: <8f34198c0811022345t6030bb8cg4ccb48ef49f6b4bb@mail.gmail.com>
	<4910C088.4050109@fr.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4910C088.4050109-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Ian jonhson wrote:
>> Dear all,
>>
>> I am now working in the development of user tool for container
>> (built by Daniel Lezcano) and interest in the accounting
>> of container. Now, I would like to know whether the patches stated
>> in:
>> http://lwn.net/Articles/229974/
> 
> I think this one is known as CONFIG_CGROUP_CPUACCT and it is in mainline.
> 
>> http://lwn.net/Articles/243795/
> 
> This one is in mainline too. It is a subsystem of the resource
> controller. Note that it is related to physical memory.
> 
>> is been embedded in mainstream. More further, what is the
>> development status of  CPU,MEM, network bandwidth in container?
> 
> I am not sure what you mean by CPU bandwidth. There is the cgroup
> scheduler which allows to prioritize a group of processes but I don't 
> think there is a resource controller which blocks a set of processes 
> when a cpu consumption limit has been reached.
> 

This is under discussion, since the implementation needs many more things to be
considered.

> For the memory, there is the memory controller which gives an amount of 
> physical memory to a group of processes. When the limit is reached, the 
> processes begin to swap. There is some statistics in the cgroup files 
> about the memory consumption and the limits reached by the group.
> 

Some features like hierarchy support and soft limits are under development. Only
hard limits are available ATM.

-- 
	Balbir
