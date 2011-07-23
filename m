From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 6/7] proc: Introduce the /proc/<pid>/dump file
Date: Sat, 23 Jul 2011 12:11:37 +0400
Message-ID: <4E2A8239.5060908@parallels.com>
References: <4E204466.8010204@parallels.com> <4E204500.6040800@parallels.com>
	<20110721064408.GR3455@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110721064408.GR3455-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On 07/21/2011 10:44 AM, Tejun Heo wrote:
> Hello,
> 
> On Fri, Jul 15, 2011 at 05:47:44PM +0400, Pavel Emelyanov wrote:
>> An image read from file contains task's registers and information
>> about its VM. Later this image can be execve-ed causing recreation
>> of the previously read task state.
>>
>> The file format is my own, very simple. Introduced to make the code
>> as simple as possible. Better file format (if any) is to be discussed.
> 
> First of all, I don't really think we need to bake in process dumper
> into the kernel.

Neither do I :) I just didn't have better candidate in mind and wanted
to discuss this part (see below).

> Most of information dumped here is already available
> through /proc and ptrace and we can add the missing pieces like the
> suggested proc vma fds.

Let's start with the simplest things. Can you suggest the best (from you pov)
way for dumping all the registers, tls and the anonymous pages through the 
existing interfaces?

Thanks,
Pavel
