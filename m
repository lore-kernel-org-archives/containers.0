From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: PROBLEM: Crash cgdeleting empty memory cgroups with
	memory.kmem.limit_in_bytes set
Date: Thu, 21 Feb 2013 12:34:25 +0400
Message-ID: <5125DC11.7060106@parallels.com>
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

I will take a look. Thanks for the report for the reportee: I tested
cgroup deletion quite extensively (quite important feature for me) so it
is nice to have an uncaught case.

About naming, I can change, no problem.
