From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: LXC+USER integrated patchset
Date: Wed, 10 Nov 2010 11:22:57 -0800
Message-ID: <20101110192256.GA19346@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

FYI,

I just uploaded a patchset for the lxc tree to sourceforge:

	http://lxc.sourceforge.net/patches/lxc+usercr/lxc-0.7.2/lxc-patches/

Feel free to use this patchset to test/play with checkpoint/restart :-)

Excerpts from the 'cover-letter' in the patchset:
| These patches apply on top of lxc-0.7.2.
|
| The patches mainly pull user-cr into the lxc source tree and enable
| building LXC with integrated support for C/R.
|
| These patches should work with a recent kernel ( 2.6.32 or later) and
| with the ckpt-v22-dev branch of the Linux C/R tree:
| 
| 	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
|
| The FD_NOCHECKPOINT (which is an expermental patch) and NR_eclone should be
| the only changes dependent on kernel changes. The error from
|
|         fcntl(FD_NOCHECKPOINT)
|
| is silently ignored for now, so it should not be a problem. But please
| report any problems you encounter :-)

Sukadev
