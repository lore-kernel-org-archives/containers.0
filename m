From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not
	read.
Date: Wed, 19 Oct 2016 11:36:30 -0700
Message-ID: <CALCETrXMZ-3_T5Bucfyeh2nusLjOe50E1MoM3mRNzjrNkJppzg__25308.1815004863$1476902232$gmane$org@mail.gmail.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz>
	<8737jt903u.fsf@xmission.com> <20161018150507.GP14666@pc.thejh.net>
	<87twc9656s.fsf@xmission.com> <20161018191206.GA1210@laptop.thejh.net>
	<87r37dnz74.fsf@xmission.com> <87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87y41kjn6l.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Oct 19, 2016 9:54 AM, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>
> > On Tue, Oct 18, 2016 at 2:15 PM, Eric W. Biederman
> > <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> >>
> >> When the user namespace support was merged the need to prevent
> >> ptracing an executable that is not readable was overlooked.
> >
> > Before getting too excited about this fix, isn't there a much bigger
> > hole that's been there forever?
>
> In this case it was a newish hole (2011) that the user namespace support
> added that I am closing.  I am not super excited but I figure it is
> useful to make the kernel semantics at least as secure as they were
> before.
>

But if it was never secure in the first place...

> > Simply ptrace yourself, exec the
> > program, and then dump the program out.  A program that really wants
> > to be unreadable should have a stub: the stub is setuid and readable,
> > but all the stub does is to exec the real program, and the real
> > program should have mode 0500 or similar.
> >
> > ISTM the "right" check would be to enforce that the program's new
> > creds can read the program, but that will break backwards
> > compatibility.
>
> Last I looked I had the impression that exec of a setuid program kills
> the ptrace.

I thought it killed the setuid, not the ptrace.

(I ought to know because I rewrote that code back in 2005 or so back when I
thought kernel programming was only for the cool kids.  It was probably my
first kernel patch ever and it fixed an awkward-to-exploit race.  But it's
been a while.)
