From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 09/15] (RFC) IPC: new kernel API to change
 an ID
Date: Mon, 04 Feb 2008 16:41:26 +0300
Message-ID: <47A71606.5030201@sw.ru>
References: <20080129160229.612172683@bull.net>	<20080129162000.454857358@bull.net>	<20080129210656.GB1990@martell.zuzino.mipt.ru>	<47A18E47.5050206@bull.net>
	<47A19AC2.7040709@sw.ru>	<47A1B78C.7050405@bull.net>
	<47A1C8FE.9010700@sw.ru> <47A1F2DB.7080600@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47A1F2DB.7080600-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Cedric Le Goater wrote:
> Hello Kirill !
> 
> Kirill Korotaev wrote:
>> Pierre,
>>
>> my point is that after you've added interface "set IPCID", you'll need
>> more and more for checkpointing:
>> - "create/setup conntrack" (otherwise connections get dropped),
>> - "set task start time" (needed for Oracle checkpointing BTW),
>> - "set some statistics counters (e.g. networking or taskstats)"
>> - "restore inotify"
>> and so on and so forth.
> 
> right. we know that we will have to handle a lot of these
> and more and we will need an API for it :) so how should we handle it ?
> through a dedicated syscall that would be able to checkpoint and/or
> restart a process, an ipc object, an ipc namespace, a full container ?
> will it take a fd or a big binary blob ?  
> I personally really liked Pavel idea's of filesystem. but we dropped the
> thread.

Imho having a file system interface means having all its problems.
Imagine you have some information about tasks exported with a file system interface.
Obviously to collect the information you have to hold some spinlock like tasklist_lock or similar.
Obviously, you have to drop the lock between sys_read() syscalls.
So interface gets much more complicated - you have to rescan the objects and somehow find the place where
you stopped previous read. Or you have to to force reader to read everything at once.

> that's for the user API but we will need also kernel services to expose
> (checkpoint) states and restore them. If it's too
> early to talk about the user API, we could try first to refactor
> the kernel internals to expose correctly what we need.

That's what I would start with.

> That's what Pierre's patchset is trying to do.

Not exactly. For checkpointing/restoring we actually need only one new API call for each
subsystem - create some object with given ID (and maybe parameters, if they are not dynamically changeable by user).
While Pierre's patchset adds different API call - change object ID.

Thanks,
Kirill
