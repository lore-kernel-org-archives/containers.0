From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/3] userns fixes for v3.13-rc1
Date: Tue, 26 Nov 2013 16:14:19 -0800
Message-ID: <87siui1z1g.fsf_-_@xmission.com>
References: <20131115164123.GN28794@redhat.com>
	<20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131126181043.GA25492-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Tue, 26 Nov 2013 18:10:43 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


If folks will take a look I would appreciate it.  This is my pile of
user namespace fixes against v3.13-rc1.  All of these are minor
regressions that should be backported to v3.12.  Unfortunately they were
discovered late enough and I was running sick that I haven't had a time
to get to them earlier.

Eric W. Biederman (3):
      vfs: In d_path don't call d_dname on a mount point
      fork:  Allow CLONE_PARENT after setns(CLONE_NEWPID)
      vfs: Fix a regression in mounting proc

 fs/dcache.c    |    7 ++++++-
 fs/namespace.c |    2 +-
 kernel/fork.c  |    2 +-
 3 files changed, 8 insertions(+), 3 deletions(-)
