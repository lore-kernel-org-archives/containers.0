From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Tue, 13 Feb 2018 12:35:46 -0800
Message-ID: <CAGXu5jJZgrgLrhkZO33RNdOds8zwnnOZh+rqwguxJM+zm=EJ7g__41226.2456877672$1518554058$gmane$org@mail.gmail.com>
References: <7eb1497e-e5f3-c5ba-e255-7f510795b51d@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7eb1497e-e5f3-c5ba-e255-7f510795b51d-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tom Hromatka <tom.hromatka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 12:33 PM, Tom Hromatka <tom.hromatka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Feb 13, 2018 at 7:42 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>>
>> This patchset enables seccomp filters to be written in eBPF. Although,
>> this patchset doesn't introduce much of the functionality enabled by
>> eBPF, it lays the ground work for it.
>>
>> It also introduces the capability to dump eBPF filters via the PTRACE
>> API in order to make it so that CHECKPOINT_RESTORE will be satisifed.
>> In the attached samples, there's an example of this. One can then use
>> BPF_OBJ_GET_INFO_BY_FD in order to get the actual code of the program,
>> and use that at reload time.
>>
>> The primary reason for not adding maps support in this patchset is
>> to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
>> If we have a map that the BPF program can read, it can potentially
>> "change" privileges after running. It seems like doing writes only
>> is safe, because it can be pure, and side effect free, and therefore
>> not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
>> to an agreement, this can be in a follow-up patchset.
>
>
>
> Coincidentally I also sent an RFC for adding eBPF hash maps to the seccomp
> userspace mailing list just last week:
> https://groups.google.com/forum/#!topic/libseccomp/pX6QkVF0F74
>
> The kernel changes I proposed are in this email:
> https://groups.google.com/d/msg/libseccomp/pX6QkVF0F74/ZUJlwI5qAwAJ
>
> In that email thread, Kees requested that I try out a binary tree in cBPF
> and evaluate its performance.  I just got a rough prototype working, and
> while not as fast as an eBPF hash map, the cBPF binary tree was a
> significant
> improvement over the linear list of ifs that are currently generated.  Also,
> it only required changing a single function within the libseccomp libary
> itself.
>
> https://github.com/drakenclimber/libseccomp/commit/87b36369f17385f5a7a4d95101185577fbf6203b
>
> Here are the results I am currently seeing using an in-house customer's
> seccomp filter and a simplistic test program that runs getppid() thousands
> of times.
>
> Test Case                      minimum TSC ticks to make syscall
> ----------------------------------------------------------------
> seccomp disabled                                             620
> getppid() at the front of 306-syscall seccomp filter         722
> getppid() in middle of 306-syscall seccomp filter           1392
> getppid() at the end of the 306-syscall filter              2452
> seccomp using a 306-syscall-sized EBPF hash map              800
> cBPF filter using a binary tree                              922

I still think that's a crazy filter. :) It should be inverted to just
check the 26 syscalls and a final "greater than" test. I would expect
it to be faster still. :)

-Kees

-- 
Kees Cook
Pixel Security
