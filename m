From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/9] Multiple devpts instances
Date: Thu, 19 Feb 2009 11:58:18 -0800
Message-ID: <499DB9DA.2070301@zytor.com>
References: <20081015053000.GA2039@us.ibm.com> <499D7E13.10601@free.fr>
	<499D97B1.1090902@zytor.com> <499DA069.3040603@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <499DA069.3040603-GANU6spQydw@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
>>
>> Resource limit partitioning is a much bigger and orthogonal problem.
>>   
> In this case we don't have the pty allocated independently, no ?
> I mean one container can allocate 4095 pty, making a pty starvation for 
> others containers. Or imagine I am a vilain and I want to mess the other 
> containers, I can do echo 0 > /proc/sys/kernel/pty/max.
> AFAIR, we said people making isolation of a resource is in charge (if it 
> is relevant), to take into account the /proc/sys part.
> 
> For example, making the network per namespace all the network 
> configuration variable located in /proc/sys/net are per namespace too. 
> When it is irrelevant the file is read-only or just not displayed.
> 
> IMHO, pty/max and pty/nr is part of the "multiple devpts instances" 
> feature.
> 

Naming and resource partitioning are two orthogonal issues, regardless 
of what's IYHO.

Really.  You have the same classes of issues with ANY allocatable 
resource in the system.  Period.  Furthermore, there are quite a few 
applications which want one and not the other.  Trying to entangle them 
is broken.

	-hpa
