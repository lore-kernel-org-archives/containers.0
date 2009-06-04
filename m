From: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Thu, 04 Jun 2009 15:19:22 +0300
Message-ID: <4A27BBCA.5020606__49025.4159704365$1244118155$gmane$org@redhat.com>
References: <20090604053649.GA3701@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090604053649.GA3701-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Bharata B Rao wrote:
> 2. Need for hard limiting CPU resource
> --------------------------------------
> - Pay-per-use: In enterprise systems that cater to multiple clients/customers
>   where a customer demands a certain share of CPU resources and pays only
>   that, CPU hard limits will be useful to hard limit the customer's job
>   to consume only the specified amount of CPU resource.
> - In container based virtualization environments running multiple containers,
>   hard limits will be useful to ensure a container doesn't exceed its
>   CPU entitlement.
> - Hard limits can be used to provide guarantees.
>   
How can hard limits provide guarantees?

Let's take an example where I have 1 group that I wish to guarantee a 
20% share of the cpu, and anther 8 groups with no limits or guarantees.

One way to achieve the guarantee is to hard limit each of the 8 other 
groups to 10%; the sum total of the limits is 80%, leaving 20% for the 
guarantee group. The downside is the arbitrary limit imposed on the 
other groups.

Another way is to place the 8 groups in a container group, and limit 
that to 80%. But that doesn't work if I want to provide guarantees to 
several groups.

-- 
error compiling committee.c: too many arguments to function
