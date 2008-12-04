From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: checkpointing VFS internals
Date: Thu, 04 Dec 2008 07:01:24 -0800
Message-ID: <1228402884.13111.67.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Try the following:

	mkdir foo bar
	mount --bind foo bar
	(date; cat) > bar/file

In another terminal:

	cat bar/file
	umount bar # should say busy
	umount -l bar
	cat bar/file # -EEXIST

# ls -l /proc/`pidof cat`/fd/
total 0
lrwx------ 1 dave dave 64 2008-12-04 06:50 0 -> /dev/pts/22
l-wx------ 1 dave dave 64 2008-12-04 06:50 1 -> barfile
lrwx------ 1 dave dave 64 2008-12-04 06:50 2 -> /dev/pts/22

You can still read and write to /proc/`pidof cat`/fd/1 as you would
probably expect.  But, there's no sign of the mount in /proc/mounts
or /proc/$pid/{mounts,mountinfo,stats}.  There's no apparent way to
checkpoint this from userspace currently.  This is basically the
unlinked but open file problem, but with mounts.

Should we work on getting the lazy unmounts in those files?  Or, is this
a case for checkpointing the mounts internally to the kernel just as we
do with unlinked files?

-- Dave
