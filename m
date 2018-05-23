From: Y Song <ys114321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC] bpf: tracing: new helper bpf_get_current_cgroup_ino
Date: Tue, 22 May 2018 20:33:24 -0700
Message-ID: <CAH3MdRVdfw52atavT3KL8MpPw7zDM_hR6aUcqDP1PogLn_sH+w__10005.0065936104$1527046345$gmane$org@mail.gmail.com>
References: <20180513173318.21680-1-alban@kinvolk.io>
	<20180521162609.lpdrnozowmzdn57m@ast-mbp.dhcp.thefacebook.com>
	<CAH3MdRWgruVq+3r+2pHTah-c2zTO03vPkepjWDZ0_KrYcroy9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAH3MdRWgruVq+3r+2pHTah-c2zTO03vPkepjWDZ0_KrYcroy9A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

I did a quick prototyping and the above interface seems working fine.

The kernel change:
===============

[yhs@localhost bpf-next]$ git diff
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 97446bbe2ca5..669b7383fddb 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -1976,7 +1976,8 @@ union bpf_attr {
        FN(fib_lookup),                 \
        FN(sock_hash_update),           \
        FN(msg_redirect_hash),          \
-       FN(sk_redirect_hash),
+       FN(sk_redirect_hash),           \
+       FN(get_current_cgroup_id),

 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ce2cbbff27e4..e11e3298f911 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -493,6 +493,21 @@ static const struct bpf_func_proto
bpf_current_task_under_cgroup_proto = {
        .arg2_type      = ARG_ANYTHING,
 };

+BPF_CALL_0(bpf_get_current_cgroup_id)
+{
+       struct cgroup *cgrp = task_dfl_cgroup(current);
+       if (!cgrp)
+               return -EINVAL;
+
+       return cgrp->kn->id.id;
+}
+
+static const struct bpf_func_proto bpf_get_current_cgroup_id_proto = {
+       .func           = bpf_get_current_cgroup_id,
+       .gpl_only       = false,
+       .ret_type       = RET_INTEGER,
+};
+
 BPF_CALL_3(bpf_probe_read_str, void *, dst, u32, size,
           const void *, unsafe_ptr)
 {
@@ -563,6 +578,8 @@ tracing_func_proto(enum bpf_func_id func_id, const
struct bpf_prog *prog)
                return &bpf_get_prandom_u32_proto;
        case BPF_FUNC_probe_read_str:
                return &bpf_probe_read_str_proto;
+       case BPF_FUNC_get_current_cgroup_id:
+               return &bpf_get_current_cgroup_id_proto;
        default:
                return NULL;
        }

The following program can be used to print out a cgroup id given a cgroup path.
[yhs@localhost cg]$ cat get_cgroup_id.c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char **argv)
{
    int dirfd, err, flags, mount_id, fhsize;
    struct file_handle *fhp;
    char *pathname;

    if (argc != 2) {
        printf("usage: %s <cgroup_path>\n", argv[0]);
        return 1;
    }

    pathname = argv[1];
    dirfd = AT_FDCWD;
    flags = 0;

    fhsize = sizeof(*fhp);
    fhp = malloc(fhsize);
    if (!fhp)
        return 1;

    err = name_to_handle_at(dirfd, pathname, fhp, &mount_id, flags);
    if (err >= 0) {
        printf("error\n");
        return 1;
    }

    fhsize = sizeof(struct file_handle) + fhp->handle_bytes;
    fhp = realloc(fhp, fhsize);
    if (!fhp)
        return 1;

    err = name_to_handle_at(dirfd, pathname, fhp, &mount_id, flags);
    if (err < 0)
        perror("name_to_handle_at");
    else {
        int i;

        printf("dir = %s, mount_id = %d\n", pathname, mount_id);
        printf("handle_bytes = %d, handle_type = %d\n", fhp->handle_bytes,
            fhp->handle_type);
        if (fhp->handle_bytes != 8)
            return 1;

        printf("cgroup_id = 0x%llx\n", *(unsigned long long *)fhp->f_handle);
    }

    return 0;
}
[yhs@localhost cg]$

Given a cgroup path, the user can get cgroup_id and use it in their bpf
program for filtering purpose.

I run a simple program t.c
   int main() { while(1) sleep(1); return 0; }
in the cgroup v2 directory /home/yhs/tmp/yhs
   none on /home/yhs/tmp type cgroup2 (rw,relatime,seclabel)

$ ./get_cgroup_id /home/yhs/tmp/yhs
dir = /home/yhs/tmp/yhs, mount_id = 124
handle_bytes = 8, handle_type = 1
cgroup_id = 0x1000006b2

// the below command to get cgroup_id from the kernel for the
// process compiled with t.c and ran under /home/yhs/tmp/yhs:
$ sudo ./trace.py -p 4067 '__x64_sys_nanosleep "cgid = %llx", $cgid'
PID     TID     COMM            FUNC             -
4067    4067    a.out           __x64_sys_nanosleep cgid = 1000006b2
4067    4067    a.out           __x64_sys_nanosleep cgid = 1000006b2
4067    4067    a.out           __x64_sys_nanosleep cgid = 1000006b2
^C[yhs@localhost tools]$

The kernel and user space cgid matches. Will provide a
formal patch later.




On Mon, May 21, 2018 at 5:24 PM, Y Song <ys114321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, May 21, 2018 at 9:26 AM, Alexei Starovoitov
> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Sun, May 13, 2018 at 07:33:18PM +0200, Alban Crequy wrote:
>>>
>>> +BPF_CALL_2(bpf_get_current_cgroup_ino, u32, hierarchy, u64, flags)
>>> +{
>>> +     // TODO: pick the correct hierarchy instead of the mem controller
>>> +     struct cgroup *cgrp = task_cgroup(current, memory_cgrp_id);
>>> +
>>> +     if (unlikely(!cgrp))
>>> +             return -EINVAL;
>>> +     if (unlikely(hierarchy))
>>> +             return -EINVAL;
>>> +     if (unlikely(flags))
>>> +             return -EINVAL;
>>> +
>>> +     return cgrp->kn->id.ino;
>>
>> ino only is not enough to identify cgroup. It needs generation number too.
>> I don't quite see how hierarchy and flags can be used in the future.
>> Also why limit it to memcg?
>>
>> How about something like this instead:
>>
>> BPF_CALL_2(bpf_get_current_cgroup_id)
>> {
>>         struct cgroup *cgrp = task_dfl_cgroup(current);
>>
>>         return cgrp->kn->id.id;
>> }
>> The user space can use fhandle api to get the same 64-bit id.
>
> I think this should work. This will also be useful to bcc as user
> space can encode desired id
> in the bpf program and compared that id to the current cgroup id, so we can have
> cgroup level tracing (esp. stat collection) support. To cope with
> cgroup hierarchy, user can use
> cgroup-array based approach or explicitly compare against multiple cgroup id's.
