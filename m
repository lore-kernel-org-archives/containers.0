From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not
	read.
Date: Wed, 19 Oct 2016 19:29:17 +0200
Message-ID: <20161019172917.GE1210__3443.02555681697$1476898193$gmane$org@laptop.thejh.net>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz>
	<8737jt903u.fsf@xmission.com> <20161018150507.GP14666@pc.thejh.net>
	<87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net>
	<87r37dnz74.fsf@xmission.com> <87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Oct 19, 2016 at 11:52:50AM -0500, Eric W. Biederman wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
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
> 
> If we are talking about a exec of a simple unreadable executable (aka
> something that sets undumpable but is not setuid or setgid).  Then I
> agree it should break the ptrace as well and since those programs are as
> rare as hens teeth I don't see any problem with changing the ptrace behavior
> in that case.

Nope. check_unsafe_exec() sets LSM_UNSAFE_* flags in bprm->unsafe, and then
the flags are checked by the LSMs and cap_bprm_set_creds() in commoncap.c.
cap_bprm_set_creds() just degrades the execution to a non-setuid-ish one,
and e.g. ptracers stay attached.

Same thing happens if the fs struct is shared with another process or if
NO_NEW_PRIVS is active.

(Actually, it's still a bit like normal setuid execution: IIRC AT_SECURE
stays active, and the resulting process still won't be dumpable, so it's
not possible for a *new* ptracer to attach afterwards. But this is just
from memory, I'm not entirely sure.)
