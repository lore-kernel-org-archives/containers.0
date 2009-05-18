From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: cr test cases moved
Date: Mon, 18 May 2009 16:29:38 -0500
Message-ID: <20090518212938.GA21867@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

I was keeping a few automated testcases in a tarball under
sf.net/projects/lxc.  I've moved these to a git tree which you
can fetch using

	git clone git://git.sr71.net/~hallyn/cr_tests.git

Two purposes for these:  first, to eventually hook some of them
into LTP.  Second, to try and let people easily and reliably
reproduce tests across arches.  For instance, it appears the
fileio test has problems on x86, while it works fine on s390.
The (not-yet-automated) sleep testcase shows that restart blocks
on s390 aren't yet working, but I've not yet tested on x86 to
make sure those work at all.

Suka, please let me know if the fileio test succeeds on your
x86 box.  If you could also try the sleep testcase, I'd be
very interested.

thanks,
-serge
