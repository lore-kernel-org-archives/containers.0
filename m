From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 7/7] binfmt: Introduce the binfmt_img exec handler
Date: Sat, 23 Jul 2011 11:04:50 +0200
Message-ID: <20110723090450.GK21089@mtj.dyndns.org>
References: <4E204466.8010204@parallels.com> <4E204519.3040804@parallels.com>
	<20110721065127.GS3455@htj.dyndns.org>
	<20110722224617.GA16940@count0.beaverton.ibm.com>
	<4E2A83AC.6090504@parallels.com>
	<20110723084529.GH21089@mtj.dyndns.org>
	<4E2A8B7D.8010807@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E2A8B7D.8010807-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Sat, Jul 23, 2011 at 12:51:09PM +0400, Pavel Emelyanov wrote:
> On 07/23/2011 12:45 PM, Tejun Heo wrote:
> > Just restore it using the usual system calls - clone, mmap, open....
> 
> I can't clone/mmap/open registers (yet, unless we decide to have /proc/pid/regs
> file, do we?). Neither can I do it for anonymous private mappings :(

Hmmm?  When restoring a task, the task is started under restorer's
control.  The restorer can use ptrace to restore registers or feed it
assemblies to restore register states (ie. series of movq's to set
each register to the stored value followed by jmp to the stored RIP).

I don't understand your concern about anonymous private mappings.
What's different about them?  Can't the process being restored mmap
anonymous private mappings and fill it with the saved data?

Thanks.

-- 
tejun
