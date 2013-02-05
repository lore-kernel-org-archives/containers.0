From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] newuidmap,newgidmap: New suid helpers for using
	subordinate uids and gids
Date: Tue, 5 Feb 2013 17:20:02 +0000
Message-ID: <20130205172002.GA3516__215.695220004086$1360087688$gmane$org@mail.hallyn.com>
References: <87d2wxshu0.fsf@xmission.com> <87ehhdpoag.fsf@xmission.com>
	<20130204183129.GA27179@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130204183129.GA27179-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

Another patch needed, to handle the shortopts in usermod, and add
a missing break when handling wlfg (leading to Wflg being handled
as well).

Index: shadow-userns/src/usermod.c
===================================================================
--- shadow-userns.orig/src/usermod.c	2013-02-05 16:35:10.608485591 +0000
+++ shadow-userns/src/usermod.c	2013-02-05 17:16:20.540485591 +0000
@@ -993,9 +993,9 @@
 		};
 		while ((c = getopt_long (argc, argv,
 #ifdef WITH_SELINUX
-			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:UZ:",
+			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:UZ:v:w:V:W:",
 #else				/* !WITH_SELINUX */
-			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:U",
+			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:Uv:w:V:W:",
 #endif				/* !WITH_SELINUX */
 			                 long_options, NULL)) != -1) {
 			switch (c) {
@@ -1141,6 +1141,7 @@
 					exit(E_BAD_ARG);
 				}
 				wflg = true;
+                break;
 			case 'W':
 				if (prepend_range (optarg, &del_sub_gids) == 0) {
 					fprintf (stderr,
