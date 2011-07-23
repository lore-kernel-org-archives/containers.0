From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 3/7] proc: Introduce the Children: line in
	/proc/<pid>/status
Date: Sat, 23 Jul 2011 12:45:02 +0400
Message-ID: <4E2A8A0E.5030208@parallels.com>
References: <4E204466.8010204@parallels.com> <4E2044C3.7050506@parallels.com>
	<20110721065436.GT3455@htj.dyndns.org>
	<4E2A8116.1040309@parallels.com>
	<20110723084110.GG21089@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110723084110.GG21089-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/23/2011 12:41 PM, Tejun Heo wrote:
> Hello,
> 
> On Sat, Jul 23, 2011 at 12:06:46PM +0400, Pavel Emelyanov wrote:
>>> The dumper would have to build full process tree anyway so I don't 
>>> see much point in providing backlink from kernel.
>>
>> Hm... Why would a dumper need to build the whole tree? Maybe you're
>> right with this, so can you elaborate?
> 
> It depends on what you want to dump.  Dumping arbitrary task has
> issues even at the most basic level due to relationships among family
> of processes, which I assume is why the in-kernel CR was primarily
> focused on dumping and restoring full namespaces.  If you're doing
> that, there is no avoiding walking process tree anyway (which
> apparently can even be per-NS using uprocfs).

OK I see. Then my answer is - typically a container looks like an init task
with everybody else growing from that point. Having a machine with 1000 of
containers building the whole /proc tree in memory to dump a single container
would be MUCH more expensive that having this small like in proc.

> Thanks.
> 
