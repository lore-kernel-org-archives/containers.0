From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC 1/3] seccomp: add a return code to trap to userspace
Date: Mon, 26 Feb 2018 19:27:51 -0800
Message-ID: <6314EDD9-2B0F-454C-9B99-E57694DC7AE1@amacapital.net>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180204104946.25559-2-tycho@tycho.ws>
	<CAGXu5jLAAKY19a9iC1PmXRyuwdn1Zxr2Cb318zdzkqgYt8vtdg@mail.gmail.com>
	<20180214152958.cjgwh2k52zji2jxk@cisco>
	<CALCETrXeZZfVzXh7SwKhyB=+ySDk5fhrrdrXrcABsQ=JpQT7Tg@mail.gmail.com>
	<CAGXu5jKBmej+fXhEc+Jy7Guy+vXEZkHnc=4LNm1NNEsc1=DFVA@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jKBmej+fXhEc+Jy7Guy+vXEZkHnc=4LNm1NNEsc1=DFVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org



> On Feb 26, 2018, at 4:49 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> 
>> On Wed, Feb 14, 2018 at 9:19 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>> On Wed, Feb 14, 2018 at 3:29 PM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
>>>> On Tue, Feb 13, 2018 at 01:09:20PM -0800, Kees Cook wrote:
>>>> On Sun, Feb 4, 2018 at 2:49 AM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
>>>> I wonder if this communication should be netlink, which gives a more
>>>> well-structured way to describe what's on the wire? The reason I ask
>>>> is because if we ever change the seccomp_data structure, we'll now
>>>> have two places where we need to deal with it (the first being within
>>>> the BPF itself). My initial idea was to prefix the communication with
>>>> a size field, then send the structure, and then I had nightmares, and
>>>> realized this was basically netlink reinvented.
>>> 
>>> I suggested netlink in LA, and everyone (especially Andy) groaned very
>>> loudly :). I'm happy to switch it to netlink if you like, although i
>>> think memcpy() of structs should be safe here, since the return value
>>> from read or write can indicate the size of things.
>> 
>> I could easily get on board with "netlink" (i.e. NLA) messages sent
>> over an fd.  I will object strongly to the use of netlink *sockets*.
> 
> Yeah, I was thinking NLA over the fd; not a netlink socket.
> 
>>>> An ERRNO filter would block a USER_NOTIF because it's unconditional.
>>>> TRACE could be either, USER_NOTIF could be either.
>>>> 
>>>> This means TRACE rules would be bumped by a USER_NOTIF... hmm.
>>> 
>>> Yes, I didn't exactly know what to do here. ERRNO, TRAP, and KILL all
>>> seemed more important than USER_NOTIF, but TRACE didn't. I don't have
>>> a strong opinion about what to do here, because users can adjust their
>>> filters accordingly. Let me know what you prefer.
>> 
>> If we switched to eBPF functions, this whole issue goes away.
> 
> Yeah, though we'd still need some kind of "wait for answer" eBPF
> function. It feels wrong to re-use maps for that...
> 

BPF_CALL.

Alexei, can we make it so that each bpf program type can easily limit which BPF_CALL helpers can be use and allow bpf program types to add their own helpers?c
