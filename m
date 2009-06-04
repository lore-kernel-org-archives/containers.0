From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Thu, 04 Jun 2009 14:32:34 -0700
Message-ID: <4A283D72.6070603__48089.2603089616$1244151567$gmane$org@google.com>
References: <20090604053649.GA3701@in.ibm.com> <4A27BBCA.5020606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A27BBCA.5020606-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Avi Kivity wrote:
> Bharata B Rao wrote:
>> 2. Need for hard limiting CPU resource
>> --------------------------------------
>> - Pay-per-use: In enterprise systems that cater to multiple clients/customers
>>   where a customer demands a certain share of CPU resources and pays only
>>   that, CPU hard limits will be useful to hard limit the customer's job
>>   to consume only the specified amount of CPU resource.
>> - In container based virtualization environments running multiple containers,
>>   hard limits will be useful to ensure a container doesn't exceed its
>>   CPU entitlement.
>> - Hard limits can be used to provide guarantees.
>>   
> How can hard limits provide guarantees?

Hard limits are useful and desirable in situations where we would like 
to maintain deterministic behavior.

Placing a hard cap on the cpu usage of a given task group (and 
configuring such that this cpu time is not overcommited) on a system 
allows us to create a hard guarantee that throughput for that task group 
will not fluctuate as other workloads are added and removed on the system.

Cache use and bus bandwidth in a multi-workload environment can still 
cause a performance deviation, but these are second order compared to 
the cpu scheduling guarantees themselves.

Mike Waychison
