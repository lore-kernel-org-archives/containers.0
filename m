From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: PROBLEM: Crash cgdeleting empty memory cgroups with
	memory.kmem.limit_in_bytes set
Date: Thu, 21 Feb 2013 15:22:56 +0400
Message-ID: <51260390.8010203@parallels.com>
References: <1361375371.7786.5.camel@michalke-online.eu>
	<20130220230019.GJ3570@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130220230019.GJ3570-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Steffen Michalke <StMichalke-S0/GAf8tV78@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/21/2013 03:00 AM, Tejun Heo wrote:
> (cc'ing cgroup / memcg people and quoting whole body)
> 
> Looks like something is going wrong with memcg cache destruction.
> Glauber, any ideas?  Also, can we please not use names as generic as
> kmem_cache_destroy_work_func for something specific to memcg?  How
> about something like memcg_destroy_cache_workfn?
> 
> Thanks.

Steffen,

Is there any chance you could test that using SLAB instead of SLUB?
I haven't manage to reproduce it yet, but I am working on some theories
about why this is happening. If I could at least know if this is likely
a cache problem vs a inner-memcg problem, that would help. The calltrace
is not incredibly helpful, but it does indicate that the problem happens
when freeing cache objects.
