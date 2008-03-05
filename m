From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] libcg: design and plans
Date: Wed, 05 Mar 2008 19:54:56 +0530
Message-ID: <47CEAD38.3080501__46152.4478313096$1204727389$gmane$org@linux.vnet.ibm.com>
References: <20080304152341.GB5659@linux.vnet.ibm.com>
	<6599ad830803042215n6aedb3eeub0c037e6a4e7bb34@mail.gmail.com>
	<20080305103343.GA22217@linux.vnet.ibm.com>
	<6599ad830803050241k590e4389ud95b9b3ef920f8b6@mail.gmail.com>
	<20080305110730.GB22217@linux.vnet.ibm.com>
	<6599ad830803050351p91bdacahd47059e863f56817@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830803050351p91bdacahd47059e863f56817-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Sudhir Kumar <skumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Mar 5, 2008 at 3:07 AM, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>  OK. Hmm, I've not really thought about it. At first thought, it should
>>  not be very difficult. Only thing I am not sure is the arbitrary
>>  grouping of the groups (ok, a bit confusing).
> 
> I suspect that the main form of composite grouping is going to be
> between parents and children. E.g. you might want to say things like:
> 
> create_group(A, memory=1G, cpu=100)
> create_group(B, parent=A, memory=inherit, cpu=20)
> create_group(C, parent=A, memory=inherit, cpu=30)
> 
> i.e. both B and C inherit/share their memory limit from their parent,
> but have their own CPU groups (child groups of their parent?)
>

No, we don't plan on doing that. What we plan on doing is

1. Specify the mount point for each controller
2. In the create group API, specify the name of the group and the various
parameters.

If for example CPU is mounted at /cpu and Memory at /mem

Then a specification for creation of group A would be of the form

create_group(A, cpu=100, memory=100M)

Then,

/cpu/A has shares set to 100 and /mem/A has memory.limit set to 100M

If you want to create subgroups under A, you specify

create_group(A/B, memory=200M, cpu=50)

That would create /cpu/A/B and /mem/A/B

Please note that memory and CPU hierarchy needs work in the kernel. The shares
and hierarchy support is pending. We need to make the res_counters
infrastructure aware of hierarchies.



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
