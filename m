From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: My netns patches updated to Linus' latest
Date: Thu, 19 Jul 2007 01:05:32 -0600
Message-ID: <m1myxs3mbn.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org



Ok.  Now that I finally have a working version of sysfs I can
start worrying about what else needs to happen to start merging
the network namespace work.

Currently I have two interesting branches available (all essentially
with the same content)

Against the latest -mm
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git#netns/v2.6.22-rc6-mm1-netns23

Against a snapshot of Linus' current tree.
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git#netns/v2.6.22netns24

The code has been reduced to a simple struct net, and a few other
tweaks like removing dev_net_lock from the network namespace structure
have been performed.

There is a config option but all it does at present is enable/disable
the option of cloning the network namespace.

My next project is most likely going to be to dig in and make the
loopback device a normal network device (not statically allocated)
as a cleanup in preparation for the network namespace work.

Feel free to pick the patches apart.   Especially in the core of the
network stack.

I'm hoping to start seriously submitting patches short after the merge
window closes.  So we can get a long test/review cycle.

Eric
