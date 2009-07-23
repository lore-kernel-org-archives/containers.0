From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v17][PATCH 22/60] c/r: external checkpoint of a task	other
	than ourself
Date: Thu, 23 Jul 2009 00:32:23 -0400
Message-ID: <4A67E7D7.9060800__11922.697016462$1248323619$gmane$org@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
	<1248256822-23416-23-git-send-email-orenl@librato.com>
	<20090722175223.GA19389@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722175223.GA19389-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> Now we can do "external" checkpoint, i.e. act on another task.
> 
> ...
> 
>>  long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
>>  {
>>  	long ret;
>>
>> +	ret = init_checkpoint_ctx(ctx, pid);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	if (ctx->root_freezer) {
>> +		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
>> +		if (ret < 0)
>> +			return ret;
>> +	}
> 
> Self-checkpoint of a task in root freezer is now denied, though.
> 
> Was that intentional?

Yes.

"root freezer" is an arbitrary task in the checkpoint subtree or
container. It is used to verify that all checkpointed tasks - except
for current, if doing self-checkpoint - belong to the same freezer
group.

Since current is busy calling checkpoint(2), and since we only permit
checkpoint of (cgroup-) frozen tasks, then - by definition - it cannot
possibly belong to the same group. If it did, it would itself be frozen
like its fellows and unable to call checkpoint(2).

Oren.
