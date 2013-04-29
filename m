From: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: For review: user_namespaces(7) man page
Date: Mon, 29 Apr 2013 09:45:45 +0200
Message-ID: <CAFLxGvzXkGcR=Wyx8YZKKRACEnNLMA0xQoDfruq7CT1D-FNLnA__39498.5324507163$1367221558$gmane$org@mail.gmail.com>
References: <CAKgNAkh1TEkQiQ2g2jhbNzVTwpDYOreJt3rAukZCP9H1wh0mLQ@mail.gmail.com>
	<20130315153811.GD24305@sergelap>
	<CAKgNAkiMOGtuCyvhSpku65p1ZJ5SfdYcOxxAU+H-mk-76wqOPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAKgNAkiMOGtuCyvhSpku65p1ZJ5SfdYcOxxAU+H-mk-76wqOPw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 21, 2013 at 4:52 PM, Michael Kerrisk (man-pages)
<mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi Serge,
>
> On Fri, Mar 15, 2013 at 4:38 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
>> Hi,
>>
>> you mention that after creating a new user namespace you at first have
>> all capabilities in the new ns.  You don't explicitly mention (or I
>> missed it - I did see the mention of securebits) that if you want to
>> keep those capabilities after doing an exec, you need to first have
>> something mapped to uid 0 in the userns, and do setuid(0).
>
> Good point. I'll add something on that.
>
>> You might not want to list manpages from other projects,
>
> Actually, not a problem. Many of the pages in my set already do this.
>
>> but Eric's
>> shadow patches introduce some good new manpages as well.  Those aren't yet
>> accepted upstream, but if/when they are then mention at least of
>> subuid(5), subgid(5), and newuidmap(1) and newgidmap(1) might be good.
>
> I'll add those.
>
> Cheers,
>
> Michael

Can we please also document which capabilities are useless within an
user namespace?
E.g. CAP_MKNOD.
You get this capability but the kernel always checks it against the
initial userns.

Thanks,
//richard
