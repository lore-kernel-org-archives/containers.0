From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an
	unreadable file
Date: Thu, 17 Nov 2016 15:28:07 -0800
Message-ID: <CALCETrU8R280foE_AKtUHcUe3rVKjqA06307jBB04ec4dfwObg@mail.gmail.com>
References: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <87inrmavax.fsf_-_@xmission.com>
	<20161117204707.GB10421@1wt.eu>
	<CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Thu, Nov 17, 2016 at 1:07 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Thu, Nov 17, 2016 at 12:47 PM, Willy Tarreau <w@1wt.eu> wrote:
>> On Thu, Nov 17, 2016 at 11:08:22AM -0600, Eric W. Biederman wrote:
>>>
>>> It is the reasonable expectation that if an executable file is not
>>> readable there will be no way for a user without special privileges to
>>> read the file.  This is enforced in ptrace_attach but if we are
>>> already attached there is no enforcement if a readonly executable
>>> is exec'd.
>>
>> I'm really scared by this Eric. At least you want to make it a hardening
>> option that can be disabled at run time, otherwise it can easily break a
>> lot of userspace :
>>
>> admin@aloha:~$ ll /bin/bash /bin/coreutils /bin/ls /usr/bin/telnet
>> -r-xr-x--x 1 root adm 549272 Oct 28 16:25 /bin/bash
>> -rwx--x--x 1 root adm 765624 Oct 28 16:27 /bin/coreutils
>> lrwxrwxrwx 1 root root 9 Oct 28 16:27 /bin/ls -> coreutils
>> -r-xr-x--x 1 root adm  70344 Oct 28 16:34 /usr/bin/telnet
>>
>> And I've not invented it, I've being taught to do this more than 20
>> years ago and been doing this since on any slightly hardened server
>> just because in pratice it's efficient at stopping quite a bunch of
>> rootkits which require to copy and modify your executables. Sure
>> they could get the contents using ptrace, but using cp is much more
>> common than ptrace in scripts and that works. This has prooven quite
>> efficient in field at stopping some rootkits several times over the
>> last two decades and I know I'm not the only one to do it. In fact
>> I *never* install an executable with read permissions for users if
>> there's no need for random users to copy it. Does it mean that
>> nobody should be able to see why their favorite utility doesn't
>> work anymore ? Not in my opinion, at least not by default.
>>
>> So here I fear that we'll break strace at many places where strace
>> precisely matters to debug things.
>>
>> However I'd love to have this feature controlled by a sysctl (to
>> enforce it by default where possible).
>
> I'm not opposed to a sysctl for this. Regardless, I think we need to
> embrace this idea now, though, since we'll soon end up with
> architectures that enforce executable-only memory, in which case
> ptrace will again fail. Almost better to get started here and then not
> have more surprises later.

That won't be a problem because exec-only memory is going to need to
allow ptrace to read it anyway.

--Andy
