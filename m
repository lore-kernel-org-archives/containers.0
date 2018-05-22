From: Y Song <ys114321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC] bpf: tracing: new helper bpf_get_current_cgroup_ino
Date: Mon, 21 May 2018 17:24:49 -0700
Message-ID: <CAH3MdRWgruVq+3r+2pHTah-c2zTO03vPkepjWDZ0_KrYcroy9A__17505.6963846602$1526948612$gmane$org@mail.gmail.com>
References: <20180513173318.21680-1-alban@kinvolk.io>
	<20180521162609.lpdrnozowmzdn57m@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180521162609.lpdrnozowmzdn57m-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 21, 2018 at 9:26 AM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Sun, May 13, 2018 at 07:33:18PM +0200, Alban Crequy wrote:
>>
>> +BPF_CALL_2(bpf_get_current_cgroup_ino, u32, hierarchy, u64, flags)
>> +{
>> +     // TODO: pick the correct hierarchy instead of the mem controller
>> +     struct cgroup *cgrp = task_cgroup(current, memory_cgrp_id);
>> +
>> +     if (unlikely(!cgrp))
>> +             return -EINVAL;
>> +     if (unlikely(hierarchy))
>> +             return -EINVAL;
>> +     if (unlikely(flags))
>> +             return -EINVAL;
>> +
>> +     return cgrp->kn->id.ino;
>
> ino only is not enough to identify cgroup. It needs generation number too.
> I don't quite see how hierarchy and flags can be used in the future.
> Also why limit it to memcg?
>
> How about something like this instead:
>
> BPF_CALL_2(bpf_get_current_cgroup_id)
> {
>         struct cgroup *cgrp = task_dfl_cgroup(current);
>
>         return cgrp->kn->id.id;
> }
> The user space can use fhandle api to get the same 64-bit id.

I think this should work. This will also be useful to bcc as user
space can encode desired id
in the bpf program and compared that id to the current cgroup id, so we can have
cgroup level tracing (esp. stat collection) support. To cope with
cgroup hierarchy, user can use
cgroup-array based approach or explicitly compare against multiple cgroup id's.
