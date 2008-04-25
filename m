From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Userspace checkpoint/restart hack: cryo
Date: Fri, 25 Apr 2008 10:24:19 -0700
Message-ID: <1209144259.12718.46.camel@nimitz.home.sr71.net>
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
To: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

A guy named Marc Vertes wrote this as a little demonstration of
checkpoint/restart.  I've been using it to experiment with
checkpoint/restart.  I thought it might be of some use as we move
subsystems to being helped by the kernel to checkpoint and restart.

It's ptrace-based, and stuck on i386 for now.  It can probably be ported
elsewhere without too much trouble.    It doesn't support *anything
fancy like multuiple tasks :).  It has the advantage of being very
feature-bare, and I think it is pretty easy to hack on.  Whatever c/r
support we add to the kernel could easily be added on and tested.

http://userweb.kernel.org/~daveh/cryo/cryo-001.tar.gz

Usage:
	cr -p `pidof task` > checkpoint.cryo 
	cr -r < checkpoint.cryo

If anyone else has something simpler or easier to hack on, I'm all ears.

-- Dave
