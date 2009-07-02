From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Thu, 02 Jul 2009 10:17:57 +0800
Message-ID: <4A4C18D5.7020806__46927.7011849501$1246507015$gmane$org@cn.fujitsu.com>
References: <4A4C0C60.4050106@cn.fujitsu.com>
	<6599ad830907011836x5eccc83eyc896a67295a6486d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907011836x5eccc83eyc896a67295a6486d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Thanks Li - but as I said to Serge in the email when I brought this up
> originally, I already had a patch in mind for this; I've had an intern
> (Ben) at Google working on it. His patch (pretty much ready, and being
> sent out tomorrow I hope) is pretty similar to yours, but his is on
> top of another patch that provides a (currently read-only)
> "cgroup.procs" file in each cgroup dir that lists the unique tgids in
> the cgroup. So the key in the list of pid arrays is actually a pid_ns
> and a file type (indicating procs or tasks) rather than just a pid_ns.
> 
> So I think it makes more sense to not use this patch, but to use the
> pair of patches that Ben's written, since they provide more overal
> functionality.
> 

But I guess we are going to fix the bug for 2.6.31? So is it ok to
merge a new feature 'cgroup.procs' together into 2.6.31?
