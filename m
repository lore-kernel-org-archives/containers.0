From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] subordinateio: Fix subordinate_parse to have an internal
	static buffer
Date: Thu, 24 Jan 2013 15:13:48 -0800
Message-ID: <87bocexjgz.fsf_-_@xmission.com>
References: <87d2wxshu0.fsf@xmission.com> <87liblr344.fsf@xmission.com>
	<20130123182206.GA4468@mail.hallyn.com> <87a9ryyzh2.fsf@xmission.com>
	<20130124225008.GA3816@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130124225008.GA3816@sergelap> (Serge Hallyn's message of "Thu,
	24 Jan 2013 16:50:08 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk
	(man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org


subordinate_parse is supposed to return a static structure that
represents one line in /etc/subuid or /etc/subgid.  I goofed and
failed to make the variable rangebuf that holds the username of
in the returned structure static.

Add this missing static specification.

Reported-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 lib/subordinateio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/subordinateio.c b/lib/subordinateio.c
index 851cfa0..4cca992 100644
--- a/lib/subordinateio.c
+++ b/lib/subordinateio.c
@@ -48,7 +48,7 @@ static void subordinate_free (/*@out@*/ /*@only@*/void *ent)
 static void *subordinate_parse (const char *line)
 {
 	static struct subordinate_range range;
-	char rangebuf[1024];
+	static char rangebuf[1024];
 	int i;
 	char *cp;
 	char *fields[NFIELDS];
-- 
1.7.5.4
