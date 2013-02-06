From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] newuidmap,newgidmap: New suid helpers for using
	subordinate uids and gids
Date: Wed, 6 Feb 2013 03:00:24 +0000
Message-ID: <20130206030023.GA10917@mail.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com> <87ehhdpoag.fsf@xmission.com>
	<20130204183129.GA27179@mail.hallyn.com>
	<87sj5ai8us.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87sj5ai8us.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Note you need the following bit on top of your patch to make newuidmap
> > and newgidmap link against libselinux.  Otherwise selinux-enabled builds
> > (default in ubuntu) fail.
> 
> Interesting.  I can't imagine what brings in libselinux.  But I am in
> favor of whatever works.

FWIW, it came in through libshadow (presumably shadowio.c which
includes commonio, which calls set_selinux_file_context).  Oh,
I also see newuidmap.c #including subordinateio which includes
commonio.

libtool: link: gcc -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wall -Wl,-Bsymbolic-functions -Wl,-z -Wl,relro -o newgidmap newgidmap.o  ../libmisc/libmisc.a ../lib/.libs/libshadow.a
../lib/.libs/libshadow.a(selinux.o): In function `set_selinux_file_context':
/build/buildd/shadow-4.1.5.1/lib/selinux.c:64: undefined reference to `matchpathcon'
/build/buildd/shadow-4.1.5.1/lib/selinux.c:70: undefined reference to `setfscreatecon'
/build/buildd/shadow-4.1.5.1/lib/selinux.c:75: undefined reference to `freecon'
/build/buildd/shadow-4.1.5.1/lib/selinux.c:58: undefined reference to `is_selinux_enabled'
/build/buildd/shadow-4.1.5.1/lib/selinux.c:65: undefined reference to `security_getenforce'
/build/buildd/shadow-4.1.5.1/lib/selinux.c:71: undefined reference to `security_getenforce'
../lib/.libs/libshadow.a(selinux.o): In function `reset_selinux_file_context':
/build/buildd/shadow-4.1.5.1/lib/selinux.c:94: undefined reference to `setfscreatecon'
/build/buildd/shadow-4.1.5.1/lib/selinux.c:90: undefined reference to `is_selinux_enabled'
collect2: error: ld returned 1 exit status
