From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] newuidmap,newgidmap: New suid helpers for using
	subordinate uids and gids
Date: Mon, 4 Feb 2013 18:31:29 +0000
Message-ID: <20130204183129.GA27179@mail.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com>
 <87ehhdpoag.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ehhdpoag.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Note you need the following bit on top of your patch to make newuidmap
and newgidmap link against libselinux.  Otherwise selinux-enabled builds
(default in ubuntu) fail.

Index: shadow-4.1.5.1/src/Makefile.am
===================================================================
--- shadow-4.1.5.1.orig/src/Makefile.am	2013-02-04 11:56:40.485335430 -0600
+++ shadow-4.1.5.1/src/Makefile.am	2013-02-04 11:57:49.525334261 -0600
@@ -80,6 +80,8 @@
 endif
 
 chage_LDADD    = $(LDADD) $(LIBPAM_SUID) $(LIBAUDIT) $(LIBSELINUX)
+newuidmap_LDADD    = $(LDADD) $(LIBSELINUX)
+newgidmap_LDADD    = $(LDADD) $(LIBSELINUX)
 chfn_LDADD     = $(LDADD) $(LIBPAM) $(LIBSELINUX) $(LIBCRYPT_NOPAM) $(LIBSKEY) $(LIBMD)
 chgpasswd_LDADD = $(LDADD) $(LIBPAM_SUID) $(LIBSELINUX) $(LIBCRYPT)
 chsh_LDADD     = $(LDADD) $(LIBPAM) $(LIBSELINUX) $(LIBCRYPT_NOPAM) $(LIBSKEY) $(LIBMD)
