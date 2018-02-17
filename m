From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] bpf, seccomp: Add eBPF filter capabilities
Date: Fri, 16 Feb 2018 22:29:32 -0800
Message-ID: <CAMp4zn_pNGc+wircCd7Vjwxg7APG1WqrcFt78wFRTzie=POXJw__25599.5407504544$1518848943$gmane$org@mail.gmail.com>
References: <20180213154255.GA3301@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5j+WvVKu8EcEDMJ=HPDtXEhcL7gZX+ic83SVhRU7_+em=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5j+WvVKu8EcEDMJ=HPDtXEhcL7gZX+ic83SVhRU7_+em=w@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 12:34 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Tue, Feb 13, 2018 at 7:42 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>> From: Sargun Dhillon <sargun-5cpTQ645gshBDgjK7y7TUQ@public.gmane.org>
>>
>> This introduces the BPF_PROG_TYPE_SECCOMP bpf program type. It is meant
>> to be used for seccomp filters as an alternative to cBPF filters. The
>> program type has relatively limited capabilities in terms of helpers,
>> but that can be extended later on.
>>
>> It also introduces a new mechanism to attach these filters via the
>> prctl and seccomp syscalls -- SECCOMP_MODE_FILTER_EXTENDED, and
>> SECCOMP_SET_MODE_FILTER_EXTENDED respectively.
>>
>> Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
>> ---
>>  arch/Kconfig                 |   7 ++
>>  include/linux/bpf_types.h    |   3 +
>>  include/uapi/linux/bpf.h     |   2 +
>>  include/uapi/linux/seccomp.h |  15 +++--
>>  kernel/bpf/syscall.c         |   1 +
>>  kernel/seccomp.c             | 148 +++++++++++++++++++++++++++++++++++++------
>>  6 files changed, 150 insertions(+), 26 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index 76c0b54443b1..db675888577c 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -401,6 +401,13 @@ config SECCOMP_FILTER
>>
>>           See Documentation/prctl/seccomp_filter.txt for details.
>>
>> +config SECCOMP_FILTER_EXTENDED
>> +       bool "Extended BPF seccomp filters"
>> +       depends on SECCOMP_FILTER && BPF_SYSCALL
>> +       help
>> +         Enables seccomp filters to be written in eBPF, as opposed
>> +         to just cBPF filters.
>> +
>>  config HAVE_GCC_PLUGINS
>>         bool
>>         help
>> diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
>> index 19b8349a3809..945c65c4e461 100644
>> --- a/include/linux/bpf_types.h
>> +++ b/include/linux/bpf_types.h
>> @@ -22,6 +22,9 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event)
>>  #ifdef CONFIG_CGROUP_BPF
>>  BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_DEVICE, cg_dev)
>>  #endif
>> +#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
>> +BPF_PROG_TYPE(BPF_PROG_TYPE_SECCOMP, seccomp)
>> +#endif
>>
>>  BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
>>  BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index db6bdc375126..5f96cb7ed954 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -1,3 +1,4 @@
>> +
>>  /* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
>>  /* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
>>   *
>> @@ -133,6 +134,7 @@ enum bpf_prog_type {
>>         BPF_PROG_TYPE_SOCK_OPS,
>>         BPF_PROG_TYPE_SK_SKB,
>>         BPF_PROG_TYPE_CGROUP_DEVICE,
>> +       BPF_PROG_TYPE_SECCOMP,
>>  };
>>
>>  enum bpf_attach_type {
>> diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
>> index 2a0bd9dd104d..7da8b39f2a6a 100644
>> --- a/include/uapi/linux/seccomp.h
>> +++ b/include/uapi/linux/seccomp.h
>> @@ -7,14 +7,17 @@
>>
>>
>>  /* Valid values for seccomp.mode and prctl(PR_SET_SECCOMP, <mode>) */
>> -#define SECCOMP_MODE_DISABLED  0 /* seccomp is not in use. */
>> -#define SECCOMP_MODE_STRICT    1 /* uses hard-coded filter. */
>> -#define SECCOMP_MODE_FILTER    2 /* uses user-supplied filter. */
>> +#define SECCOMP_MODE_DISABLED          0 /* seccomp is not in use. */
>> +#define SECCOMP_MODE_STRICT            1 /* uses hard-coded filter. */
>> +#define SECCOMP_MODE_FILTER            2 /* uses user-supplied filter. */
>> +#define SECCOMP_MODE_FILTER_EXTENDED   3 /* uses eBPF filter from fd */
>
> This MODE flag isn't needed: it's still using a filter, and the
> interface changes should be sufficient with
> SECCOMP_SET_MODE_FILTER_EXTENDED below.
>
>>  /* Valid operations for seccomp syscall. */
>> -#define SECCOMP_SET_MODE_STRICT                0
>> -#define SECCOMP_SET_MODE_FILTER                1
>> -#define SECCOMP_GET_ACTION_AVAIL       2
>> +#define SECCOMP_SET_MODE_STRICT                        0
>> +#define SECCOMP_SET_MODE_FILTER                        1
>> +#define SECCOMP_GET_ACTION_AVAIL               2
>> +#define SECCOMP_SET_MODE_FILTER_EXTENDED       3
>
> It seems like this should be a FILTER flag, not a syscall op change?
>
>> +
>>
>>  /* Valid flags for SECCOMP_SET_MODE_FILTER */
>>  #define SECCOMP_FILTER_FLAG_TSYNC      1
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index e24aa3241387..86d6ec8b916d 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -1202,6 +1202,7 @@ static int bpf_prog_load(union bpf_attr *attr)
>>
>>         if (type != BPF_PROG_TYPE_SOCKET_FILTER &&
>>             type != BPF_PROG_TYPE_CGROUP_SKB &&
>> +           type != BPF_PROG_TYPE_SECCOMP &&
>>             !capable(CAP_SYS_ADMIN))
>>                 return -EPERM;
>
> So only init_ns-CAP_SYS_ADMIN would be able to use seccomp eBPF?
>
No, this is specifically so non-init CAP_SYS_ADMIN cal load BPF
filters that are either socket_filter, cgroup_skb, or seccomp.

