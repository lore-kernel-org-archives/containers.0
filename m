From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: restart (mktree) program usage
Date: Thu, 17 Sep 2009 13:58:40 -0400
Message-ID: <4AB278D0.50604@librato.com>
References: <20090909055636.GA27622@us.ibm.com> <4AA82B7C.8080107@librato.com>
	<20090917013546.GA30161@us.ibm.com> <4AB1A99D.3020307@librato.com>
	<20090917131843.GA29297@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090917131843.GA29297-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>
>> Sukadev Bhattiprolu wrote:
>>> Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
>>> | 
>>> | 
>>> | Sukadev Bhattiprolu wrote:
>>> | > I have a usage question on the 'restart' (formerly mktree) program.
>>> | > 
>>> | > In the following container c/r case: 
>>> | > 
>>> | > 	- create a container
>>> | > 	- log in to the container,
>>> | > 	- restore filesystem(s) from snapshot
>>> | > 	- restart application from checkpoint
>>> | 
>>> | FWIW, I'd expect that future versions of 'restart' will be capable
>>> | of doing this entire setup, (filesystem(s) included), as it matures.
>>> | 
>>> | Note that this use case that you suggest will only work to restart
>>> | subtrees; it is unsuitable for full containers (with pids) because
>>> | the pid of init (1) will already be in use.
>>>
>>> True. But if originally the application was started as:
>>>
>>> 	Create container
>>> 	Login to contaienr
>> Actually, I'm not sure what you mean by "login to container" ?
> 
> I assume he was thinking of a system container created with liblxc
> or libvirt, and literally logging in on its console or over ssh.

This is exactly my point:

* If you checkpoint full container, you get the sshd (and init) as
well, so you can't restore into an "existing" container, but create
a new one.

* If you checkpoint subtree, you will miss orphans, and you will
give up leak-detection.

I'd assume most users of this scenarios will prefer full container.

If you want to restart by first creating a new container, than set
it up, then log-in to that container, and finally run restart -
you will _have to_ modify the checkpoint image to remove unwanted
parts, and adjust the remaining accordingly.

For instance, you will have to remove (or tell the kernel to skip)
the data for the init task, and the ssh-server, and then change the
ppid of the root of your subtree to be 1 instead of what it was
(probably the old ssh-server), and so on.

It's doable, but I'm unsure if it's worth the extra work.

Oren.

> 
>>> Yes, that would be really useful I think for things like restoring file
>>> system to its snapshot. Without that there is somewhat of an assymetry
>>> in starting an application in a container and restarting it from a
>>> checkpoint.
> 
> Fine, they are different operations :)
> 
> -serge
