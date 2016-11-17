From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/3] ptrace: Capture the ptracer's creds not
	PT_PTRACE_CAP
Date: Thu, 17 Nov 2016 17:44:46 -0600
Message-ID: <87twb5y8lt.fsf__30683.4986353808$1479426458$gmane$org@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <87oa1eavfx.fsf_-_@xmission.com>
	<CALCETrUSnPfzpabQMNuyOu09j9QDzRDeoQVF_U51=ow3bP5pkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrUSnPfzpabQMNuyOu09j9QDzRDeoQVF_U51=ow3bP5pkw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Thu, 17 Nov 2016 15:27:09 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Thu, Nov 17, 2016 at 9:05 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> When the flag PT_PTRACE_CAP was added the PTRACE_TRACEME path was
>> overlooked.  This can result in incorrect behavior when an application
>> like strace traces an exec of a setuid executable.
>>
>> Further PT_PTRACE_CAP does not have enough information for making good
>> security decisions as it does not report which user namespace the
>> capability is in.  This has already allowed one mistake through
>> insufficient granulariy.
>>
>> I found this issue when I was testing another corner case of exec and
>> discovered that I could not get strace to set PT_PTRACE_CAP even when
>> running strace as root with a full set of caps.
>>
>> This change fixes the above issue with strace allowing stracing as
>> root a setuid executable without disabling setuid.  More fundamentaly
>> this change allows what is allowable at all times, by using the correct
>> information in it's decision.
>>
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Fixes: 4214e42f96d4 ("v2.4.9.11 -> v2.4.9.12")
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  fs/exec.c                  |  2 +-
>>  include/linux/capability.h |  1 +
>>  include/linux/ptrace.h     |  1 -
>>  include/linux/sched.h      |  1 +
>>  kernel/capability.c        | 20 ++++++++++++++++++++
>>  kernel/ptrace.c            | 12 +++++++-----
>>  6 files changed, 30 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index 6fcfb3f7b137..fdec760bfac3 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -1401,7 +1401,7 @@ static void check_unsafe_exec(struct linux_binprm *bprm)
>>         unsigned n_fs;
>>
>>         if (p->ptrace) {
>> -               if (p->ptrace & PT_PTRACE_CAP)
>> +               if (ptracer_capable(p, current_user_ns()))
>
> IIRC PT_PTRACE_CAP was added to prevent TOCTOU races.  What prevents
> that type of race now?  For that matter, what guarantees that we've
> already switched to new creds here and will continue to do so in the
> future?

Because instead of capturing a single bit we now capture tracers
entire credentials in tsk->ptracer_cred.   As such tsk->ptracer_cred
never changes except when ptracing begins or ends, and we remain
safe for TOCTOU races.

We do hold cred_guard_mutex here so that guarantees we get a new
ptracer.  So the worst that can happen here is our tracer detaches
and ptracer_capable will uncondintionally return true.

Eric
