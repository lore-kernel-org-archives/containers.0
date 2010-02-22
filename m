From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] cr_tests: Filesystem tests
Date: Mon, 22 Feb 2010 12:02:25 -0600
Message-ID: <20100222180225.GA9031@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266632337-13792-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> These filesystem-related tests for unlinked file support and
> dnotify are expected to fail so long as those features are
> unsupported by c/r.
> 
> PATCH 1/9 Add tests for checkpoint/restart of unlinked files.
> PATCH 2/9 Add a do_ckpt utility (for python scripts)
> PATCH 3/9 A tool to create a random tree of dirs and files
> PATCH 4/9 A tool to re-fill a tree of dirs and files
> PATCH 5/9 A tool to check a tree of files and dirs
> PATCH 6/9 Add script to hold an unlinked tree
> PATCH 7/9 Add random tree test
> PATCH 8/9 Add unlinked fifo test
> PATCH 9/9 Add fsnotify test for dnotify

Ok, I went ahead and pushed them to branch master, since they
aren't hooked into cr_tests/runall.sh yet.  But at the moment
I find that ./hold_unlinked_tree.py hangs, and notify/run.sh
reports failure when it should fail success for now.

thanks,
-serge
