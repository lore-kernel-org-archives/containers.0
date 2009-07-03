From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Fri, 03 Jul 2009 09:15:04 +0800
Message-ID: <4A4D5B98.6000509__48633.8252005682$1246583704$gmane$org@cn.fujitsu.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702231814.3969.44308.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> The following series (written by Ben Blum) adds a "cgroup.procs" file

This is rather useful. :)

> to each cgroup that reports unique tgids rather than pids, and fixes a
> pid namespace bug in the existing "tasks" file that could cause
> readers in different namespaces to interfere with one another.
> 
> The patches as a pair provide similar functionality to Li Zefan's
> patch posted yesterday, with the addition on the "cgroup.procs" file;
> if it's decided that Li's patch needs to be fast-tracked to 2.6.31,
> then these patches can be rebased as a small extension of Li's patch;
> if Li'z patch doesn't need to go to 2.6.31 then it makes more sense to
> take this pair since they provide more overall functionality.
> 

I'd prefer fixing it for 2.6.31. There is no reason we don't fix it
earlier than later. Base a fix on top of a new feature is no good,
and it makes backporting the fix harder if someone wants to do this.
