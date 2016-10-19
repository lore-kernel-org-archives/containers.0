From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not
	read.
Date: Wed, 19 Oct 2016 16:26:41 -0500
Message-ID: <87pomwghda.fsf__4444.31100409037$1476912557$gmane$org@xmission.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Wed, 19 Oct 2016 11:38:18 -0700")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Wed, Oct 19, 2016 at 10:55 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>>
>>> On Wed, Oct 19, 2016 at 10:29 AM, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org> wrote:
>>>> On Wed, Oct 19, 2016 at 11:52:50AM -0500, Eric W. Biederman wrote:
>>>>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>>>>> > Simply ptrace yourself, exec the
>>>>> > program, and then dump the program out.  A program that really wants
>>>>> > to be unreadable should have a stub: the stub is setuid and readable,
>>>>> > but all the stub does is to exec the real program, and the real
>>>>> > program should have mode 0500 or similar.
>>>>> >
>>>>> > ISTM the "right" check would be to enforce that the program's new
>>>>> > creds can read the program, but that will break backwards
>>>>> > compatibility.
>>>>>
>>>>> Last I looked I had the impression that exec of a setuid program kills
>>>>> the ptrace.
>>>>>
>>>>> If we are talking about a exec of a simple unreadable executable (aka
>>>>> something that sets undumpable but is not setuid or setgid).  Then I
>>>>> agree it should break the ptrace as well and since those programs are as
>>>>> rare as hens teeth I don't see any problem with changing the ptrace behavior
>>>>> in that case.
>>>>
>>>> Nope. check_unsafe_exec() sets LSM_UNSAFE_* flags in bprm->unsafe, and then
>>>> the flags are checked by the LSMs and cap_bprm_set_creds() in commoncap.c.
>>>> cap_bprm_set_creds() just degrades the execution to a non-setuid-ish one,
>>>> and e.g. ptracers stay attached.
>>>
>>> I think you're right.  I ought to be completely sure because I rewrote
>>> that code back in 2005 or so back when I thought kernel programming
>>> was only for the cool kids.  It was probably my first kernel patch
>>> ever and it closed an awkward-to-exploit root hole.  But it's been a
>>> while.  (Too bad my second (IIRC) kernel patch was more mundane and
>>> fixed the mute button on "new" Lenovo X60-era laptops and spend
>>> several years in limbo...)
>>
>> Ah yes and this is only a problem if the ptracer does not have
>> CAP_SYS_PTRACE.
>>
>> If the tracer does not have sufficient permissions any opinions on
>> failing the exec or kicking out the ptracer?  I am leaning towards failing
>> the exec as it is more obvious if someone cares.  Dropping the ptracer
>> could be a major mystery.
>
> I would suggest leaving it alone.  Changing it could break enough
> things that a sysctl would be needed, and I just don't see how this is
> a significant issue, especially since it's been insecure forever.
> Anyone who cares should do the stub executable trick:
>
> /sbin/foo: 04755, literally just does execve("/sbin/foo-helper");
>
> /sbin/foo-helper: 0500.

I can't imagine what non-malware would depend on being able to
circumvent file permissions and ptrace a read-only executable.  Is there
something you are thinking of?

I know I saw someone depending on read-only executables being read-only
earlier this week on the security list, and it could definitely act as
part of a counter measure to make binaries harder to exploit.

So given that people actually expect no-read permissions to be honored
on executables (with what seem valid and sensible use cases), that
I can't see any valid reason not to honor no-read permissions, that it
takes a really convoluted setup to bypass the current no-read
permissions, and that I can't believe anyone cares about the current
behavior of ptrace I think this is worth fixing.

Eric
