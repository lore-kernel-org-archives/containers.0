From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH RFC] c/r mounts ns.  Except not really.
Date: Tue, 22 Dec 2009 20:18:59 -0500
Message-ID: <4B317003.2060706@cs.columbia.edu>
References: <20091215023945.GA12100@us.ibm.com>
	<20091215201928.GA20037@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091215201928.GA20037-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> We only c/r a mounts ns with objref 0, meaning inherit the existing
>> mounts ns.  We do intend to implement c/r of mounts and mounts
>> namespaces in the kernel.  It shouldn't be ugly or complicate locking
>> to do so.  Just haven't gotten around to it.
>>
>> Why did I bother with this?  Because we can't re-create private
>> mounts yet, and while I don't expect trouble doing so, I think
>> it's more than we want to take on now for v19.  But I'd like
>> as much as possible for everything which we don't support, to not
>> be checkpointable, since not doing so has in the past invited
>> slanderous accusations of being a toy implementation  :)
>>
>> Comments?

This seems to me like the proper intermediary step.

>>
>> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

>> @@ -2323,3 +2324,37 @@ void put_mnt_ns(struct mnt_namespace *ns)
>>  	kfree(ns);
>>  }
>>  EXPORT_SYMBOL(put_mnt_ns);
>> +
>> +#ifdef CONFIG_CHECKPOINT
>> +int checkpoint_mounts_ns(struct ckpt_ctx *ctx, struct mnt_namespace *mnt_ns)
>> +{
>> +	if (mnt_ns == ctx->root_nsproxy->mnt_ns)
>> +		return 0;

As you mention below, this should be CKPT_MNT_NS_INHERIT.

> 
> Technically note that this is not even correct.  If the container
> being checkpointed had a mnt_ns private from its parents, then
> it could have its own mounts which are not checkpointed (and therefore
> can't even be generically restored by userspace).  So really this should
> be returning 0 (which should be CKPT_MNT_NS_INHERIT) only if mnt_ns
> == ctx->root_task->parent->nsproxy->mnt_ns (requiring more careful
> dereferencing since we don't have it pinned).
> 
> Whatever we do here for v19, I intend to do the same thing for
> network devices for v19.  The question is, are we being unprofessional,
> or are we being useful+flexible, by simply ignoring these things at
> checkpoint when we know we won't restore them?

IIRC we agreed that so-called "external" mounts - whatever is mounted
at the root of the container is the responsibility of userspace to have
prepared properly before restart.

So I don't see an issue with ignoring these at checkpoint, with one
exception: leak detection in full-container checkpoint should complain
if the root container fs is shared with parent (above container) tasks.

I think about it this way: at checkpoint, we care about container (or
checkpoint) root and below. Then at restart, we should decide whether
the root task (of the restore) should inherit its initial FS, or
whether it should start with a private one.

Recall that we had/have this dilemma also with UTS namespace, and with
IPC namespace.

Here is one way to do it:  (consider ipc-ns) at checkpoint, for the
kernel will compare every task's ipc-ns to the container's _parent_'s
ipc-ns, and if equal will save CKPT_OBJ_NS_INHERIT. If --inherit-ipc
is given, it will not the state of the parent's namespace, otherwise
it will.

At restart, if --inherit-ipc then whenever the kernel sees objref
that is CKPT_OBJ_NS_INHERIT, it will use the container's parent's
ipc-ns. Otherwise, it will create a new, private namespace for it.
(Also, with --inherit-ipc, if there is namespace state following
the CKPT_OBJ_NS_INHERIT, it should skip it without using it).

Oren.
