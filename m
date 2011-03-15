From: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/2] suck some poison out of cgroups' linked lists
Date: Tue, 15 Mar 2011 15:08:41 +0200
Message-ID: <1300194523-19325-1-git-send-email-ext-phil.2.carmody__28947.889005258$1300195148$gmane$org@nokia.com>
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
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


I recently saw cgroup_attach_task drop this bomb:
[   46.045806] Unable to handle kernel paging request at virtual address 00200200
Which is clearly linked-list poison.

Dereferencing 00100104 has also been seen nearby according to a quick 
web-search that I did.

Apparently, whether nodes are on a list is being checked with list_empty(),
and if they're on a list, they're list_del()ed. According to a subsequent 
list_empty() check, they're still on a list, as list_del() doesn't turn
the nodes into singleton lists, it simply poisons both its pointers, and
merry poison dereferencing may ensue. Oops.

There are at least 2 to address this matter, I've gone for the latter:

1) Do not use list_empty() to check if a node is on a list or not. Have
an additional new function that checks to see whether the node is either
a singleton or is poisoned. Something like list_node_{on,off}_list()?

2) Ensure that you never leave poison anywhere where you might want
to use list_empty().

It might be that these oopses are seen only because there's a marginal
race in the cgroups code, as they seem to be very rare. In that case
this patchset might not fix the core problem, but might simply hide it.
Someone with more cgroups expertise might want to investigate that 
possibility.

Patch 1 is the "hindsight is 20/20" patch which would have made 
identifying the issue trivial.

Cheers,
Phil