>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index 940fa408a288..b30dd25c1cb8 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -37,6 +37,7 @@
>>  #include <linux/security.h>
>>  #include <linux/tracehook.h>
>>  #include <linux/uaccess.h>
>> +#include <linux/bpf.h>
>>
>>  /**
>>   * struct seccomp_filter - container for seccomp BPF programs
>> @@ -367,17 +368,6 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
>>
>>         BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
>>
>> -       /*
>> -        * Installing a seccomp filter requires that the task has
>> -        * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
>> -        * This avoids scenarios where unprivileged tasks can affect the
>> -        * behavior of privileged children.
>> -        */
>> -       if (!task_no_new_privs(current) &&
>> -           security_capable_noaudit(current_cred(), current_user_ns(),
>> -                                    CAP_SYS_ADMIN) != 0)
>> -               return ERR_PTR(-EACCES);
>> -
>>         /* Allocate a new seccomp_filter */
>>         sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
>>         if (!sfilter)
>> @@ -423,6 +413,48 @@ seccomp_prepare_user_filter(const char __user *user_filter)
>>         return filter;
>>  }
>>
>> +#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
>> +/**
>> + * seccomp_prepare_extended_filter - prepares a user-supplied eBPF fd
>> + * @user_filter: pointer to the user data containing an fd.
>> + *
>> + * Returns 0 on success and non-zero otherwise.
>> + */
>> +static struct seccomp_filter *
>> +seccomp_prepare_extended_filter(const char __user *user_fd)
>> +{
>> +       struct seccomp_filter *sfilter;
>> +       struct bpf_prog *fp;
>> +       int fd;
>> +
>> +       /* Fetch the fd from userspace */
>> +       if (get_user(fd, (int __user *)user_fd))
>> +               return ERR_PTR(-EFAULT);
>> +
>> +       /* Allocate a new seccomp_filter */
>> +       sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
>> +       if (!sfilter)
>> +               return ERR_PTR(-ENOMEM);
>> +
>> +       fp = bpf_prog_get_type(fd, BPF_PROG_TYPE_SECCOMP);
>> +       if (IS_ERR(fp)) {
>> +               kfree(sfilter);
>> +               return ERR_CAST(fp);
>> +       }
>> +
>> +       sfilter->prog = fp;
>> +       refcount_set(&sfilter->usage, 1);
>> +
>> +       return sfilter;
>> +}
>> +#else
>> +static struct seccomp_filter *
>> +seccomp_prepare_extended_filter(const char __user *filter_fd)
>> +{
>> +       return ERR_PTR(-EINVAL);
>> +}
>> +#endif
>> +
>>  /**
>>   * seccomp_attach_filter: validate and attach filter
>>   * @flags:  flags to change filter behavior
>> @@ -492,7 +524,10 @@ void get_seccomp_filter(struct task_struct *tsk)
>>  static inline void seccomp_filter_free(struct seccomp_filter *filter)
>>  {
>>         if (filter) {
>> -               bpf_prog_destroy(filter->prog);
>> +               if (bpf_prog_was_classic(filter->prog))
>> +                       bpf_prog_destroy(filter->prog);
>> +               else
>> +                       bpf_prog_put(filter->prog);
>>                 kfree(filter);
>>         }
>>  }
>> @@ -842,18 +877,36 @@ static long seccomp_set_mode_strict(void)
>>   * Returns 0 on success or -EINVAL on failure.
>>   */
>>  static long seccomp_set_mode_filter(unsigned int flags,
>> -                                   const char __user *filter)
>> +                                   const char __user *filter,
>> +                                   unsigned long filter_type)
>
> I think this can just live in flags?
>
>>  {
>> -       const unsigned long seccomp_mode = SECCOMP_MODE_FILTER;
>> +       /* We use SECCOMP_MODE_FILTER for both eBPF and cBPF filters */
>> +       const unsigned long filter_mode = SECCOMP_MODE_FILTER;
>>         struct seccomp_filter *prepared = NULL;
>>         long ret = -EINVAL;
>>
>>         /* Validate flags. */
>>         if (flags & ~SECCOMP_FILTER_FLAG_MASK)
>>                 return -EINVAL;
>> +       /*
>> +        * Installing a seccomp filter requires that the task has
>> +        * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
>> +        * This avoids scenarios where unprivileged tasks can affect the
>> +        * behavior of privileged children.
>> +        */
>> +       if (!task_no_new_privs(current) &&
>> +           security_capable_noaudit(current_cred(), current_user_ns(),
>> +                                    CAP_SYS_ADMIN) != 0)
>> +               return -EACCES;
>
> This changes the order of checks -- before, too-large filters would
> get EINVAL even if they lacked the needed permissions. As long as this
> doesn't break anything in the real world, it should be fine, but I
> might want to instead create a perm-check function and just call it in
> both functions. (And likely write a self-test that checks this order,
> if it doesn't already exist.)
>
>>
>>         /* Prepare the new filter before holding any locks. */
>> -       prepared = seccomp_prepare_user_filter(filter);
>> +       if (filter_type == SECCOMP_SET_MODE_FILTER_EXTENDED)
>> +               prepared = seccomp_prepare_extended_filter(filter);
>> +       else if (filter_type == SECCOMP_SET_MODE_FILTER)
>> +               prepared = seccomp_prepare_user_filter(filter);
>> +       else
>> +               return -EINVAL;
>> +
>>         if (IS_ERR(prepared))
>>                 return PTR_ERR(prepared);
>>
>> @@ -867,7 +920,7 @@ static long seccomp_set_mode_filter(unsigned int flags,
>>
>>         spin_lock_irq(&current->sighand->siglock);
>>
>> -       if (!seccomp_may_assign_mode(seccomp_mode))
>> +       if (!seccomp_may_assign_mode(filter_mode))
>>                 goto out;
>>
>>         ret = seccomp_attach_filter(flags, prepared);
>> @@ -876,7 +929,7 @@ static long seccomp_set_mode_filter(unsigned int flags,
>>         /* Do not free the successfully attached filter. */
>>         prepared = NULL;
>>
>> -       seccomp_assign_mode(current, seccomp_mode);
>> +       seccomp_assign_mode(current, filter_mode);
>
> With a filter flag, the above hunks don't need to be changed, for example.
>
>>  out:
>>         spin_unlock_irq(&current->sighand->siglock);
>>         if (flags & SECCOMP_FILTER_FLAG_TSYNC)
>> @@ -926,7 +979,9 @@ static long do_seccomp(unsigned int op, unsigned int flags,
>>                         return -EINVAL;
>>                 return seccomp_set_mode_strict();
>>         case SECCOMP_SET_MODE_FILTER:
>> -               return seccomp_set_mode_filter(flags, uargs);
>> +               return seccomp_set_mode_filter(flags, uargs, op);
>> +       case SECCOMP_SET_MODE_FILTER_EXTENDED:
>> +               return seccomp_set_mode_filter(flags, uargs, op);
>
> And this isn't needed, since it would be passed as a flag.
>
>>         case SECCOMP_GET_ACTION_AVAIL:
>>                 if (flags != 0)
>>                         return -EINVAL;
>> @@ -969,6 +1024,10 @@ long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
>>                 op = SECCOMP_SET_MODE_FILTER;
>>                 uargs = filter;
>>                 break;
>> +       case SECCOMP_MODE_FILTER_EXTENDED:
>> +               op = SECCOMP_SET_MODE_FILTER_EXTENDED;
>> +               uargs = filter;
>> +               break;
>
> Same.
>
>>         default:
>>                 return -EINVAL;
>>         }
>> @@ -1040,8 +1099,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
>>         if (IS_ERR(filter))
>>                 return PTR_ERR(filter);
>>
>> -       fprog = filter->prog->orig_prog;
>> -       if (!fprog) {
>> +       if (!bpf_prog_was_classic(filter->prog)) {
>>                 /* This must be a new non-cBPF filter, since we save
>>                  * every cBPF filter's orig_prog above when
>>                  * CONFIG_CHECKPOINT_RESTORE is enabled.
>> @@ -1050,6 +1108,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
>>                 goto out;
>>         }
>>
>> +       fprog = filter->prog->orig_prog;
>
> I wonder if it would be easier to review to split eBPF install from
> the eBPF "get filter" changes as separate patches?
>
Yes, will respin. Thanks for your feedback. I appreciate the quick review.

>>         ret = fprog->len;
>>         if (!data)
>>                 goto out;
>> @@ -1239,6 +1298,55 @@ static int seccomp_actions_logged_handler(struct ctl_table *ro_table, int write,
>>         return 0;
>>  }
>>
>> +#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
>> +static bool seccomp_is_valid_access(int off, int size,
>> +                                   enum bpf_access_type type,
>> +                                   struct bpf_insn_access_aux *info)
>> +{
>> +       if (type != BPF_READ)
>> +               return false;
>> +
>> +       if (off < 0 || off + size > sizeof(struct seccomp_data))
>> +               return false;
>> +
>> +       switch (off) {
>> +       case bpf_ctx_range_till(struct seccomp_data, args[0], args[5]):
>> +               return (size == sizeof(__u64));
>> +       case bpf_ctx_range(struct seccomp_data, nr):
>> +               return (size == FIELD_SIZEOF(struct seccomp_data, nr));
>> +       case bpf_ctx_range(struct seccomp_data, arch):
>> +               return (size == FIELD_SIZEOF(struct seccomp_data, arch));
>> +       case bpf_ctx_range(struct seccomp_data, instruction_pointer):
>> +               return (size == FIELD_SIZEOF(struct seccomp_data,
>> +                                            instruction_pointer));
>> +       }
>> +
>> +       return false;
>> +}
>> +
>> +static const struct bpf_func_proto *
>> +seccomp_func_proto(enum bpf_func_id func_id)
>> +{
>> +       switch (func_id) {
>> +       case BPF_FUNC_get_current_uid_gid:
>> +               return &bpf_get_current_uid_gid_proto;
>> +       case BPF_FUNC_trace_printk:
>> +               if (capable(CAP_SYS_ADMIN))
>> +                       return bpf_get_trace_printk_proto();
>> +       default:
>> +               return NULL;
>> +       }
>> +}
>
> This makes me so uncomfortable. :) Why is uid/gid needed? Why add
> printk support here? (And why is it CAP_SYS_ADMIN checked if the
> entire filter is CAP_SYS_ADMIN checked before being attached?)
>
See comment above. Anyone can load filters. You can load the filter as
a normal user, drop privliged, and install the filter later with
cap_sys_admin, or no_new_privs.
>> +
>> +const struct bpf_prog_ops seccomp_prog_ops = {
>> +};
>> +
>> +const struct bpf_verifier_ops seccomp_verifier_ops = {
>> +       .get_func_proto         = seccomp_func_proto,
>> +       .is_valid_access        = seccomp_is_valid_access,
>> +};
>> +#endif /* CONFIG_SECCOMP_FILTER_EXTENDED */
>> +
>>  static struct ctl_path seccomp_sysctl_path[] = {
>>         { .procname = "kernel", },
>>         { .procname = "seccomp", },
>> --
>> 2.14.1
>>
>
> -Kees
>
> --
> Kees Cook
> Pixel Security
