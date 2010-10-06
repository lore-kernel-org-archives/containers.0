From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R and stdio redirection
Date: Wed, 06 Oct 2010 15:43:27 +0200
Message-ID: <4CAC7CFF.5060109@fr.ibm.com>
References: <20100907200326.GA22256@us.ibm.com>
	<1283939092.32527.67.camel@bahia>
	<20101006055017.GA22969@us.ibm.com>
	<20101006095835.GC30415@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101006095835.GC30415-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

  On 10/06/2010 11:58 AM, Louis Rilling wrote:
> On 05/10/10 22:50 -0700, Sukadev Bhattiprolu wrote:
>> Greg Kurz [gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> | On Tue, 2010-09-07 at 13:03 -0700, Sukadev Bhattiprolu wrote:
>> |>  Suppose we create a container and redirect its stdout/stderr as follows:
>> |>
>> |>  	lxc-execute -name foo -- /path/to/app>  /tmp/xyz.out 2>&1
>> |>
>> |>  If we attempt to checkpoint the container 'foo', we fail bc one of the
>> |>  fds in the application refers to /tmp/xyz.out, which is also in use
>> |>  outside the container (specifically sys_checkpoint() fails due to the
>> |>  "alien mount ns" check in ckpt_fill_fname()).
>> |>
>> |>  It can be argued, 'foo' is not a strict container (since it shares the
>> |>  fd with another container).  For this reason, we currently need the
>> |>  CHECKPOINT_SUBTREE flag in lxc-checkpoint.
>> |>
>> |>  We initially thought that solving mount-namespaces will solve this, but
>> |>  realized that they are both separate problems. Mount-namespace C/R addresses
>> |>  preserving the mounts within the container and /tmp/xyz.out is outside
>> |>  the container.
>> |>
>> |>  So if an application container needs to redirect stdio as above, we should
>> |>  either
>> |>  	a) disable/ignore the alien-mount-ns check or
>> |>
>> |>  	b) try and start the application something like:
>> |>
>> |>  		$ cat /tmp/wrapper
>> |>  		/path/to/app>  /tmp/xyz.out 2>&1
>> |>
>> |>  		$ lxc-execute --name foo --  /tmp/wrapper
>> |>
>> |>  with the difference being /tmp/xyz.out is now inside the container's /tmp
>> |>  filesystem rather than in the parent container.
>> |>
>> |>  Maybe we can go with approach 'a' above only if CHECKPOINT_SUBTREE is also
>> |>  set - we had discussed this before and considered it hacky.
>> |>
>> |>  Or are there other solutions to this stdio redirection issue ?
>> |>
>> |
>> | To be more accurate, this issue is about fd leaking from a parent
>> | container to its descendants. The fd numbers may be anything else than
>> | 0,1 or 2 and the underlying files may be regular files, pipes,
>> | sockets... For example, in the HPC world, stdio are often sockets
>> | inheritated from a rshd like daemon.
>>
>> I agree that fd substitution is the right way to go.
>>
>> However, Matt Helsley and I were discussing this and wondered if we should
>> ignore the redirection and expect to user to specify it during restart.
>>
>> i.e if container was created like this:
>>
>> 	lxc-execute -name foo -- /path/to/app>  /tmp/xyz.out 2>&1
>>
>> and checkpointed, can we expect the user to restart it like this ?
>>
>> 	lxc-restart --name foo --statefile ckpt.img>>  /tmp/xyz.out
>>
>> i.e user has to redo the redirection or the output would go to stdout.
>>
>> Doing this would somehow seem to match a (bogus container) like:
>>
>> 	lxc-execute --name foo -- /path/to/app | sort
>>
>> If this container is checkpointed/restarted, we can't really redirect
>> the output of the app to 'sort' right ? So expecting the user to
>> redo the redirection on restart would treat both redirections ('>'
>> and '|') in a consistent way ?
>  From the fd substitution point of view, this means that lxc-restart would
> automatically request the substitution of its stdout to the checkpointed
> container init's stdout?
>

Yes, and this should apply to any inherited file descriptor (not only 
0,1 and 2).

> This sounds reasonable to me at least. Especially since the container is usually
> not supposed to know where the host is redirecting its stdout.
>
> Thanks,
>
> Louis
>
--
Greg
