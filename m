From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R and stdio redirection
Date: Wed, 08 Sep 2010 11:44:52 +0200
Message-ID: <1283939092.32527.67.camel@bahia>
References: <20100907200326.GA22256@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100907200326.GA22256-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2010-09-07 at 13:03 -0700, Sukadev Bhattiprolu wrote:
> Suppose we create a container and redirect its stdout/stderr as follows:
> 
> 	lxc-execute -name foo -- /path/to/app > /tmp/xyz.out 2>&1
> 
> If we attempt to checkpoint the container 'foo', we fail bc one of the
> fds in the application refers to /tmp/xyz.out, which is also in use
> outside the container (specifically sys_checkpoint() fails due to the
> "alien mount ns" check in ckpt_fill_fname()).
> 
> It can be argued, 'foo' is not a strict container (since it shares the
> fd with another container).  For this reason, we currently need the
> CHECKPOINT_SUBTREE flag in lxc-checkpoint.
> 
> We initially thought that solving mount-namespaces will solve this, but
> realized that they are both separate problems. Mount-namespace C/R addresses
> preserving the mounts within the container and /tmp/xyz.out is outside
> the container.
> 
> So if an application container needs to redirect stdio as above, we should
> either 
> 	a) disable/ignore the alien-mount-ns check or 
> 
> 	b) try and start the application something like:
> 
> 		$ cat /tmp/wrapper
> 		/path/to/app > /tmp/xyz.out 2>&1
> 
> 		$ lxc-execute --name foo --  /tmp/wrapper
> 
> with the difference being /tmp/xyz.out is now inside the container's /tmp
> filesystem rather than in the parent container.
> 
> Maybe we can go with approach 'a' above only if CHECKPOINT_SUBTREE is also
> set - we had discussed this before and considered it hacky.
> 
> Or are there other solutions to this stdio redirection issue ?
> 

To be more accurate, this issue is about fd leaking from a parent
container to its descendants. The fd numbers may be anything else than
0,1 or 2 and the underlying files may be regular files, pipes,
sockets... For example, in the HPC world, stdio are often sockets
inheritated from a rshd like daemon.

-- 
Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
