From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 7/7] binfmt: Introduce the binfmt_img exec handler
Date: Sat, 23 Jul 2011 12:17:48 +0400
Message-ID: <4E2A83AC.6090504@parallels.com>
References: <4E204466.8010204@parallels.com> <4E204519.3040804@parallels.com>
	<20110721065127.GS3455@htj.dyndns.org>
	<20110722224617.GA16940@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110722224617.GA16940-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/23/2011 02:46 AM, Matt Helsley wrote:
> On Thu, Jul 21, 2011 at 08:51:27AM +0200, Tejun Heo wrote:
>> On Fri, Jul 15, 2011 at 05:48:09PM +0400, Pavel Emelyanov wrote:
>>> When being execve-ed the handler reads registers, mappings and provided
>>> memory pages from image and just assigns this state on current task. This
>>> simple functionality can be used to restore a task, whose state whas read
>>> from e.g. /proc/<pid>/dump file before.
>>
>> Ummm... iff the process is single threaded. :(

Yup :( This is the weak side.

>> Much more complex machinery is needed to restore full process anyway
>> which would require some kernel facilities but definitely a lot more
> 
> Agreed,

Well, let me describe why I chose the binfmt handler for restore.

The basic idea is very simple - you have to create a process with a defined
values in registers and defined set of memory mappings (with the memory
contents). This creation is obviously done by some (maybe another) process.

Thus we have two ways to go - either we transform the restoring task into
the target one or we freeze the target one and repopulate it "remotely".

The 1st approach seemed to be more elegant to me, and with this one we do
already have an API for turning one VM+regs into another - the execve.

If you can suggest another way - I'm open for discussion.

>> logic in userland.  I really can't see much point in having
> 
> I disagree (surprise! ;)).
> 
>> dumper/restorer in kernel.  The simplistic dumper/restorer proposed
>> here isn't really useful - among other things, it's single threaded
>> only and there's no mechanism to freeze the task being dumped.  It is
> 
> To be fair Pavel used signals to stop/resume the task. It's not
> a good solution but it's a start (more below).
> 
>> almost trivially implementable from userland using existing
>> facilities.  I wonder what the point is.
> 
> No, I think that ultimately an addition to the cgroup freezer will
> be needed.

Sure it will be! I planned to use one in the next iterations and used
the sigstop just for simplicity.
