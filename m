From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [net-next v2 1/2] bpf, seccomp: Add eBPF filter capabilities
Date: Tue, 20 Feb 2018 23:31:13 -0800
Message-ID: <CAMp4zn8B5ksZh=_9PpxySnySfcFkw-DTT4U3R+jakCYRztRtzQ@mail.gmail.com>
References: <20180219162159.GA11474@ircssh-2.c.rugged-nimbus-611.internal>
	<37135c70-bb09-c4ac-e81d-dc161724292b@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <37135c70-bb09-c4ac-e81d-dc161724292b-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 19, 2018 at 4:00 PM, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org> wrote:
> On 02/19/2018 05:22 PM, Sargun Dhillon wrote:
>> This introduces the BPF_PROG_TYPE_SECCOMP bpf program type. It is meant
>> to be used for seccomp filters as an alternative to cBPF filters. The
>> program type has relatively limited capabilities in terms of helpers,
>> but that can be extended later on.
>>
>> The eBPF code loading is separated from attachment of the filter, so
>> a privileged user can load the filter, and pass it back to an
>> unprivileged user who can attach it and use it at a later time.
>>
>> In order to attach the filter itself, you need to supply a flag to the
>> seccomp syscall indicating that a eBPF filter is being attached, as
>> opposed to a cBPF one. Verification occurs at program load time,
>> so the user should only receive errors related to attachment.
>>
>> Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
> [...]
>> @@ -867,7 +924,7 @@ static long seccomp_set_mode_filter(unsigned int flags,
>>
>>       spin_lock_irq(&current->sighand->siglock);
>>
>> -     if (!seccomp_may_assign_mode(seccomp_mode))
>> +     if (!seccomp_may_assign_mode(filter_mode))
>>               goto out;
>>
>>       ret = seccomp_attach_filter(flags, prepared);
>> @@ -876,7 +933,7 @@ static long seccomp_set_mode_filter(unsigned int flags,
>>       /* Do not free the successfully attached filter. */
>>       prepared = NULL;
>>
>> -     seccomp_assign_mode(current, seccomp_mode);
>> +     seccomp_assign_mode(current, filter_mode);
>>  out:
>>       spin_unlock_irq(&current->sighand->siglock);
>>       if (flags & SECCOMP_FILTER_FLAG_TSYNC)
>> @@ -1040,8 +1097,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
>>       if (IS_ERR(filter))
>>               return PTR_ERR(filter);
>>
>> -     fprog = filter->prog->orig_prog;
>> -     if (!fprog) {
>> +     if (!bpf_prog_was_classic(filter->prog)) {
>
> This is actually a bug, see f8e529ed941b ("seccomp, ptrace: add support for
> dumping seccomp filters") and would cause a NULL ptr deref in case the filter
> was created with bpf_prog_create_from_user() with save_orig as false, so the
> if (!fprog) test for cBPF cannot be removed from here.
>
Isn't this function within:
#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
#endif

And, above, where bpf_prog_create_from_user is, save_prog is derived from:
const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);

Are there any other places this can be loaded, or this function can be
exposes if CONFIG_CHECKPOINT_RESTORE = n?


>>               /* This must be a new non-cBPF filter, since we save
>>                * every cBPF filter's orig_prog above when
>>                * CONFIG_CHECKPOINT_RESTORE is enabled.
>> @@ -1050,6 +1106,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
>>               goto out;
>>       }
>>
>> +     fprog = filter->prog->orig_prog;
>>       ret = fprog->len;
>
> (See above.)
>
>>       if (!data)
>>               goto out;
>> @@ -1239,6 +1296,58 @@ static int seccomp_actions_logged_handler(struct ctl_table *ro_table, int write,
>>       return 0;
>>  }
>>
>> +#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
>> +static bool seccomp_is_valid_access(int off, int size,
>> +                                 enum bpf_access_type type,
>> +                                 struct bpf_insn_access_aux *info)
>> +{
>> +     if (type != BPF_READ)
>> +             return false;
>> +
>> +     if (off < 0 || off + size > sizeof(struct seccomp_data))
>> +             return false;
>
>         if (off % size != 0)
>                 return false;
>
>> +     switch (off) {
>> +     case bpf_ctx_range_till(struct seccomp_data, args[0], args[5]):
>> +             return (size == sizeof(__u64));
>> +     case bpf_ctx_range(struct seccomp_data, nr):
>> +             return (size == FIELD_SIZEOF(struct seccomp_data, nr));
>> +     case bpf_ctx_range(struct seccomp_data, arch):
>> +             return (size == FIELD_SIZEOF(struct seccomp_data, arch));
>> +     case bpf_ctx_range(struct seccomp_data, instruction_pointer):
>> +             return (size == FIELD_SIZEOF(struct seccomp_data,
>> +                                          instruction_pointer));
>
>         default:
>                 return false;
>
> [...]
>> +static const struct bpf_func_proto *
>> +seccomp_func_proto(enum bpf_func_id func_id)
>> +{
>> +     switch (func_id) {
>> +     case BPF_FUNC_get_current_uid_gid:
>> +             return &bpf_get_current_uid_gid_proto;
>> +     case BPF_FUNC_ktime_get_ns:
>> +             return &bpf_ktime_get_ns_proto;
>> +     case BPF_FUNC_get_prandom_u32:
>> +             return &bpf_get_prandom_u32_proto;
>> +     case BPF_FUNC_get_current_pid_tgid:
>> +             return &bpf_get_current_pid_tgid_proto;
>
> Do you have a use-case description for the above helpers? Is the prandom/ktime
> one for simulating errors coming from the syscall? And the other two for
> orchestration purposes?
>
> One use case this work could enable would be to implement state machines in BPF
> for BPF-seccomp and enabling a more fine-grained / tiny subset of syscalls based
> on the state the prog is in while the rest is all blocked out - as opposed to a
> global white/black-list of syscalls the app can do in general. Getting to such
> an app model would probably be rather challenging at least for complex apps. We'd
> need some sort of scratch buffer for keeping the state for this though, e.g. either
> map with single slot or per thread scratch space. Anyway, just a thought.
>
>> +     default:
>> +             return NULL;
>> +     }
>> +}
>> +
>> +const struct bpf_prog_ops seccomp_prog_ops = {
>> +};
>> +
>> +const struct bpf_verifier_ops seccomp_verifier_ops = {
>> +     .get_func_proto         = seccomp_func_proto,
>> +     .is_valid_access        = seccomp_is_valid_access,
>> +};
>> +#endif /* CONFIG_SECCOMP_FILTER_EXTENDED */
>> +
>>  static struct ctl_path seccomp_sysctl_path[] = {
>>       { .procname = "kernel", },
>>       { .procname = "seccomp", },
>>
>
