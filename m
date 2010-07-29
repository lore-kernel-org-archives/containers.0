From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: pid namespace isolation broken with powertop
Date: Thu, 29 Jul 2010 09:35:31 -0500
Message-ID: <1280414131.3143.45.camel@localhost>
References: <4C51747A.4050203@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C51747A.4050203-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2010-07-29 at 14:30 +0200, Daniel Lezcano wrote:
> Hi all,
> 
> I noticed all the tasks of the host are listed in /proc/timer_stats
> These information is not virtualized neither isolated within a container.
> 
> I was expecting to see only the tasks in the container with the 
> corresponding pids.
> 
> I am not sure this is something critical, but the usage of powertop in 
> the container shows all the tasks of the system.
> 
> While looking at the code in kernel/time/timer.c, it is not obvious to 
> fix this isolation because it is the pid number which is stored in a 
> list, so there is not enough informations to discriminate the pid 
> namespace against the current one.
> 
> I am wondering if:
> 
>   1) is it worth to isolate these informations ? (IMHO, yes).
>   2) should the stats be stored per pid namespace or adding an hash 
> value + pid namespace as a key in the timer stats list ?

Well, powertop is used for monitoring and modifying global system
characteristics (e.g. processor C states, USB autosuspend) that don't
make sense to virtualize.  Many events in /proc/timer_stats are
accocunted to pid 0 (swapper/idle).  I think the question is whether a
pidns-relative slice of timer events will be useful or just confusing.
