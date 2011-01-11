From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: linux-cr:  v23-rc1 pushed
Date: Mon, 10 Jan 2011 20:18:12 -0500
Message-ID: <4D2BAFD4.1080400@cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Folks,

I just pushed out a new v23-rc1 branch of linux-cr. This one is
rebased to 2.6.37, and contains nearly all the patches pulled
on v22-dev. I only gave it a brief test drive... feel free to 
throw all your ammo it.

Rebasing was fairly straightforward, but I'd feel more comfortable 
with more eyes looking at some code, specifically:

userns [Serge ?]
sockets [Dan ?]
cgroup_freezer [Matt ?]

I skipped PowerPC patches and ARM patches. Nathan, Christoffer -
can you take a look at those, respectively, and re-post to list ?

For the "final" v23, I'm hoping to add at least the logic for
unlinked files and inotify-and-friends; so now is probably a
good time to start circulating them ... (hint!)

There are some updates and fixes to user-cr too, mainly pulling
(and reworking) suka's old cleanup patches, and updating the
include files.

I also pulled and reworked Suka's patches for file-locks, and 
Nathan's patches for hugetlb - will post those seperately.

Happy New Year,

Oren.
