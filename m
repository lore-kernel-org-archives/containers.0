From: Y Song <ys114321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC] bpf: tracing: new helper bpf_get_current_cgroup_ino
Date: Mon, 14 May 2018 12:38:39 -0700
Message-ID: <CAH3MdRUe7K8zJHuGAfnY6_VEkBLAWY1F_WaJgcLs4qDdQv1bTA__47133.6255818189$1526326640$gmane$org@mail.gmail.com>
References: <20180513173318.21680-1-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180513173318.21680-1-alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, May 13, 2018 at 10:33 AM, Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> From: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
>
> bpf_get_current_cgroup_ino() allows BPF trace programs to get the inode
> of the cgroup where the current process resides.
>
> My use case is to get statistics about syscalls done by a specific
> Kubernetes container. I have a tracepoint on raw_syscalls/sys_enter and
> a BPF map containing the cgroup inode that I want to trace. I use
> bpf_get_current_cgroup_ino() and I quickly return from the tracepoint if
> the inode is not in the BPF hash map.

Alternatively, the kernel already has bpf_current_task_under_cgroup helper
which uses a cgroup array to store cgroup fd's. If the current task is
in the hierarchy of a particular cgroup, the helper will return true.

One difference between your helper and bpf_current_task_under_cgroup() is
that your helper tests against a particular cgroup, not including its
children, but
bpf_current_task_under_cgroup() will return true even the task is in a
nested cgroup.

Maybe this will work for you?

>
> Without this BPF helper, I would need to keep track of all pids in the
> container. The Netlink proc connector can be used to follow process
> creation and destruction but it is racy.
>
> This patch only looks at the memory cgroup, which was enough for me
> since each Kubernetes container is placed in a different mem cgroup.
> For a generic implementation, I'm not sure how to proceed: it seems I
> would need to use 'for_each_root(root)' (see example in
> proc_cgroup_show() from kernel/cgroup/cgroup.c) but I don't know if
> taking the cgroup mutex is possible in the BPF helper function. It might
> be ok in the tracepoint raw_syscalls/sys_enter but could the mutex
> already be taken in some other tracepoints?

mutex is not allowed in a helper since it can block.

>
> Signed-off-by: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
> ---
>  include/uapi/linux/bpf.h | 11 ++++++++++-
>  kernel/trace/bpf_trace.c | 25 +++++++++++++++++++++++++
>  2 files changed, 35 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index c5ec89732a8d..38ac3959cdf3 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -755,6 +755,14 @@ union bpf_attr {
>   *     @addr: pointer to struct sockaddr to bind socket to
>   *     @addr_len: length of sockaddr structure
>   *     Return: 0 on success or negative error code
> + *
> + * u64 bpf_get_current_cgroup_ino(hierarchy, flags)
> + *     Get the cgroup{1,2} inode of current task under the specified hierarchy.
> + *     @hierarchy: cgroup hierarchy

Not sure what is the value to specify hierarchy here.
A cgroup directory fd?

> + *     @flags: reserved for future use
> + *     Return:
> + *       == 0 error

looks like < 0 means error.

> + *        > 0 inode of the cgroup
               >= 0 means good?
>   */
>  #define __BPF_FUNC_MAPPER(FN)          \
>         FN(unspec),                     \
> @@ -821,7 +829,8 @@ union bpf_attr {
>         FN(msg_apply_bytes),            \
>         FN(msg_cork_bytes),             \
>         FN(msg_pull_data),              \
> -       FN(bind),
> +       FN(bind),                       \
> +       FN(get_current_cgroup_ino),
>
>  /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>   * function eBPF program intends to call
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 56ba0f2a01db..9bf92a786639 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -524,6 +524,29 @@ static const struct bpf_func_proto bpf_probe_read_str_proto = {
>         .arg3_type      = ARG_ANYTHING,
>  };
>
> +BPF_CALL_2(bpf_get_current_cgroup_ino, u32, hierarchy, u64, flags)
> +{
> +       // TODO: pick the correct hierarchy instead of the mem controller
> +       struct cgroup *cgrp = task_cgroup(current, memory_cgrp_id);
> +
> +       if (unlikely(!cgrp))
> +               return -EINVAL;
> +       if (unlikely(hierarchy))
> +               return -EINVAL;
> +       if (unlikely(flags))
> +               return -EINVAL;
> +
> +       return cgrp->kn->id.ino;
> +}
> +
> +static const struct bpf_func_proto bpf_get_current_cgroup_ino_proto = {
> +       .func           = bpf_get_current_cgroup_ino,
> +       .gpl_only       = false,
> +       .ret_type       = RET_INTEGER,
> +       .arg1_type      = ARG_DONTCARE,
> +       .arg2_type      = ARG_DONTCARE,
> +};
> +
>  static const struct bpf_func_proto *
>  tracing_func_proto(enum bpf_func_id func_id, const struct bpf_prog *prog)
>  {
> @@ -564,6 +587,8 @@ tracing_func_proto(enum bpf_func_id func_id, const struct bpf_prog *prog)
>                 return &bpf_get_prandom_u32_proto;
>         case BPF_FUNC_probe_read_str:
>                 return &bpf_probe_read_str_proto;
> +       case BPF_FUNC_get_current_cgroup_ino:
> +               return &bpf_get_current_cgroup_ino_proto;
>         default:
>                 return NULL;
>         }
> --
> 2.14.3
>
