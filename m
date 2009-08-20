From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/8] Revert commit 8827c288feb7810185aa7c2e37537202fc709869
Date: Thu, 20 Aug 2009 14:13:49 -0700
Message-ID: <20090820141349.9967b275.akpm__47277.084660209$1250803091$gmane$org@linux-foundation.org>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235812.22531.76212.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090818235812.22531.76212.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 18 Aug 2009 16:58:12 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Revert commit 8827c288feb7810185aa7c2e37537202fc709869
> 
> This is in preparation for some clashing cgroups changes that subsume
> the original commit's functionaliy.


Please don't refer to commits via their bare hash number.

This commit actually has a different hash in my tree:

commit 096b7fe012d66ed55e98bc8022405ede0cc80e96
Author:     Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
AuthorDate: Wed Jul 29 15:04:04 2009 -0700
Commit:     Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
CommitDate: Wed Jul 29 19:10:35 2009 -0700

    cgroups: fix pid namespace bug


And it will definitely have a different hash in linux-next, -stable,
distro trees, etc.

So the conventional way of referring to a commit within a changelog is


096b7fe012d66ed55e98bc8022405ede0cc80e96 ("cgroups: fix pid namespace bug")
