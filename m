From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: For review: pid_namespaces(7) man page
Date: Mon, 04 Mar 2013 13:27:47 -0600
Message-ID: <1362425267.7276.1@driftwood>
References: <876217olp0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <876217olp0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (from ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org on
	Sun Mar  3 22:03:55 2013)
Content-Disposition: inline
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
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/03/2013 10:03:55 PM, Eric W. Biederman wrote:
> Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org> writes:
> 
> > On 03/01/2013 03:57:40 AM, Michael Kerrisk (man-pages) wrote:
> >> > And yet the glibc guys insist on #define
> >> GNU_GNU_GNU_ALL_HAIL_STALLMAN in
> >> > order to access this Linux-specific feature which has nothing
> >> whatsoever to
> >> > do with the FSF.
> >>
> >> This is a misunderstanding. _GNU_SOURCE is the standard way to  
> expose
> >> Linux-specific functionality from POSIX header files.
> >
> > What standard? The Linux kernel is not, and never was, part of the  
> GNU
> > project.
> 
> Is the argument that there should be a _LINUX_SOURCE directive in  
> glibc
> for this?

If you don't #define any feature test macros at all, you get a bunch of  
macros (_BSD_SOURCE, _SVID_SOURCE, _POSIX_SOURCE,  
_POSIX_C_SOURCE=200809L, and so on) defined by default in features.h.  
If you start defining macros, several of the default ones _go_away_,  
and you start missing things that are defined by posix-2008. Yes,  
defining feature test macros makes definitions _vanish_ out of the  
headers, which means feature test macros can actually reduce code  
portability.

The _GNU_SOURCE is glibc's way of saying "switch on everything glibc  
offers". (Except it isn't _quite_, but that seems to be what they  
intended.) So there are various things that test _specifically_ for  
that macro, but the macro also switches on (from features.h):

/* If _GNU_SOURCE was defined by the user, turn on all the other  
features.  */
#ifdef _GNU_SOURCE
# undef  _ISOC95_SOURCE
# define _ISOC95_SOURCE 1
# undef  _ISOC99_SOURCE
# define _ISOC99_SOURCE 1
# undef  _POSIX_SOURCE
# define _POSIX_SOURCE  1
# undef  _POSIX_C_SOURCE
# define _POSIX_C_SOURCE        200809L
# undef  _XOPEN_SOURCE
# define _XOPEN_SOURCE  700
# undef  _XOPEN_SOURCE_EXTENDED
# define _XOPEN_SOURCE_EXTENDED 1
# undef  _LARGEFILE64_SOURCE
# define _LARGEFILE64_SOURCE    1
# undef  _BSD_SOURCE
# define _BSD_SOURCE    1
# undef  _SVID_SOURCE
# define _SVID_SOURCE   1
# undef  _ATFILE_SOURCE
# define _ATFILE_SOURCE 1
#endif

This is not fine-grained control of what libc exports. This is "if you  
want to use unshare() then everything we ever implemented gets  
simultaneously exported into your namespace". (Which it _mostly_ is if  
you never use any feature test macros, but not the Linux-specific  
system calls.)

The new musl-libc.org did an _ALL_SOURCE macro that just enables every  
feature test macro they implemented. (That's its definition, it's the  
feature test macro that says feature test macros area bad idea.)

> Although come to think of it I can't imagine how <sched.h> is a POSIX
> header.  Last I looked it only had linux specific bits in it.  Which
> makes needing any kind of #define strange.

My objection is that Linux system calls are not part of the GNU  
project. Requiring that macro to get Linux system calls out of bionic,  
uClibc, klibc, musl, olibc, dietlibc, or newlib is _silly_. It's the  
"GNU/Linux" prefix imposed on the source level, and it's a fairly  
recent development (I've only noticed it since 2008 or so).

Rob
